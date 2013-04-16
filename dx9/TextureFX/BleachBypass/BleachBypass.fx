float2 R;
float Opacity=1;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);mipfilter=NONE;minfilter=LINEAR;magfilter=LINEAR;};
float4 p0(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 map=tex2D(s0,x);
    float3 lumC=float4(0.25,0.65,0.1,0);
	float lum=dot(lumC,map.rgb);
	float3 blend=lum.rrr;
    float L=min(1,max(0,10*(lum-0.45)));
    float3 result1=2*map.rgb*blend;
    float3 result2=1-2*(1-blend)*(1-map.rgb);
	float3 newColor=lerp(result1,result2,L);
    float A2=Opacity*map.a;
    float3 mixRGB=A2*newColor.rgb;
    mixRGB +=((1-A2)*map.rgb);
	return float4(mixRGB,map.a);
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Bleach{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p0();}}
