//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise,gooch
//@credits:copyright nVidia corporation

//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tWIT:WorldInverseTranspose;
float4x4 tVI:ViewInverse;
float4x4 TT;
float gridSpaceX;
float gridSpaceY;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//material properties
float3 lPos <string UIName="Light Position";> = {0, -5, 2};
float4 LiteCol:COLOR <string UIName="Bright Surface Color";> ={0.8,0.5,0.1,1};
float4 DarkCol:COLOR <string UIName="Dark Surface Color";> ={0.0,0.0,0.0,1};
float4 WarmCol:COLOR <string UIName="Gooch Warm Tone";> ={0.5,0.4,0.05,1};
float4 CoolCol:COLOR <string UIName="Gooch Cool Tone";> ={0.05,0.05,0.6,1};
float4 SpecCol:COLOR <string UIName="Hilight Color";> ={0.7,0.7,1.0,1};
float SpecExpon <string UIName="Specular Exponent";float UIMin=0;float UIStep=1.0;> =40;
float GlossTop <string UIName="Maximum for Gloss Dropoff";float UIMin=0;float UIStep=0.05;> =.7;
float GlossBot <string UIName="Minimum for Gloss Dropoff";float UIMin=0;float UIStep=0.05;> =.5;
float GlossDrop <string UIName="Strength of Glossy Dropoff";float UIMin=0;float UIStep=.05;> =.2;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;
float timer:TIME;
float TurbDensity <string uiname="Turbulence Density";float UIMin=0;float UIStep=0.001;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0;float UIStep=0.01;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0;float UIStep=0.1;> =1.90;
float Speed <string uiname="Speed";float UIMin=0;float UIStep=0.001;> =.3;
float radius=1;
//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldPos:TEXCOORD3;
    float3 WorldEyePos:TEXCOORD4;
};

float3 sphere(float u,float v){
    float x=radius*cos(v)*sin(u) ;
    float y=radius*sin(v)*sin(u) ;
    float z=radius*cos(u) ;
    return float3(x,y,z);
}

#define TWOPI 6.28318531
#define PI 3.14159265

#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u,float v){
    float4 PosO=float4(sphere(u,v),1);
    float4 noisePos=TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i=(vnoise3D(noisePos.xyz,NTab)+1)*.5;
    // displacement along normal
    float ni=pow(abs(i),Sharp);
    i -=.5;
    //i = sign(i) * pow(i,Sharpness);
    float4 Nn=float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 UV:TEXCOORD0){
    vs2ps OUT=(vs2ps)0;
    PosO=mul(PosO, TT);
    
    float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;

    u = (PosO.x+.5)*PI;
    v = (PosO.y+.5)*TWOPI;
    u2 = (PosO.x+gridSpaceX+.5)*PI;
    v2 = (PosO.y+gridSpaceY+.5)*TWOPI;

    PosO.xyz=vNoiseFunc3D(u,v);
    tang=vNoiseFunc3D(u2,v);
    bitang=vNoiseFunc3D(u,v2);
    tang -=PosO.xyz;
    bitang -=PosO.xyz;

    NormO = cross(tang,bitang);
    OUT.LightVec = normalize(-mul(lPos,tV));
    OUT.WorldNormal = mul(NormO,tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.WorldPos = Pw;
    OUT.LightVec = lPos-Pw;
    OUT.TexCoord = mul(UV,tTex);
    OUT.WorldEyePos = tVI[3].xyz;
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

static float gMin = min(GlossBot,GlossTop);
static float gMax = max(GlossBot,GlossTop);
static float gDr = (1-GlossDrop);

void goochShared(vs2ps IN,out float4 DiffuseContrib,out float4 SpecularContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldEyePos-IN.WorldPos);
    float3 Hn = normalize(Vn+Ln);
    float hdn = pow(max(0,dot(Hn,Nn)),SpecExpon);
    hdn = hdn * (GlossDrop+smoothstep(gMin,gMax,hdn)*gDr);
    SpecularContrib = float4((hdn*SpecCol));
    float ldn = dot(Ln,Nn);
    float mixer = .5*(ldn+1);
    float diffComp = max(0,ldn);
    float3 surfColor = lerp(DarkCol,LiteCol,mixer);
    float3 toneColor = lerp(CoolCol,WarmCol,mixer);
    DiffuseContrib = float4((surfColor+toneColor),1);
}

float4 ps(vs2ps IN):COLOR{
    float4 diffContrib;
    float4 specContrib;
	goochShared(IN,diffContrib,specContrib);
    float4 result=tex2D(Samp,IN.TexCoord.xy)*diffContrib + specContrib;
    return mul(result,tColor);
}

technique vNoiseGoochy {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_0 ps();}}
