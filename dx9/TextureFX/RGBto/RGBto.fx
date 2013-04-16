float2 R;

texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

#include "ColorSpaces.fxh"

float4 psToCMY(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 rgba = tex2D(s0,x);
	return float4(rgb2cmy(rgba.xyz),rgba.w);
}  

float4 psToCMYK(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float3 rgb = tex2D(s0,x).xyz;
	return rgb2cmyk(rgb);
}  

float4 psToHSV(float2 vp:vpos):color{float2 x=(vp+.5)/R; 
	float4 rgba = tex2D(s0,x);
	return float4(rgb2hsv(rgba.xyz),rgba.w);
} 

float4 psToYUV(float2 vp:vpos):color{float2 x=(vp+.5)/R;   
	float4 rgba = tex2D(s0,x) - float4(0,.5,.5,0);
	return float4(rgb2yuv(rgba.xyz)+float3(0,.5,.5),rgba.w);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique toCMY {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psToCMY();}}
technique toCMYK {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psToCMYK();}}
technique toHSV {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psToHSV();}}
technique toYUV {pass Convert {VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psToYUV();}}
