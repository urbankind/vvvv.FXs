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
vs2ps vsBENTHORNS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*PI;
    float v = PosO.y*2*TWOPI;

    PosO.x = (2+cos(u))*(v/3-sin(v));
    PosO.y = (2+cos(u-TWOPI/3))*(cos(v)-1);
    PosO.z = (2+cos(u+TWOPI/3))*(cos(v)-1);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}

//////////////////////////////////////////////////////////////////////
vs2ps vsENNEPERS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO =  mul(PosO,TT);

    float u = PosO.x*2;
    float v = PosO.y*2;

    PosO.x = u-pow(u,3)/3+u*pow(v,2);
    PosO.y = v-pow(v,3)/3+v*pow(u,2);
    PosO.z = pow(u,2)-pow(v,2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}

//////////////////////////////////////////////////////////////////////
vs2ps vsPILLOW(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*TWOPI;
    float v = PosO.y*TWOPI;

    PosO.x = cos(u);
    PosO.y = cos(v);
    PosO.z = sin(u)*sin(v);
    
    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}

//////////////////////////////////////////////////////////////////////
vs2ps vsMONKEYSADDLE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*1.1;
    float v = PosO.y*2*1.1;

    PosO.x = u;
    PosO.y = v;
    PosO.z = pow(u,3)-3*u*pow(v,2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////
vs2ps vsHENNEBURG(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
    
    float u = PosO.x*2;
    float v = PosO.y*2;
    
    PosO.x = 2*sinh(u)*cos(v)-2*sinh(3*u)*cos(3*v)/3;
    PosO.y = 2*sinh(u)*sin(v)+2*sinh(3*u)*sin(3*v)/3;
    PosO.z = 2*cosh(2*u)*cos(2*v);
    
    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////
vs2ps vsSNAIL(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = PosO.x*2*TWOPI;
    float v = PosO.y*2*PI/2;

    PosO.x = u*cos(v)*sin(u);
    PosO.y = u*cos(u)*cos(v);
    PosO.z = -u*sin(v);
    
    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////
vs2ps vsLEMNISCAPE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = (PosO.x+0.5)*PI;
    float v = (PosO.y+0.5)*PI;
    float cosvSqrtAbsSin2u = cos(v)*sqrt(abs(sin(2*u)));

    PosO.x = cosvSqrtAbsSin2u*cos(u);
    PosO.y = cosvSqrtAbsSin2u*sin(u);
    PosO.z = pow(PosO.x,2)-pow(PosO.y,2)+2*PosO.x*PosO.y*pow(tan(v),2);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
///////////////////////////////////////////////////

vs2ps vsTRANGULOID(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
    
    float u = PosO.x*TWOPI ;
    float v = PosO.y*TWOPI ;

    PosO.x = sin(3*u)*2/(2+cos(v));
    PosO.y = (sin(u)+2*sin(2*u))*2/(2+cos(v+TWOPI/a));
    PosO.z = (cos(u)-2*cos(2*u))*(2+cos(v))*((2+cos(v+TWOPI/3))*0.25);

    Out.colpos = length(PosO+lpos);
    Out.PosWVP = mul(PosO,tWVP);
    Out.TexCd  = mul(TexCd,tTex);
    return Out;
}
//////////////////////////////////////////////
vs2ps vsCONE(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);

    float u = (PosO.x+0.5);
    float theta = (PosO.y+0.5)*TWOPI;
    float ar = ((1-u)/1)*a;// * (b * (cos(u*c)+1) + 1);

   PosO.x = (ar*cos(theta))+(u*cos(b*TWOPI-u))*d;
   PosO.y = (ar*sin(theta))+(u*cos(c*TWOPI-u))*d;
   PosO.z = u*d;
	
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

technique BentHorns {pass P0{VertexShader=compile vs_1_1 vsBENTHORNS();PixelShader=compile ps_2_0 ps();}}
technique Ennepers {pass P0{VertexShader=compile vs_1_1 vsENNEPERS();PixelShader=compile ps_2_0 ps();}}
technique Pillow {pass P0{VertexShader=compile vs_1_1 vsPILLOW();PixelShader=compile ps_2_0 ps();}}
technique MonkeySaddle {pass P0{VertexShader=compile vs_1_1 vsMONKEYSADDLE();PixelShader=compile ps_2_0 ps();}}
technique Henneburg {pass P0{VertexShader=compile vs_1_1 vsHENNEBURG();PixelShader=compile ps_2_0 ps();}}
technique Snail {pass P0{VertexShader=compile vs_1_1 vsSNAIL();PixelShader=compile ps_2_0 ps();}}
technique Lemniscape {pass P0{VertexShader=compile vs_1_1 vsLEMNISCAPE();PixelShader=compile ps_2_0 ps();}}
technique Tranguloid {pass P0{VertexShader=compile vs_1_1 vsTRANGULOID();PixelShader=compile ps_2_0 ps();}}
technique Cone {pass P0{VertexShader=compile vs_1_1 vsCONE();PixelShader=compile ps_2_0 ps();}}

