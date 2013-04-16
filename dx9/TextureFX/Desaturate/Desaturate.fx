float2 R;
float desaturate <float uimin=0.0;float uimax=1.0;> =.5;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 desatPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;     
    float3 map=tex2D(s0,x).xyz;
    float3 grayer=float3(0.3,0.59,0.11);
    float3 gray=dot(grayer,map).xxx;
    float3 result=lerp(map,gray,desaturate);
    return float4(result,1);
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique main{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 desatPS();}}
