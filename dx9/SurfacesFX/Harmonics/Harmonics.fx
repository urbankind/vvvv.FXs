//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 TT ;

//material properties
float3 lpos <String uiname="Light Position";>;
float4 col:COLOR <String uiname="Color";> =1;
float4x4 tColor <string uiname="Color Transform";>;

float a;
float b;
float c;
float d;
float e;
float f;
float g;
float h;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float4 colpos:TEXCOORD1;
};

vs2ps VS(float4 Pos:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out =(vs2ps)0;
    Pos= mul(Pos,TT);

    float r=0;
    float phi=Pos.x;
    float theta=Pos.y;
    
   r +=pow(sin(a*phi),(double)b);
   r +=pow(cos(c*phi),(double)d);
   r +=pow(sin(e*theta),(double)f);
   r +=pow(cos(g*theta),(double)h);
    
    Pos.x=r*sin(phi)*cos(theta);
    Pos.y=r*cos(phi);
    Pos.z=r*sin(phi)*sin(theta);

    Out.colpos=length(Pos+lpos);
    Out.PosWVP=mul(Pos,tWVP);
    Out.TexCd=mul(TexCd,tTex);
    return Out;
}

float4 PS(vs2ps In):COLOR{
	float4 src=tex2D(Samp,In.TexCd);
	float4 col1=(In.colpos*src*col);
	col1.a=1;     
    return mul(col1,tColor);
}

technique Harmonics{pass P0{Wrap0=U;VertexShader=compile vs_2_0 VS();PixelShader=compile ps_2_0 PS();}}
