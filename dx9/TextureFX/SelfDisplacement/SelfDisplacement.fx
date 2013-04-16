float2 R;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float Displacement <float UIMin=0.0;float UIMax=1.0;> =0.01;

float4 dispPS(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float2 disp = Displacement*(tex2D(s0,x));
    float4 map = tex2D(s0,x+disp);
    return map;
} 

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique deformTexture {pass TexturePass{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 dispPS();}}
