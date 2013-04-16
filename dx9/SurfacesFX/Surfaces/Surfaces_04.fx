//@author:desaxismundi
//@tags:surfaces,3D
//http://local.wasp.uwa.edu.au/~pbourke/surfaces_curves/
//http://mathworld.wolfram.com/topics/Surfaces.html

//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 TT;

//material properties
float3 lpos <String uiname="Light Position";>;
float4 col:COLOR<String uiname="Color";> =1;
float4x4 tColor <string uiname="Color Transform";>;

float a=1;
float b=1;
float c=1;
float d=1;

//texture
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;AddressU=WRAP;AddressV=WRAP;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
	float4 PosWVP:POSITION;
	float4 TexCd:TEXCOORD0;
	float4 colpos:TEXCOORD1;
};

#define TWOPI 6.28318531
#define PI 3.14159265

///////////////////////////////////////////////////////////////
vs2ps vsSCHERK(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*8;
    float v = PosO.y*12.5;

    PosO.x = u;
    PosO.y = v;
    PosO.z = log(cos(c*u)/cos(c*v))/c;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
//////////////////////////////////////////////
vs2ps vsDINI(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*PI;

    PosO.x = a*cos(u)*sin(v);
    PosO.y = a*sin(u)*sin(v);
    PosO.z = a*(cos(v)+log(tan(v/2)))+b*u;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
/////////////////////////////////////////////////////////
vs2ps vsHELICOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2;
    float v = PosO.y*2;

    PosO.x = c*v*cos(u);
    PosO.y = c*v*sin(u);
    PosO.z = u;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////
vs2ps vsBOUR(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = (PosO.x+0.5)*PI;
    float v = (PosO.y+0.5)*TWOPI;

    PosO.x = pow(u,a-1)*cos((a-1)*v)/(2*(a-1))-pow(u,a+1)*cos((a+1)*v)/(2*(a+1));
    PosO.y = pow(u,a-1)*sin((a-1)*v)/(2*(a-1))+pow(u,a+1)*sin((a+1)*v)/(2*(a+1));
    PosO.z = pow(u,a)*cos(a*v)/a;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////
vs2ps vsCATALAN(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x;
    float v = PosO.y;

    PosO.x = c*(u-cosh(v)*sin(u));
    PosO.y = c*(1-cosh(v)*cos(u));
    PosO.z = -4*c*sin(u/2)*sinh(v/2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd  = mul(TexCd, tTex);
    return Out;
}
///////////////////////////////////////////////////////
vs2ps vsFISH(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*PI;
    float v = PosO.y*2*TWOPI;

    PosO.x = (cos(u)-cos(2*u))*cos(v)/4;
    PosO.y = (sin(u)-sin(2*u))*sin(v)/4;
    PosO.z = cos(u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////
vs2ps vsDOUBLECONE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2;

    PosO.x = v*cos(u);
    PosO.y = (v-1)*cos(u+TWOPI/3);
    PosO.z = (1-v)*cos(u-TWOPI/3);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////
vs2ps vsTRIAXIALTEARDROP(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*PI;
    float v = PosO.y*TWOPI;

    PosO.x = (1-cos(u))*cos(u+TWOPI/3)*cos(v+TWOPI/3)/2;
    PosO.y = (1-cosh(u))*cos(u+TWOPI/3)*cos(v-TWOPI/3)/2;
    PosO.z = cos(u-TWOPI/3);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////
vs2ps vsJET(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = (PosO.x+0.5)*PI;
    float v = (PosO.y+0.5)*TWOPI;

    PosO.x = (1-cosh(u))*sin(u)*cos(v)/2;
    PosO.y = (1-cosh(u))*sin(u)*sin(v)/2;
    PosO.z = cosh(u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
float4 ps(vs2ps In):COLOR{
    float4 src = tex2D(s0,In.TexCd);
    float4 col1 = (In.colpos*src*col);
    col1.a = 1;
    return mul(col1,tColor);
}

technique Scherk {pass P0{VertexShader=compile vs_1_1 vsSCHERK();PixelShader=compile ps_2_0 ps();}}
technique Dini {pass P0{VertexShader=compile vs_1_1 vsDINI();PixelShader=compile ps_2_0 ps();}}
technique Helicoid {pass P0{VertexShader=compile vs_1_1 vsHELICOID();PixelShader=compile ps_2_0 ps();}}
technique Bour {pass P0{VertexShader=compile vs_1_1 vsBOUR();PixelShader=compile ps_2_0 ps();}}
technique Catalan {pass P0{VertexShader=compile vs_1_1 vsCATALAN();PixelShader=compile ps_2_0 ps();}}
technique Fish {pass P0{VertexShader=compile vs_1_1 vsFISH();PixelShader=compile ps_2_0 ps();}}
technique DoubleCone {pass P0{VertexShader=compile vs_1_1 vsDOUBLECONE();PixelShader=compile ps_2_0 ps();}}
technique TriaxialTeardrop {pass P0{VertexShader=compile vs_1_1 vsTRIAXIALTEARDROP();PixelShader=compile ps_2_0 ps();}}
technique jet {pass P0{VertexShader=compile vs_1_1 vsJET();PixelShader=compile ps_2_0 ps();}}

