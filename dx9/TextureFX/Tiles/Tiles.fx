float2 R;
texture tex0;
sampler s0=sampler_state {Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float NumTiles <string UIName="# Tiles";float UIMin=1.0;float UIMax=100.0;> =20;
float Threshhold <string UIName="Edge Width";float UIMin=0.0;float UIMax=2.0;> =.03;
float3 EdgeColor = {0.7,0.7,0.7};

float4 psTILES(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float size = 1.0/NumTiles;
    float2 Pbase = x- fmod(x,size.xx);
    float2 PCenter = Pbase + (size/2.0).xx;
    float2 st = (x - Pbase)/size;
    float4 c1 = (float4)0;
    float4 c2 = (float4)0;
    float4 invOff = float4((1-EdgeColor),1);
    if (st.x > st.y) { c1 = invOff; }
    float threshholdB =  1.0 - Threshhold;
    if (st.x > threshholdB) { c2 = c1; }
    if (st.y > threshholdB) { c2 = c1; }
    float4 cBottom = c2;
    c1 = (half4)0;
    c2 = (half4)0;
    if (st.x > st.y) { c1 = invOff; }
    if (st.x < Threshhold) { c2 = c1; }
    if (st.y < Threshhold) { c2 = c1; }
    float4 cTop = c2;
    float4 tileColor = tex2D(s0,PCenter);    
    float4 result = tileColor + cTop - cBottom;
    return result;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Tiles {pass p0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psTILES();}}
