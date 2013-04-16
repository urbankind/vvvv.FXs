float2 R;
float fade <float UIMin=0.0;float UIMax=1.0;> =1;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};
texture gradientTex;
sampler s1=sampler_state{texture=<gradientTex>;MIPFILTER=LINEAR;MINFILTER=LINEAR;MAGFILTER=LINEAR;};

float4 ps0(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float3 map=tex2D(s0,x).xyz;
	float R=tex2D(s1,float2(map.x,0)).x;
	float G=tex2D(s1,float2(map.y,0)).y;
	float B=tex2D(s1,float2(map.z,0)).z;
	float3 newcol=float3(R,G,B);
	float3 result=lerp(map,newcol,fade);
	return float4(result,1);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Clamp{pass pp0{AddressU[0]=CLAMP;AddressV[0]=CLAMP;vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 ps0();}}
