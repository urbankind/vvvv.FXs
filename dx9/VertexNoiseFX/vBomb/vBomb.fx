//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vBomb,vnoise
//@credits:copyright nVidia corporation

//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;        
float4x4 tP:PROJECTION;  
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MinFilter=LINEAR;MagFilter=LINEAR;MipFilter=POINT;AddressU=CLAMP;AddressV=CLAMP;};

float timer:TIME;
float4 tColor:color;
float Disp <string uiname="Displacement";float UIMin=0.0;float UIMax=10.0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0.1;float UIMax=10.0;> =1.9;
float Speed <string uiname="Speed";float UIMin=0.01;float UIMax=5.0;> =.3;
float TurbDensity <string uiname="Turbulence Density";float UIMin=0.01;float UIMax=10.0;> =2.27;   
float ColSharp <string uiname="ColorSharpness";float UIMin=0.1;float UIMax=10.0;> =3;
float ColorRange <string uiname="Color Range";float UIMin=-6.0;float UIMax=5.0;> =-2;
//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps{
    float4 Pos:POSITION;
    float4 Color0:COLOR0;
};

#include "vnoise-table.fxh"
#include "vnoise.fxh"

vs2ps vsVBOMB3D(float4 PosO:POSITION,float4 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps OUT=(vs2ps)0;
    float4 noisePos=TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i=(vnoise3D(noisePos.xyz,NTab)+1)*.5;
    float cr=1-(.5+ColorRange*(i-.5));
    cr=pow(cr,ColSharp);
    OUT.Color0=float4((cr).xxx,1);
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=.5;
    //i = sign(i) * pow(i,Sharpness);
    float4 Nn=float4(normalize(PosO).xyz,0);
    float4 NewPos=PosO-(Nn*(ni-.5)*Disp);
    //position.w = 1.0f;
    OUT.Pos=mul(NewPos,tWVP);
    return OUT;
}

float4 PS(vs2ps IN):COLOR{
float2 nuv=float2(IN.Color0.x,.5);
float4 nc=tex2D(Samp,nuv);
//return float4(IN.Color0.xxx,1.0);
return nc*tColor;
}

technique vBomb3Dnoise {pass p0{VertexShader=compile vs_2_0 vsVBOMB3D();PixelShader=compile ps_2_0 PS();}}
