//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP : WorldViewProjection;
float4x4 TT <String uiname="Transform before function";>;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

float4 col:COLOR <String uiname="Color";>  ={1,1,1,1};
float4x4 tColor <string uiname="Color Transform";>;
float timer : TIME;
float TurbDensity <string uiname="Turbulence Density";float UImin=0;> =2.27;
float Disp <string uiname="Displacement";> =1.6;
float Sharp <string uiname="Sharpness";> =1.9;
float Speed <string uiname="Speed";> =0.3;
float ColorRange <string uiname="Color Range";> =-2;
float ColSharp <string uiname="ColorSharpness";> =3;
//float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCoord:TEXCOORD0;
    float4 colpos:TEXCOORD1;
};

#include "vnoise-table.fxh"
#include "vnoise.fxh"
#define TWOPI 6.28318531
#define PI 3.14159265

vs2ps vsVNOISE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps OUT=(vs2ps)0;
    PosO=mul(PosO,TT);
	
    float u=(PosO.x)*TWOPI;
    float v=(PosO.y)*PI;
   
    PosO.x=cos(v)*sin(u);
    PosO.y=sin(v)*sin(u);
    PosO.z=cos(u) ;
    
    float4 noisePos=TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i=(vnoise3D(noisePos.xyz, NTab)+1)*.5;
    float cr=1-(.5+ColorRange*(i-.5));
    cr=pow(cr,ColSharp);
    OUT.colpos=float4((cr).xxx,1);
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=.5;
   float4 Nn=float4(normalize(PosO).xyz,0);
   float4 NewPos=PosO-(Nn*(ni-.5)*Disp);
   OUT.TexCoord =mul(TexCd, tTex);
   OUT.Pos=mul(NewPos,tWVP); 
   return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float4 src=tex2D(Samp,IN.TexCoord);
    float4 col1=(IN.colpos*src*col);
    return mul(col1,tColor);
}

technique VertexNoise {pass P0{ Wrap0 = U;VertexShader = compile vs_2_0 vsVNOISE3D();PixelShader = compile ps_2_0 ps();}}
