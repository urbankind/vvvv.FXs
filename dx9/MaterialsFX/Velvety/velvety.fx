//@author:desaxismundi
//@tags:velvet,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string uiname="Light Position";> ={0,-5,2};
float4 lDiff:COLOR <string uiname="Diffuse Color";> ={0.5,0.5,0.5,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.7,0.7,0.75,1};
float4 lSub:COLOR <String uiname="Under-Color";> ={0.2,0.2,1.0,1};
float lRollOff <String uiname="Edge Rolloff";float UIMin=0.0; float UIMax=1.0; float UIStep=0.05;> =.3;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=None;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD3;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

vs2ps vsVELVET(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
	vs2ps OUT=(vs2ps)0;
    float3 Nn=normalize(mul(NormO, tWIT).xyz);
    float4 Po=float4(PosO.xyz,1);
    OUT.HPosition=mul(Po,tWVP);
    float3 Pw=mul(Po,tW).xyz;
    float3 Ln=normalize(lPos-Pw);
    float ldn=dot(Ln,Nn);
    float diffComp=max(0,ldn);
    float3 diffContrib=diffComp*lDiff;
    float subLamb=smoothstep(-lRollOff,1,ldn)-smoothstep(0.0,1,ldn);
    subLamb=max(0,subLamb);
    float3 subContrib=subLamb*lSub;
    OUT.TexCoord=UV;
    float3 Vn=normalize(tVI[3].xyz-Pw);
    float vdn=1-dot(Vn,Nn);
    float3 vecColor=float4(vdn.xxx,1);
    OUT.diffCol=float4((subContrib+diffContrib).xyz,1);
    OUT.specCol=float4((vecColor*lSpec).xyz,1);
    return OUT;
}

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT=(vs2ps)0;  
    float4 normal=normalize(NormO);
    OUT.WorldNormal=mul(normal,tWIT).xyz;
    float4 Po=float4(PosO.xyz,1);
    float3 Pw=mul(Po,tW).xyz;
    OUT.LightVec=normalize(lPos-Pw);
    OUT.TexCoord=UV.xyxx;
    OUT.WorldView=normalize(tVI[3].xyz-Pw);
    OUT.HPosition=mul(Po,tWVP);
    return OUT;
}

void velvetShared(vs2ps IN,out float3 DiffuseContrib,out float3 SpecularContrib){
    float3 Ln=normalize(IN.LightVec);
    float3 Nn=normalize(IN.WorldNormal);
    float3 Vn=normalize(IN.WorldView);
    float3 Hn=normalize(Vn+Ln);
    float ldn=dot(Ln,Nn);
    float diffComp=max(0,ldn);
    float3 diffContrib=diffComp*lDiff;
    float subLamb=smoothstep(-lRollOff,1,ldn)-smoothstep(0,1,ldn);
    subLamb=max(0,subLamb);
    float3 subContrib=subLamb*lSub;
    float vdn=1-dot(Vn,Nn);
    float3 vecColor=float4(vdn.xxx,1);
    DiffuseContrib=float4((subContrib+diffContrib).xyz,1);
    SpecularContrib=float4((vecColor*lSpec).xyz,1);
}

float4 psVELVET(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
	velvetShared(IN,diffContrib,specContrib);
    float3 map=tex2D(Samp,IN.TexCoord.xy).xyz;
    float3 result=specContrib+(map*diffContrib);
    return float4(result,1);
}

technique TexturedPS {pass pp0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 psVELVET();}}
technique VertexTextured {pass pp0{VertexShader=compile vs_1_1 vsVELVET();
		SpecularEnable = true;
	    Texture[0] = <Tex>;
	    MinFilter[0] = Linear;
	    MagFilter[0] = Linear;
	    MipFilter[0] = None;
        ColorArg1[ 0 ] = Texture;
        ColorOp[ 0 ] = Modulate;
        ColorArg2[ 0 ] = Diffuse;
    }
}
