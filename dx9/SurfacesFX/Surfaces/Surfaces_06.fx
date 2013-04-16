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
vs2ps vsSTILETTO(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*TWOPI;

    PosO.x = (2+cos(u))*pow(cos(v),3)*sin(v);
    PosO.y = (2+cos(u+TWOPI/3))*pow(cos(v+TWOPI/3),2)*pow(sin(v+TWOPI/3),2);
    PosO.z = -(2+cos(u-TWOPI/3))*pow(cos(v+TWOPI/3),2)*pow(sin(v+TWOPI/3),2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsMAEDERSOWL(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y;

    PosO.x = v*cos(u)-0.5*pow(v,2)*cos(2*u);
    PosO.y = -v*sin(u)-0.5*pow(v,2)*sin(2*u);
    PosO.z = 4*pow(v,1.5)*cos(3*u/2)/3;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsTRIAXIALTRITORUS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = sin(u)*(1+cos(v));
    PosO.y = sin(u+TWOPI/3)*(1+cos(v+TWOPI/3));
    PosO.z = sin(u+2*TWOPI/3)*(1+cos(v+2*TWOPI/3));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsTEAR(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*PI;

    PosO.x = a*(1-cos(u))*sin(u)*cos(v);
    PosO.y = a*(1-cos(u))*sin(u)*sin(v);
    PosO.z = cos(u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////

vs2ps vsSLIPPERS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = (2+cos(u))*pow(cos(v),3)*sin(v);
    PosO.y = (2+cos(u+TWOPI/3))*pow(cos(TWOPI/3+v),2)*pow(sin(TWOPI/3+v),2);
    PosO.z = -(2+cos(u-TWOPI/3))*pow(cos(TWOPI/3-v),2)*pow(sin(TWOPI/3-v),3);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsKUEN(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = (PosO.x+0.5)*TWOPI;
    float v = (PosO.y+0.5)*TWOPI;

    PosO.x = (2*(cos(v)+(v*sin(v)))*sin(u))/(1+pow(v,2)*pow(sin(u),2));
    PosO.y = (2*(sin(v)-(v*cos(v)))*sin(u))/(1+pow(v,2)*pow(sin(u),2));
    PosO.z = (log(tan(u/2))+((2*cos(u))))/(1+pow(v,2)*pow(sin(u),2));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsKLEINCYCLOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = cos(u/c)*cos(u/b)*(a+cos(v))+sin(u/b)*sin(v)*cos(v);
    PosO.y = sin(u/c)*cos(u/b)*(a+cos(v))+sin(u/b)*sin(v)*cos(v);
    PosO.z = -sin(u/b)*(a+cos(v))+cos(u/b)*sin(v)*cos(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsKLEINBOTTLE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    float r = 4*(1-cos(u)/2);
    
    PosO.x = 6*cos(u)*(1+sin(u))+r*cos(v+PI);
    PosO.y = 16*sin(u);
    PosO.z = r*sin(v);

	Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
vs2ps vsTRACTRIX(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = cos(u)*(v-tanh(v));
    PosO.y = cos(u)/cosh(v);
    PosO.z = pow(PosO.x,2)-pow(PosO.y,2)+2*PosO.x*PosO.y*pow(tanh(u),2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////
float4 ps(vs2ps In):COLOR{
    float4 src = tex2D(s0,In.TexCd);
    float4 col1 = (In.colpos*src*col);
    col1.a = 1;
    return mul(col1,tColor);
}

technique Stiletto {pass P0{VertexShader=compile vs_1_1 vsSTILETTO();PixelShader=compile ps_2_0 ps();}}
technique MaedersHowl {pass P0{VertexShader=compile vs_1_1 vsMAEDERSOWL();PixelShader=compile ps_2_0 ps();}}
technique TriaxialTritorus {pass P0{VertexShader=compile vs_1_1 vsTRIAXIALTRITORUS();PixelShader=compile ps_2_0 ps();}}
technique Tear {pass P0{VertexShader=compile vs_1_1 vsTEAR();PixelShader=compile ps_2_0 ps();}}
technique Slippers {pass P0{VertexShader=compile vs_1_1 vsSLIPPERS();PixelShader=compile ps_2_0 ps();}}
technique Kuen {pass P0{VertexShader=compile vs_1_1 vsKUEN();PixelShader=compile ps_2_0 ps();}}
technique KleinCycloid {pass P0{VertexShader=compile vs_1_1 vsKLEINCYCLOID();PixelShader=compile ps_2_0 ps();}}
technique KleinBottle {pass P0{VertexShader=compile vs_1_1 vsKLEINBOTTLE();PixelShader=compile ps_2_0 ps();}}
technique Tractrix {pass P0{VertexShader=compile vs_1_1 vsTRACTRIX();PixelShader=compile ps_2_0 ps();}}
technique Helicoid {pass P0{VertexShader=compile vs_1_1 vsHELICOID();PixelShader=compile ps_2_0 ps();}}

