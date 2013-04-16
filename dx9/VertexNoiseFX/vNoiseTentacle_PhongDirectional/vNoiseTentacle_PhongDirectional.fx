//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise,phong,directional
//@credits:copyright nVidia corporation

//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;       
float4x4 tWV:WORLDVIEW;
float4x4 tVP:VIEWPROJECTION;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tP:PROJECTION;  
float4x4 TT ;
float gridSpaceX;
float gridSpaceY;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//light properties
float3 lDir <string uiname="Light Direction";> ={0,-5,2};        
float4 lAmb:COLOR <String uiname="Ambient Color";> ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float lPower <String uiname="Power"; float uimin=0.0;> =25;    
float4x4 tColor <string uiname="Color Transform";>;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex:TEXTUREMATRIX <string uiname="Texture Transform";>;

float timer;
float TurbDensity <string uiname="Turbulence Density";float UIMin=0.01;float UIMax=8.0;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0.0;float UIMax=2.0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0.1;float UIMax=5.0;> =1.9;
float Speed <string uiname="Speed";float UIMin=0.01;float UIMax=1.0;> =.3;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightDirV:TEXCOORD1;
    float3 NormV:TEXCOORD2;
    float3 ViewDirV:TEXCOORD3;
    float3 Pos:TEXCOORD4;
};

#define TWOPI 6.28318531
#define PI 3.14159265
float gridScaleX = 1;
float gridScaleY = 1;
float param1 = 1;
float param2 = 1;
float param3 = 1;
float param4 = 1;

float3 cone(float u,float theta){
   float3 p;
   float a =((gridScaleX-u)/gridScaleX)*param1;// * (param2 * (cos(u*param3)+1) + 1);
   float3 offset;
   p.x = a*cos(theta);
   p.y = a*sin(theta);
   p.z = u;
   offset.x = u*cos(param2*TWOPI-u);
   offset.y = u*cos(param3*TWOPI-u);
   offset.z = 0;
   return p+offset*param4;
}

#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u,float v){
    float4 PosO = float4(cone(u, v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz,NTab)+1)*.5;
    //displacement along normal
    float ni = pow(abs(i),Sharp);
    i -= .5;
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

float3 vNoiseFunc2D(float u,float v){
    float4 PosO = float4(cone(u, v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise2D(noisePos.xy, NTab)+1)*.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -= .5;
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

float3 vNoiseFunc1D(float u,float v){
    float4 PosO = float4(cone(u, v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise1D(noisePos.y,NTab)+1)*.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -= .5;
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float x, y, z, u, v, pi;
    float u2, v2;
    float3 tang, bitang;

    gridScaleX *= PI;
    gridScaleY *= TWOPI;

    u = (PosO.x + 0.5) * gridScaleX;
    v = (PosO.y + 0.5) * gridScaleY;
    u2 = (PosO.x + gridSpaceX + 0.5) * gridScaleX;
    v2 = (PosO.y + gridSpaceY + 0.5) * gridScaleY;

    PosO.xyz = vNoiseFunc3D(u, v);
    tang   = vNoiseFunc3D(u2, v);
    bitang = vNoiseFunc3D(u, v2);
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;

    NormO = cross(tang, bitang);
    Out.LightDirV = normalize(-mul(lDir, tV));
    Out.NormV = normalize(mul(NormO, tWV));
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

vs2ps vsVNOISE2D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
    
    float x, y, z, u, v, pi;
    float u2, v2;
    float3 tang, bitang;

    //map u and v
    gridScaleX *= PI;
    gridScaleY *= TWOPI;
    u = (PosO.x + 0.5) * gridScaleX;
    v = (PosO.y + 0.5) * gridScaleY;
    u2 = (PosO.x + gridSpaceX + 0.5) * gridScaleX;
    v2 = (PosO.y + gridSpaceY + 0.5) * gridScaleY;

    //get position
    PosO.xyz = vNoiseFunc2D(u, v);
    tang = vNoiseFunc2D(u2, v);
    bitang = vNoiseFunc2D(u, v2);
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;

    NormO = cross(tang, bitang);
    Out.LightDirV = normalize(-mul(lDir, tV));
    Out.NormV = normalize(mul(NormO, tWV));
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

vs2ps vsVNOISE1D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
   
    float x, y, z, u, v, pi;
    float u2, v2;
    float3 tang, bitang;

    //map u and v
    gridScaleX *= PI;
    gridScaleY *= TWOPI;
    u = (PosO.x + 0.5) * gridScaleX;
    v = (PosO.y + 0.5) * gridScaleY;
    u2 = (PosO.x + gridSpaceX + 0.5) * gridScaleX;
    v2 = (PosO.y + gridSpaceY + 0.5) * gridScaleY;

    PosO.xyz = vNoiseFunc1D(u, v);
    tang   = vNoiseFunc1D(u2, v);
    bitang = vNoiseFunc1D(u, v2);
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;

    NormO = cross(tang, bitang);
    Out.LightDirV = normalize(-mul(lDir, tV));
    Out.NormV = normalize(mul(NormO, tWV));
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

float4 ps(vs2ps In):COLOR{
    lAmb.a = 1;
    float3 H = normalize(In.ViewDirV + In.LightDirV);
    float3 shades = lit(dot(In.NormV, In.LightDirV), dot(In.NormV, H), lPower);
    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float3 R = normalize(2 * dot(In.NormV, In.LightDirV) * In.NormV - In.LightDirV);
    float3 V = normalize(In.ViewDirV);
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;
    float4 col = tex2D(Samp, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return mul(col, tColor);
}

technique vNoise3D {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_a ps();}}
technique vNoise2D {pass P0{VertexShader=compile vs_3_0 vsVNOISE2D();PixelShader=compile ps_2_a ps();}}
technique vNoise1D {pass P0{VertexShader=compile vs_3_0 vsVNOISE1D();PixelShader=compile ps_2_a ps();}}
