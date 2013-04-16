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
vs2ps vsPARABOLOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
	float u = PosO.x*2;
	float v = PosO.y*2*TWOPI;

    PosO.x = a*pow((u/b),.5)*cos(v);
    PosO.y = a*pow((u/b),.5)*sin(v);
    PosO.z = (u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsHYPERBOLOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*TWOPI;

	PosO.x = a*pow((1+pow(u,2)),.5)*cos(v);
	PosO.y = b*pow((1+pow(u,2)),.5)*sin(v);
	PosO.z = c*(u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsLIMPETTORUS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO, TT);
	
	float u = PosO.x*2*PI;
	float v = PosO.y*2*PI;

	PosO.x = cos(u)/(sqrt(2)+sin(v));
	PosO.y = sin(u)/(sqrt(2)+sin(v));
	PosO.z = 1/(sqrt(2)+cos(v));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsHANDKERCHIEF(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2;
    float v = PosO.y*2;

	PosO.x = u;
	PosO.y = v;
	PosO.z = pow(u,3)/3+u*pow(v,2)+a*(pow(u,2)-pow(v,2));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsAPPLE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*PI;

	PosO.x = cos(u)*(4+3.8*cos(v));
	PosO.y = sin(u)*(4+3.8*cos(v));
	PosO.z = (cos(v)+sin(v)-1)*(1+sin(v))*log(1-PI*v/10)+7.5*sin(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsSPRINGS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*.898;

	PosO.x = (1-a*cos(v))*cos(u);
	PosO.y = (1-a*cos(v))*sin(u);
	PosO.z = b*(sin(v)+c*u/PI);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsFIGURE8TORUS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*(-PI*2);
    float v = PosO.y*2*PI;

    PosO.x = cos(u)*(c+sin(v)*cos(u)-sin(2*v)*sin(u)/2);
    PosO.y = sin(u)*(c+sin(v)*cos(u)-sin(2*v)*sin(u)/2) ;
    PosO.z = sin(u)*sin(v)+cos(u)*sin(2*v)/2;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsELLIPTICTORUS(float4 PosO: POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2*PI;
    float v = PosO.y*2*PI;

    PosO.x = (c+cos(v))*cos(u);
    PosO.y = (c+cos(v))*sin(u);
    PosO.z = sin(v)+cos(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsCATENOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO,TT);
	
    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2;

    PosO.x = c*cosh(v/c)*cos(u);
    PosO.y = c*cosh(v/c)*sin(u);
    PosO.z = v;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsKIDNEY(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*PI/2;

    PosO.x = cos(u)*(3*cos(v)-cos(3*v));
    PosO.y = sin(u)*(3*cos(v)-cos(3*v));
    PosO.z = 3*sin(v)-sin(3*v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
float4 ps(vs2ps In):COLOR{
    float4 src = tex2D(s0,In.TexCd);
    float4 col1 = (In.colpos*src*col);
    col1.a = 1;
    return mul(col1,tColor);
}


technique Paraboloid {pass P0{VertexShader=compile vs_1_1 vsPARABOLOID();PixelShader=compile ps_2_0 ps();}}
technique Hyperboloid {pass P0{VertexShader=compile vs_1_1 vsHYPERBOLOID();PixelShader=compile ps_2_0 ps();}}
technique LimpetTorus {pass P0{VertexShader=compile vs_1_1 vsLIMPETTORUS();PixelShader=compile ps_2_0 ps();}}
technique Handkerchief {pass P0{VertexShader=compile vs_1_1 vsHANDKERCHIEF();PixelShader=compile ps_2_0 ps();}}
technique Apple {pass P0{VertexShader=compile vs_1_1 vsAPPLE();PixelShader=compile ps_2_0 ps();}}
technique Springs {pass P0{VertexShader=compile vs_1_1 vsSPRINGS();PixelShader=compile ps_2_0 ps();}}
technique Figure8Torus {pass P0{VertexShader=compile vs_1_1 vsFIGURE8TORUS();PixelShader=compile ps_2_0 ps();}}
technique EllipticTorus {pass P0{VertexShader=compile vs_1_1 vsELLIPTICTORUS();PixelShader=compile ps_2_0 ps();}}
technique Catenoid {pass P0{VertexShader=compile vs_1_1 vsCATENOID();PixelShader=compile ps_2_0 ps();}}
technique Kydney {pass P0{VertexShader=compile vs_1_1 vsKIDNEY();PixelShader=compile ps_2_0 ps();}}

