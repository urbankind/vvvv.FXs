//@author:desaxismundi
//@help:a phong-shaded metal-style surface
//@tags:bump,plastic
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 LightPos={0,0,-1};
float4 LightColor:COLOR =1;
float4 AmbiColor:COLOR =1;
float4 SurfColor:COLOR =1;
float SpecExpon <string uiname="specular power";float uimin=1.0;float uimax=128.0;float uistep=1.0;> =12;
float Bumpy <string uiname="bump power";float uimin=0.0;float uimax=10.0;float uistep=0.1;> =1;

//samplers
texture colorTex;
sampler colorSamp=sampler_state{Texture=(colorTex);MipFilter=Linear;MinFilter=Linear;MagFilter=Linear;};
texture normalTex;
sampler normalSamp=sampler_state{Texture=(normalTex);MipFilter=Linear;MinFilter=Linear;MagFilter=Linear;};

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 lDir:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
    float3 WorldTangent:TEXCOORD4;
    float3 WorldBinorm:TEXCOORD5;
};

vs2ps vs(
	float3 PosO:POSITION,
    float4 UV:TEXCOORD0,
    float4 Normal:NORMAL,
    float4 Tangent:TANGENT,
    float4 Binormal:BINORMAL)
{
    vs2ps OUT;
    OUT.WorldNormal=mul(Normal,tWIT).xyz;
    OUT.WorldTangent=mul(Tangent,tWIT).xyz;
    OUT.WorldBinorm=mul(Binormal,tWIT).xyz;
    float4 tempPos=float4(PosO.x,PosO.y,PosO.z,1);
    float3 worldSpacePos=mul(tempPos,tW).xyz;
    OUT.lDir=LightPos-worldSpacePos;
    OUT.TexCd=UV;
    OUT.WorldEyeVec=normalize(tVI[3].xyz-worldSpacePos);
    OUT.Pos=mul(tempPos,tWVP);	
    return OUT;
}

float4 psBUMPPLASTIC(vs2ps IN):COLOR{
    float4 map=tex2D(colorSamp,IN.TexCd.xy);
    float3 bumps=Bumpy*(tex2D(normalSamp,IN.TexCd.xy).xyz-(.5).xxx);
    float3 Ln=normalize(IN.lDir);
    float3 Nn=normalize(IN.WorldNormal);
    float3 Tn=normalize(IN.WorldTangent);
    float3 Bn=normalize(IN.WorldBinorm);
    float3 Nb=Nn+(bumps.x*Tn+bumps.y*Bn);
    	   Nb=normalize(Nb);
    float3 Vn=normalize(IN.WorldEyeVec);
    float3 Hn=normalize(Vn+Ln);
    float4 lighting=lit(dot(Ln,Nb),dot(Hn,Nb),SpecExpon);
    float hdn=lighting.z;
    float ldn=lighting.y;
    float diffComp=ldn;
    float4 diffContrib=SurfColor*map*(diffComp*LightColor+AmbiColor);
    float4 specContrib=hdn*LightColor;
    float4 result=AmbiColor+diffContrib+specContrib;	
    return result;
}

technique BumpPlastic{pass p0{vertexshader=compile vs_2_0 vs();pixelshader=compile ps_2_0 psBUMPPLASTIC();}}

