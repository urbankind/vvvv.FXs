float2 R;
float2 center;
float p;
float m;

texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psTWIRL(float2 vp:vpos):color{float2 x=(vp+.5)/R;  
	x=2*x-1;x+=center;
	float r=length(x);
	float phi=atan2(x.y,x.x);
	phi=phi+(1-smoothstep(-p,p,r))*m;
	x.x=r*cos(phi);
	x.y=r*sin(phi);
	x-=center;x=x/2+.5;
	float4 map=tex2D(s0,x);
    return map;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique twirl{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psTWIRL();}}
