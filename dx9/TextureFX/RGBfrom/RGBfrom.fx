float2 R;

texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

#include "ColorSpaces.fxh"

float4 psFromCMY(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 cmy = tex2D(s0,x);
	return float4(cmy2rgb(cmy),cmy.w);
}  

float4 psFromCMYK(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 cmyk = tex2D(s0,x);
	return float4(cmyk2rgb(cmyk),1);
}  

float4 psFromHSV(float2 vp:vpos):color{float2 x=(vp+.5)/R; 
	float4 hsva = tex2D(s0,x);
	return float4(hsv2rgb(hsva.xyz),hsva.w);
} 

float4 psFromYUV(float2 vp:vpos):color{float2 x=(vp+.5)/R;   
	float4 yuva = tex2D(s0,x) - float4(0,.5,.5,0);
	return float4(yuv2rgb(yuva.xyz),yuva.w);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique fromCMY {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psFromCMY();}}
technique fromCMYK {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psFromCMYK();}}
technique fromHSV {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psFromHSV();}}
technique fromYUV {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psFromYUV();}}
