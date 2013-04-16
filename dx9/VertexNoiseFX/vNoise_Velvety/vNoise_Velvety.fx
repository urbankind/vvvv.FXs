//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise,velvet
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
float3 lPos <string uiname="Light Position";> ={0,-5,2};
float4 lDiff:COLOR <string uiname="Diffuse Color";> ={0.5,0.5,0.5,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.7,0.7,0.75,1};
float4 lSub:COLOR <String uiname="Under-Color";> ={0.2,0.2,1.0,1};
float lRollOff <String uiname="Edge Rolloff";float UIMin=0.0; float UIMax=1.0;> =.3;
float4x4 tColor <string uiname="Color Transform";>;
float timer : TIME;
float TurbDensity <string uiname="Turbulence Density";float UIMin=0;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0;> =1.9;
float Speed <string uiname="Speed";float UIMin=0;> =.3;
float radius =1;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps{
    float4 HPosition:POSITION;
    half4  TexCoord:TEXCOORD0;
    half3 LightVec:TEXCOORD1;
    half3 WorldNormal:TEXCOORD2;
    half3 WorldView:TEXCOORD3;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

float3 sphere(float u,float v){
    float x = radius*cos(v)*sin(u);
    float y = radius*sin(v)*sin(u);
    float z = radius*cos(u);
    return float3(x,y,z);
}

#define TWOPI 6.28318531
#define PI 3.14159265

#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u,float v){
    float4 PosO = float4(sphere(u,v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz,NTab)+1)*.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=.5;
    //i = sign(i) * pow(i,Sharpness);
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps OUT = (vs2ps)0;
    PosO =  mul(PosO,TT);
    
    float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;
    u = (PosO.x +.5)*PI;
    v = (PosO.y +.5)*TWOPI;
    //to get neighbour
    u2 = (PosO.x+gridSpaceX+.5)*PI;
    v2 = (PosO.y+gridSpaceY+.5)*TWOPI;
    //get position
    PosO.xyz = vNoiseFunc3D(u,v);
    //get position of neighbours
    tang   = vNoiseFunc3D(u2,v);
    bitang = vNoiseFunc3D(u,v2);
    //get tangent and bitangent
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;
    //get normal
    NormO = cross(tang, bitang);
    OUT.WorldNormal = mul(NormO,tWIT).xyz;
    half4 Po = half4(PosO.xyz,1);
    half3 Pw = mul(Po,tW).xyz;
    OUT.LightVec = normalize(lPos-Pw);
    OUT.TexCoord = TexCd.xyxx;
    OUT.WorldView = normalize(tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

void velvetShared(vs2ps IN,out half3 DiffuseContrib,out half3 SpecularContrib){
    half3 Ln = normalize(IN.LightVec);
    half3 Nn = normalize(IN.WorldNormal);
    half3 Vn = normalize(IN.WorldView);
    half3 Hn = normalize(Vn+Ln);
    float ldn = dot(Ln,Nn);
    float diffComp = max(0,ldn);
    float3 diffContrib = diffComp*lDiff;
    float subLamb = smoothstep(-lRollOff,1,ldn)-smoothstep(0,1,ldn);
    subLamb = max(0,subLamb);
    float3 subContrib = subLamb*lSub;
    float vdn = 1-dot(Vn,Nn);
    float3 vecColor = float4(vdn.xxx,1);
    DiffuseContrib = float4((subContrib+diffContrib).xyz,1);
    SpecularContrib = float4((vecColor*lSpec).xyz,1);
}

half4 PS(vs2ps IN):COLOR{
    half3 diffContrib;
    half3 specContrib;
	velvetShared(IN,diffContrib,specContrib);
    half3 map = tex2D(Samp,IN.TexCoord.xy).xyz;
    half3 result = specContrib+(map*diffContrib);
    return mul((half4(result,1)),tColor);
}

technique vNoiseVelvety {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_0 PS();}}
