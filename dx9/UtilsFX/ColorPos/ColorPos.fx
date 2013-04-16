//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;

//material properties
float4 colorpos;
float alpha;

//sampler
texture tex0;
sampler s0= sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
    float4 col:TEXCOORD1;
};
vs2ps vs(float4 vp:POSITION,float4 uv:TEXCOORD0,float4 cpos:TEXCOORD1){
    vs2ps Out=(vs2ps)0;
    Out.Pos=mul(vp,tWVP);
    Out.col=vp+colorpos;
    Out.TexCd=mul(uv,tTex);
    return Out;
}

float4 p0(vs2ps In):COLOR{
    float4 col=In.col; 
	col.a = alpha;
    return col;
}
technique TSimpleShader{pass P0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 p0();}
}

