//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;       
float4x4 tP:PROJECTION;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 TB ;
float4 lAmb:COLOR <String uiname="Ambient Color";> ={0.15,0.15,0.15,1};

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX ;

float param1 = 1;
float param2 = 1;
float param3 = 1;
float param4 = 1;

struct vs2ps{
    float4 Pos:POSITION;
    float2 TexCd:TEXCOORD0;
    float4 TexCol:TEXCOORD1;
};

#define TWOPI 6.28318531
#define PI 3.14159265

vs2ps VSSteinbachScrew(float4 PosO:POSITION,float4 TexCd:TEXCOORD0)
{
    vs2ps Out=(vs2ps)0;
    PosO=mul(PosO,TB);  
    float u=PosO.x*TWOPI;
    float v=PosO.y*TWOPI ;
    PosO.x=param1*(sin(v)*cos(param3*u))/(1+cosh(u)*cosh(v));
    PosO.y=param1*(sin(v)*sin(param3*u))/(1+cosh(u)*cosh(v));
    Out.Pos=mul(PosO,tWVP);
    Out.TexCol=PosO;
    Out.TexCd=mul(TexCd,tTex);
    return Out;
}

float4 PS(vs2ps In):COLOR
{
    float4 col=tex2D(Samp,In.TexCd)*lAmb;
    return col;
}

technique TSteinbachScrew {pass P0{VertexShader=compile vs_2_0 VSSteinbachScrew();PixelShader =compile ps_2_0 PS();}}
