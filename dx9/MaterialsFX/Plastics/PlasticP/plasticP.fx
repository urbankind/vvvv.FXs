//@author:desaxismundi 
//@tags:plastic,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lDir <string UIName="Light Direction";> ={0.7,-0.7,-0.7};
float4 lCol : COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1};
float4 AmbiCol : COLOR <string UIName="Ambient Light Color";> ={0.07,0.07,0.07,1};
float4 SurfCol : COLOR <string UIName="Surface Color";> ={1.0,1.0,1.0,1};
float lInt <string UIName="Light Quadratic Intensity";float UIMin=1.0;float UIMax=128.0;> =20000;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =55;
float Kd <string UIName="Diffuse";float UIMin=0.0;float UIMax=1.0;> =.9;
float Ks <string UIName="Specualr";float UIMin=0.0;float UIMax=1.0;> =.4;

//sampler
texture Texture;
sampler2D Samp=sampler_state{Texture=(Texture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};

struct vs2ps {
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD3;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT=(vs2ps)0;
    float4 normal = normalize(NormO);
    OUT.WorldNormal = mul(normal,tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.LightVec = (lDir-Pw);
    OUT.TexCoord = UV;
    OUT.WorldView = normalize(tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

void plasticShared(vs2ps IN,float3 LightColor,out float3 DiffuseContrib,out float3 SpecularContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn+Ln);
    float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib = litV.y*Kd*LightColor+AmbiCol;
    SpecularContrib = litV.z*Ks*LightColor;
}

float4 plasticPSt(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
	plasticShared(IN,lCol,diffContrib,specContrib);
    float3 map = tex2D(Samp,IN.TexCoord.xy).xyz;
    float3 result = specContrib+(SurfCol*map*diffContrib);
    return float4(result,1);
}

// same as above with the addition of quadratic falloff
float4 plasticQPSt(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
	float3 Cl = (lInt/dot(IN.LightVec,IN.LightVec))*lCol;
	plasticShared(IN,Cl,diffContrib,specContrib);
    float3 map = tex2D(Samp,IN.TexCoord.xy).xyz;
    float3 result = specContrib+(SurfCol*map*diffContrib);
    return float4(result,1);
}

//pixel shaded, no falloff - plain or textured
technique PS {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 plasticPSt();}}
//pixel shaded, quadratic falloff
technique QuadraticPS {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 plasticQPSt();}}

