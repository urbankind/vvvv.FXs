float2 R;
float3 GrayConv <string UIName="Grayscale Conversion Factor";> = {0.25,0.65,.1};
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};
texture GradientTex;
sampler s1=sampler_state{texture=(GradientTex);AddressU=CLAMP;AddressV=CLAMP;MIPFILTER=LINEAR;MINFILTER=LINEAR;MAGFILTER=LINEAR;};

float4 redGradPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;     
	float4 map=tex2D(s0,x);
	return float4(tex2D(s1,float2(map.x,0)).xyz,map.w);
} 

float4 grnGradPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;     
	float4 map=tex2D(s0,x);
	return float4(tex2D(s1,float2(map.y,0)).xyz,map.w);
}

float4 bluGradPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;    
	float4 map=tex2D(s0,x);
	return float4(tex2D(s1,float2(map.z,0)).xyz,map.w);
}

float4 gryGradPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;     
	float4 map=tex2D(s0,x);
	float n=dot(map.xyz,GrayConv);
	return float4(tex2D(s1,float2(n,0)).xyz,map.w);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Red{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 redGradPS();}}
technique Green{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 grnGradPS();}}
technique Blue{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 bluGradPS();}}
technique Grey{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 gryGradPS();}}
