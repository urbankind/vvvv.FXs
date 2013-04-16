float2 R;
float Alpha = 1;

texture tex0;
sampler Samp=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

// Blurs using a 3x3 filter kernel
float4 psBLUR3x3(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	// TOP ROW
  float4 s11 = tex2D(Samp, x + float2(-1/R.x,-1/R.y));    // LEFT
  float4 s12 = tex2D(Samp, x + float2(0,-1/R.y));         // MIDDLE
  float4 s13 = tex2D(Samp, x + float2(1/R.x,-1/R.y));     // RIGHT
  // MIDDLE ROW
  float4 s21 = tex2D(Samp, x + float2(-1/R.x,0));         // LEFT
  float4 col = tex2D(Samp, x);                            // DEAD CENTER
  float4 s23 = tex2D(Samp, x + float2(-1/R.x,0));         // RIGHT
  // LAST ROW
  float4 s31 = tex2D(Samp, x + float2(-1/R.x,1/R.y));     // LEFT
  float4 s32 = tex2D(Samp, x + float2(0,1/R.y));          // MIDDLE
  float4 s33 = tex2D(Samp, x + float2(1.0f /R.x,1/R.y));  // RIGHT
  // Average the color with surrounding samples
  col = (col + s11 + s12 + s13 + s21 + s23 + s31 + s32 + s33) / 9;
  col.a *= Alpha;
  return col;
}

// Blurs using a 5x5 filter kernel
float4 psBLUR5x5(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  return (
    tex2D(Samp, x + float2(-2/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(0,-2/R.y)) +
    tex2D(Samp, x + float2(1/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(2/R.x,-2/R.y)) +
 
    tex2D(Samp, x + float2(-2/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(0,-1/R.y)) +
    tex2D(Samp, x + float2(1/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(2/R.x,-1/R.y)) +
 
    tex2D(Samp, x + float2(-2/R.x,0)) +
    tex2D(Samp, x + float2(-1/R.x,0)) +
    tex2D(Samp, x + float2(0,0)) +
    tex2D(Samp, x + float2(1/R.x,0)) +
    tex2D(Samp, x + float2(2/R.x,0)) +
 
    tex2D(Samp, x + float2(-2/R.x,1/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,1/R.y)) +
    tex2D(Samp, x + float2(0,1/R.y)) +
    tex2D(Samp, x + float2(1/R.x,1/R.y)) +
    tex2D(Samp, x + float2(2/R.x,1/R.y)) +
 
    tex2D(Samp, x + float2(-2/R.x,2/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,2/R.y)) +
    tex2D(Samp, x + float2(0,2/R.y)) +
    tex2D(Samp, x + float2(1/R.x,2/R.y)) +
    tex2D(Samp, x + float2(2/R.x,2/R.y))) / 25;
}

// Blurs using a 7x7 filter kernel
float4 psBLUR7x7(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  return (
    tex2D(Samp, x + float2(-3/R.x,-3/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,-3/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,-3/R.y)) +
    tex2D(Samp, x + float2(0,-3/R.y)) +
    tex2D(Samp, x + float2(1/R.x,-3/R.y)) +
    tex2D(Samp, x + float2(2/R.x,-3/R.y)) +
    tex2D(Samp, x + float2(3/R.x,-3/R.y)) +
 
    tex2D(Samp, x + float2(-3/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(0,-2/R.y)) +
    tex2D(Samp, x + float2(1/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(2/R.x,-2/R.y)) +
    tex2D(Samp, x + float2(3/R.x,-2/R.y)) +
 
    tex2D(Samp, x + float2(-3/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(0,-1/R.y)) +
    tex2D(Samp, x + float2(1/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(2/R.x,-1/R.y)) +
    tex2D(Samp, x + float2(3/R.x,-1/R.y)) +
 
    tex2D(Samp, x + float2(-3/R.x,0)) +
    tex2D(Samp, x + float2(-2/R.x,0)) +
    tex2D(Samp, x + float2(-1/R.x,0)) +
    tex2D(Samp, x + float2(0,0)) +
    tex2D(Samp, x + float2(1/R.x,0)) +
    tex2D(Samp, x + float2(2/R.x,0)) +
    tex2D(Samp, x + float2(3/R.x,0)) +
 
    tex2D(Samp, x + float2(-3/R.x,1/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,1/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,1/R.y)) +
    tex2D(Samp, x + float2(0,1/R.y)) +
    tex2D(Samp, x + float2(1/R.x,1/R.y)) +
    tex2D(Samp, x + float2(2/R.x,1/R.y)) +
    tex2D(Samp, x + float2(3/R.x,1/R.y)) +
 
    tex2D(Samp, x + float2(-3/R.x,2/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,2/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,2/R.y)) +
    tex2D(Samp, x + float2(0,2/R.y)) +
    tex2D(Samp, x + float2(1/R.x,2/R.y)) +
    tex2D(Samp, x + float2(2/R.x,2/R.y)) +
    tex2D(Samp, x + float2(3/R.x,2/R.y)) +
 
    tex2D(Samp, x + float2(-3/R.x,3/R.y)) +
    tex2D(Samp, x + float2(-2/R.x,3/R.y)) +
    tex2D(Samp, x + float2(-1/R.x,3/R.y)) +
    tex2D(Samp, x + float2(0,3/R.y)) +
    tex2D(Samp, x + float2(1/R.x,3/R.y)) +
    tex2D(Samp, x + float2(2/R.x,3/R.y)) +
    tex2D(Samp, x + float2(3/R.x,3/R.y))) / 49;
}


void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Blur3x3 {pass P0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psBLUR3x3();}}
technique Blur5x5 {pass P0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psBLUR5x5();}}
technique Blur7x7 {pass P0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psBLUR7x7();}}
