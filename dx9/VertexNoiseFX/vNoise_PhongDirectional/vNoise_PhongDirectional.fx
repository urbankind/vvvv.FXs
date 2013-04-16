//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise,phong,directional
//@credits:copyright nVidia corporation

//transforms
float4x4 tW :WORLD;
float4x4 tV :VIEW;       
float4x4 tWV:WORLDVIEW;
float4x4 tVP:VIEWPROJECTION;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tP:PROJECTION;   
float4x4 TT;
float gridSpaceX;
float gridSpaceY;
float4x4 NoiseMatrix ={1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//material properties
float3 lDir <string uiname="Light Direction";> ={0,-5,2};       
float4 lAmb:COLOR <String uiname="Ambient Color";>  ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";>  ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float  lPower <String uiname="Power"; float uimin=0.0;> =25;     

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

float radius = 1;
float timer;
float TurbDensity <string uiname="Turbulence Density";float UIMin = 0;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin = 0;> =1.9;
float Speed <string uiname="Speed";float UIMin=0;float UIStep=0.001;> =.3;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightDirV:TEXCOORD1;
    float3 NormV:TEXCOORD2;
    float3 ViewDirV:TEXCOORD3;
    float3 Pos:TEXCOORD4;
};

float3 sphere(float u,float v){
    float x = radius*cos(v)*sin(u);
    float y = radius*sin(v)*sin(u);
    float z = radius*cos(u) ;
    return float3(x,y,z);
}

#define TWOPI 6.28318531
#define PI 3.14159265

#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u,float v){
    float4 PosO = float4(sphere(u,v),1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz, NTab)+1.0)*0.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i = sign(i) * pow(i,Sharp);
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-0.5)*Disp);
}

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO,TT);
    float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;

    u = (PosO.x+.5)*PI;
    v = (PosO.y+.5)*TWOPI;
    u2 = (PosO.x+gridSpaceX +.5)*PI;
    v2 = (PosO.y+gridSpaceY +.5)*TWOPI;

    //get positions
    PosO.xyz = vNoiseFunc3D(u,v);
    tang   = vNoiseFunc3D(u2,v);
    bitang = vNoiseFunc3D(u,v2);
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;
    NormO = cross(tang,bitang);

    Out.LightDirV = normalize(-mul(lDir,tV));
    Out.NormV = normalize(mul(NormO,tWV));
    Out.PosWVP  = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    Out.ViewDirV = -normalize(mul(PosO,tWV));
    return Out;
}

float4 ps(vs2ps In):COLOR{
    lAmb.a = 1;
    float3 H = normalize(In.ViewDirV+In.LightDirV);
    float3 shades = lit(dot(In.NormV,In.LightDirV),dot(In.NormV,H),lPower);
    float4 diff = lDiff *shades.y;
    diff.a = 1;
    float3 R = normalize(2*dot(In.NormV,In.LightDirV)*In.NormV -In.LightDirV);
    float3 V = normalize(In.ViewDirV);
    float4 spec = pow(max(dot(R,V),0),lPower*.2)*lSpec;
    float4 col = tex2D(Samp,In.TexCd);
    col.rgb *= (lAmb+diff)+spec;
    return mul(col,tColor);
}

technique vNoisePhong {pass P0{VertexShader=compile vs_3_0 vsVNOISE3D();PixelShader=compile ps_2_0 ps();}}
