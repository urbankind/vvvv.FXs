float2 R;
//texture
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);AddressU=BORDER;AddressV=BORDER;MipFilter=POINT;MinFilter=POINT;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float Threshold <float uimin=0.0;float uimax=1.0;> =0;
float GaussSteepness =2;
float GaussFactor =1;

float4 psGAUSSTHRESHOLD(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float4 col = tex2D(Samp,x);
   float4 outCol = float4 (0,0,0,1);
   
   outCol.r = GaussFactor*pow((2.7182),(-pow((col.r-Threshold),2)/GaussSteepness));
   outCol.g = GaussFactor*pow((2.7182),(-pow((col.g-Threshold),2)/GaussSteepness));
   outCol.b = GaussFactor*pow((2.7182),(-pow((col.b-Threshold),2)/GaussSteepness));

  if (col.r < outCol.r && col.g < outCol.g && col.b < outCol.b) col.rgb =0;
   else col.rgb =1;
  return col;
}

float4 psTHRESHOLD(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float4 col = tex2D(Samp,x);
   if (col.r < Threshold && col.g < Threshold && col.b < Threshold) col.rgb =0;
    else col.rgb =1;
   return col;
}

float4 psSMOOTHTHRESHOLD(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float4 col = tex2D(Samp,x);
   if (col.r < Threshold && col.g < Threshold && col.b < Threshold) col.rgb =0;
    else col.rgb = lerp(saturate(Threshold+col.rgb),1,0);
   return col;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique GaussThreshold {pass P0 {VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psGAUSSTHRESHOLD();}}
technique SmoothThreshold {pass P0 {VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSMOOTHTHRESHOLD();}}
technique SimpleThreshold {pass P0 {VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psTHRESHOLD();}}


 