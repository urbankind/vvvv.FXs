//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise,reflection
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;
float4x4 TT;
float gridSpaceX;
float gridSpaceY;
float4x4 NoiseMatrix ={1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//material properties
float3 lPos <string uiname="Light Position";> ={100.0,100.0,-100.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1};
float4 AmbiCol:COLOR <string UIName="Ambient Light Color";> ={0.07,0.07,0.07,1};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={0.546,0.379,0.218,1};
float4x4 tColor <string uiname="Color Transform";>;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =80;
float Kd <string UIName="Diffuse ";float UIMin=0.0;float UIMax=1.0;> =.1;
float Kr <string UIName="Reflection";float UIMin=0.0;float UIMax=1.0;> =.8;
float FresnelMin <string UIName="Fresnel Reflection Scale";float UIMin=0.0;float UIMax=1.0;> =.05;
static float KrMin=(Kr*FresnelMin);
float FresnelExp<string UIName="Fresnel Exponent";float UIMin=0.0;float UIMax=5.0;> =3.5;
static float InvFrExp=(1/FresnelExp);

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float timer:TIME;
float TurbDensity <string uiname="Turbulence Density";float UIMin=0.01;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0.0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0.1;> =1.9;
float Speed <string uiname="Speed";float UIMin=0.01;> =.3;
float radius=1;
//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD3;
};

float3 sphere(float u, float v){
    float x = radius*cos(v)*sin(u);
    float y = radius*sin(v)*sin(u);
    float z = radius*cos(u);
    return float3(x,y,z);
}

#define TWOPI 6.28318531
#define PI 3.14159265

#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u, float v){
    float4 PosO = float4(sphere(u, v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz,NTab)+1)*.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -= .5;
    //i = sign(i) * pow(i,Sharpness);
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 UV:TEXCOORD0){
    vs2ps OUT = (vs2ps)0;
    PosO =  mul(PosO,TT);
    
    float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;

    u = (PosO.x+.5)* PI;
    v = (PosO.y+.5)*TWOPI;
    u2 = (PosO.x+gridSpaceX+.5)*PI;
    v2 = (PosO.y+gridSpaceY+.5)*TWOPI;
	
    PosO.xyz = vNoiseFunc3D(u,v);
    tang = vNoiseFunc3D(u2,v);
    bitang = vNoiseFunc3D(u,v2);
    tang -= PosO.xyz;
    bitang -= PosO.xyz;
    NormO = cross(tang,bitang);

    OUT.WorldNormal = mul(NormO,tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po, tW).xyz;
    OUT.LightVec = normalize(lPos-Pw);
    OUT.TexCoord = UV;
    OUT.WorldView = normalize(tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

void SharedLightingCalculations(vs2ps IN,out float3 DiffuseContrib,out float3 SpecularContrib,out float3 ReflectionContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn + Ln);
    float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib = litV.y * Kd * lCol + AmbiCol;
    SpecularContrib = litV.z * lCol;
    float3 reflVect = -reflect(Vn,Nn);
    ReflectionContrib = Kr * texCUBE(Samp,reflVect).xyz;
}

float4 psMETAL(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
	SharedLightingCalculations(IN,diffContrib,specContrib,reflColor);
    float3 result = diffContrib +(SurfCol * (specContrib + reflColor));
    return mul((float4(result,1)),tColor);
}

float4 psPLASTIC(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
	float fresnel = lerp(Kr,KrMin,pow(abs(dot(Nn,Vn)),InvFrExp));
	SharedLightingCalculations(IN,diffContrib,specContrib,reflColor);
    float3 result = (diffContrib * SurfCol) + specContrib + (fresnel*reflColor);
    return mul((float4(result,1)),tColor);
}

technique vNoise3DMetal {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_0 psMETAL();}}
technique vNoise3DnoisePlastic {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_0 psPLASTIC();}}
