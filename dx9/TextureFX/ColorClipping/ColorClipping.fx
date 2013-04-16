float2 R;
float4 minCol:COLOR <string uiname="Min";> ={0.0,0.0,0.0,1.0};
float4 maxCol:COLOR <string uiname="Max";> ={1.0,1.0,1.0,1.0};
static float4 ColorRange=(maxCol-minCol);
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 ps0(float2 vp:vpos):color{float2 x=(vp+.5)/R;  
	float4 map=tex2D(s0,x);
	map=min(maxCol,map);
	map=max(minCol,map);
	return map;
} 

float4 ps1(float2 vp:vpos):color{float2 x=(vp+.5)/R;   
	float4 map=tex2D(s0,x);
	map=min(maxCol,map);
	map=max(minCol,map);
	map=(map-minCol)/ColorRange;
	return map;
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Clip{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 ps0();}}
technique Convert{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 ps1();}}
