//transforms
float4x4 tWVP:WORLDVIEWPROJECTION;

//material properties
float4 col:COLOR=1;
float4x4 tColor <string uiname="Color Transform";>;
float3 freq;
float amp;

//sampler
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float4 colpos:TEXCOORD1;
};

vs2ps VS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0,float3 Normal:NORMAL){
    vs2ps Out = (vs2ps)0;    
    float f = sin(Normal.x*freq.x)*sin(Normal.y*freq.y)*sin(Normal.z*freq.z);    
	PosO.z += Normal.z*freq.z*amp*f;
    PosO.x += Normal.x*freq.x*amp*f;
    PosO.y += Normal.y*freq.y*amp*f;   
    Out.PosWVP=mul(PosO,tWVP);
    Out.colpos=length(PosO);
	Out.TexCd=mul(TexCd,tTex);
    return Out;
}

float4 ps0(vs2ps In):COLOR {
	float4 src=tex2D(s0,In.TexCd);
	float4 col1=(In.colpos*src*col);
	col1.a=1 ;       
    return mul(col1,tColor);
}

technique Tsphere{pass P0{Wrap0=U;VertexShader=compile vs_2_0 VS();PixelShader=compile ps_2_0 ps0();}}
