//transforms
float4x4 tWVP:WORLDVIEWPROJECTION;

#include "inoise4D.fxh"

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
};

vs2ps vs(float4 Pos:POSITION,float4 TexCd:TEXCOORD0){
	vs2ps Out = (vs2ps)0;
    Out.Pos = mul(Pos,tWVP);
	Out.TexCd = mul(Pos,tTex);
    return Out;
}

float4 ps0(vs2ps In):COLOR{
 	float4 map=ridgedmf(In.TexCd,octaves,lacunarity,gain,offset);
 	map.a=1;
 	return map;
}        
float4 ps1(vs2ps In):COLOR{
	float4 map=turbulence(In.TexCd,octaves,gain,offset);
	map.a=1;
	return map;
}
float4 ps2(vs2ps In):COLOR{
	float4 map=fBm(In.TexCd,octaves,lacunarity,gain);
	map.a=1;
	return map;
}

technique MultifractalNoise{pass P0{VertexShader=compile vs_3_0 vs();PixelShader=compile ps_3_0 ps0();}}
technique Turbulence{pass P0{VertexShader=compile vs_3_0 vs();PixelShader=compile ps_3_0 ps1();}}
technique FractalSum{pass P0{VertexShader=compile vs_3_0 vs();PixelShader=compile ps_3_0 ps2();}}


