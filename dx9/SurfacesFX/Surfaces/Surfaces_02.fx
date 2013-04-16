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
vs2ps vsSTEINBACHSCREW(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*8;
    float v = PosO.y*12.5;

	PosO.x = a*(u)*cos(v);
	PosO.y = a*(u)*sin(v);
	PosO.z = a*(v)*cos(u);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsSINE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
	
    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = a*sin(u);
    PosO.y = a*sin(v);
    PosO.z = a*sin(u+v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsEIGHT(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*PI/2;

    PosO.x = cos(u)*sin(2*v);
    PosO.y = sin(u)*sin(2*v);
    PosO.z = sin(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsCORKSCREW(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO, TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y* 2*TWOPI;

    PosO.x = a*cos(u)*cos(v);
    PosO.y = a*sin(u)*cos(v);
    PosO.z = a*sin(v)+b*u;

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsROMAN2BOY(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*PI;
    float v = PosO.y*PI;

	PosO.x = (pow(2,0.5)*cos(2*u)*pow(cos(v),2)+cos(u)*sin(2*v))/(2-a*pow(2,.5)*sin(3*u)*sin(2*v));
	PosO.y = (pow(2,0.5)*sin(2*u)*pow(cos(v),2)+sin(u)*sin(2*v))/(2-a*pow(2,.5)*sin(3*u)*sin(2*v));
	PosO.z = (3*pow(cos(v),2))/(2-a*pow(2,.5)*sin(3*u)*sin(2*v));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsTWISTEDPIPE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO, TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

	PosO.x = cos(v)*(2+cos(u))/sqrt(1+pow(sin(v),2));
	PosO.y = sin(v+TWOPI/3)*(2+cos(u+TWOPI/3))/sqrt(1+pow(sin(v),2));
	PosO.z = sin(v-TWOPI/3)*(2+cos(u-TWOPI/3))/sqrt(1+pow(sin(v),2));

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsBOHEMIANDOME(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = a*cos(u);
    PosO.y = a*sin(u)+b*cos(v);
    PosO.z = c*sin(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsFOLIUM(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = cos(u)*(2*v/PI-tanh(v));
    PosO.y = cos(u+TWOPI/3)/cosh(v);
    PosO.z = cos(u-TWOPI/3)/cosh(v);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsASTROIDALELLIPSOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
    
    float u = PosO.x*PI;
    float v = PosO.y*TWOPI;

    PosO.x = pow(cos(u)*cos(v),3);
    PosO.y = pow(sin(u)*cos(v),3);
    PosO.z = pow(sin(v),3);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////////////////
vs2ps vsTRIAXIALHEXATORUS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*PI;
    float v = PosO.y*2*TWOPI;

	PosO.x = sin(u)/(sqrt(2)+cos(v));
	PosO.y = sin(u+TWOPI/3)/(sqrt(2)+cos(v+TWOPI/3));
	PosO.z = cos(u-TWOPI/3)/(sqrt(2)+cos(v-TWOPI/3));

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

technique SteinbachScrew {pass P0{VertexShader=compile vs_1_1 vsSTEINBACHSCREW();PixelShader=compile ps_2_0 ps();}}
technique Sine {pass P0{VertexShader=compile vs_1_1 vsSINE();PixelShader=compile ps_2_0 ps();}}
technique Eight {pass P0{VertexShader=compile vs_1_1 vsEIGHT();PixelShader=compile ps_2_0 ps();}}
technique Corkscrew {pass P0{VertexShader=compile vs_1_1 vsCORKSCREW();PixelShader=compile ps_2_0 ps();}}
technique Roman2Boy {pass P0{VertexShader=compile vs_1_1 vsROMAN2BOY();PixelShader=compile ps_2_0 ps();}}
technique TwistedPipe {pass P0{VertexShader=compile vs_1_1 vsTWISTEDPIPE();PixelShader=compile ps_2_0 ps();}}
technique BohemianDome {pass P0{VertexShader=compile vs_1_1 vsBOHEMIANDOME();PixelShader=compile ps_2_0 ps();}}
technique Folium {pass P0{VertexShader=compile vs_1_1 vsFOLIUM();PixelShader=compile ps_2_0 ps();}}
technique AstroidalEllipsoid {pass P0{VertexShader=compile vs_1_1 vsASTROIDALELLIPSOID();PixelShader=compile ps_2_0 ps();}}
technique TriaxialHexatorus {pass P0{VertexShader=compile vs_1_1 vsTRIAXIALHEXATORUS();PixelShader=compile ps_2_0 ps();}}

