float2 R;
texture t0 <string uiname="Texture";>;
sampler s0=sampler_state{Texture=(t0);MipFilter=LINEAR; MinFilter=LINEAR;MagFilter=LINEAR;};
float Base <float uimin=-1.0;float uimax=1.0;> =0;
float Factor <float uimin=-1.0;float uimax=5.0;> =1;

float4 psCONTRAST(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 outCol = tex2D(s0,x+(1/R));
    //outCol.r = .5+Factor*(outCol.r-.5); 
    //outCol.g = .5+Factor*(outCol.g-.5); 
    //outCol.b = .5+Factor*(outCol.b-.5); 
    outCol = .5+Base+Factor*(outCol-.5+Base); 
    clamp(outCol,0,1);
   return outCol;
}

float4 psGAMMA(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 outCol = tex2D(s0,x+(1/R));
    //Gamma Correction (Factor) and Gain (Base)
    outCol = pow((outCol*-1)+Base,1/Factor);
    clamp(outCol,0,1);
   return outCol;
}
void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Contrast {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psCONTRAST();}}
technique Gamma {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psGAMMA();}}

