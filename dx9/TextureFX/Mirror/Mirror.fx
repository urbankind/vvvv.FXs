float2 R;
float2 center;
float p;
float m;

texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psMIRROR(float2 vp:vpos):color{float2 x=(vp+.5)/R;  
	x=2*x-1;x +=center;
	x.x=x.x*sign(x.x);
	x-=center;x=x/2+.5;
	float4 map=tex2D(s0,x);
    return map;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique mirror{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psMIRROR();}}
