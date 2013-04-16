float2 R;
float2 center;
float p;
float m;

texture tex0 <string uiname="Texture";>;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psSTRETCH(float2 vp:vpos):color{float2 x=(vp+.5)/R;  
	x=2*x-1;x+=center;
	float2 s=sign(x);
	x=abs(x);
	x=.5*x+.5*smoothstep(p,m,x+center)*x;
	x= s*x;
	x-=center;x=x/2+.5;
	float4 map=tex2D(s0,x);
    return map;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique stretch{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psSTRETCH();}}
