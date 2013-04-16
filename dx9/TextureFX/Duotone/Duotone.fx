float2 R;
float4 hcol:COLOR <string UIName="High Color";> =1;
float4 lcol:COLOR <string UIName="Low Color";> ={0.0,0.0,0.0,1.0};
float threshold;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 ps(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 map=tex2D(s0,x);
    float4 dcol=(map.r+map.g+map.b/3.0);
    dcol=(map.r<threshold)?lcol:hcol;
    dcol.a=map.a;
   return dcol;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Duotone{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 ps();}}
