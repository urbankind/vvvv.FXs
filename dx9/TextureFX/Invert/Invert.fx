float2 R;
texture tex0,tex1;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
sampler s1=sampler_state{Texture=(tex1);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psINVERT(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 col = tex2D(s0,x);
    float4 col2 = tex2D(s1,x);
    float4 col3 = {((1,1,1)-col.rgb),1};
    float4 col4 = {((1,1,1)-col2.rgb),1};
    float4 col5 = (col*col4);
    float4 col6 = (col3*col2);
    float4 col7 = col5 + col6;
    return col7;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Invert {pass p0{VertexShader=compile vs_1_0 vs2d();PixelShader=compile ps_3_0 psINVERT();}}

