float2 R;
float offset;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=POINT;MinFilter=POINT;MagFilter=LINEAR;AddressU=WRAP;AddressV=WRAP;};
#include "ColorSpace.fxh"
float RGBtoGray(float3 RGB){return dot(RGB,float3(0.299,0.587,0.114));
}

float4 p0(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  float4 col=tex2D(s0,x);
  float gray=RGBtoGray(col);
  gray = frac(gray+offset);
  float3 hsv=float3(gray, 1, 1);
  col.rgb=HSVtoRGB(hsv);
  return col;
}

float4 p1(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  float4 col=tex2D(s0,x);
  float3 hsv=RGBtoHSV(col);
  col.rgb=frac(RGBtoGray(hsv)+offset);
  return col;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Gray2HSV{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p0();}}
technique HSV2Gray{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p1();}}
