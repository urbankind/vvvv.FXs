float2 R;
float nColors <string UIName="# of colors";float UIMin=2.0;float UIMax=255.0;> =4;
float gamma <string UINam ="Gamma";float UIMin=0.1;float UIMax=10.0;> =1;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psPOSTER(float2 vp:vpos):color{float2 x=(vp+.5)/R; 
	float4 map = tex2D(s0,x);
	float3 tc = map.xyz;
	tc = pow(tc,gamma);
	tc = tc*nColors;
	tc = floor(tc);
	tc = tc/nColors;
	tc = pow(tc,1/gamma);
	return float4(tc,map.w);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique posterize {pass p0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psPOSTER();}
}
