float2 R;
texture t0 <string uiname="Source1";>;
sampler s0=sampler_state{texture=(t0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
texture t1 <string uiname="Source2";>;
sampler s1 = sampler_state{texture=(t1);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
texture t2 <string uiname="Noise Texture";>;
sampler s2 = sampler_state{texture=(t2);AddressU=WRAP;AddressV=WRAP;MIPFILTER=NONE;MINFILTER=LINEAR;MAGFILTER=LINEAR;};

float Time;
float Elapse;

//simple interpolation based on time
float4 psINTERPOLATE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time);
   return lerp(tex2D(s0,x),tex2D(s1,x),t);
}

//fade to black then to next texture
float4 psFADE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time)*2-1;
	return saturate(-t)*tex2D(s0,x)+saturate(t)*tex2D(s1,x);
}

//the image saturates and starts to blend with the next one....then desaturates //
float4 psSATURATE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
       float t = saturate(Elapse*Time);
       float st = t*2-1;
       float4 cl0 = tex2D(s0,x)*2-1;
       cl0 *= 1+saturate(st+1)*4;
       cl0 = saturate(cl0*0.5+0.5);
       float4 cl1 = tex2D(s1,x)*2-1;
       cl1 *= 1+saturate(1-st)*4;
       cl1 = saturate(cl1*0.5+0.5);
       return lerp(cl0,cl1,t);
}

//the image inverts then returns
float4 psINVERT(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time);
   float ts = t * 2 - 1;
   float4 inv = (1-tex2D(s0,x))*t+(1-tex2D(s1,x))*(1-t);
   return saturate(-ts)*tex2D(s0,x)+inv*(1-abs(ts))+saturate(ts)*tex2D(s1,x);
}

//the image is turned into rectangles of block color which change in size
float4 psPIXELLATE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time);
   float tp = t*2;
	 if(tp > 1)
    tp = 2-tp;
	tp *= tp;
	tp *= tp;
	tp = saturate(tp+0.001); 

   float2 disp = frac((x.xy-0.5)/tp)-0.5;
	  	  disp *= -tp;
	t = clamp(t*4-2,-1,1);
	t = t*0.5+0.5;
   return lerp(tex2D(s0,x.xy+disp),tex2D(s1,x.xy+disp),t);
}

//t represents a line that starts at 0 and ends at 1
float4 psWIPEHORIZONTAL(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float s = step(t,x.x);
	return tex2D(s0,x)*s+tex2D(s1,x)*(1-s);
}

float4 psWIPEVERTICAL(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float s = step(t,x.y);
	return tex2D(s0,x)*s+tex2D(s1,x)*(1-s);
}

//the next texture slides in 
float4 psDIAGONALSLIDE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float s = t < 1-x.x || t < 1-x.y;
	return tex2D(s0,x)*s+tex2D(s1,frac(x+t))*(1-s);
}

// vertical lines fade in the next texture
float numLines;
float4 psVERTICALLINES(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time)*2-1;
	float xx = frac(x.x*numLines);
	xx *= 4*(1-xx);
	xx += t;
	return tex2D(s0,x)*saturate(1-xx)+tex2D(s1,x)*saturate(xx);
}

float4 psHORIZONTALLINES(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time)*2-1;
	float y = frac(x.y*numLines);
	y *= 4*(1-y);
	y += t;
	return tex2D(s0,x)*saturate(1-y)+tex2D(s1,x)*saturate(y);
}
 
//stretch the pictures
float4 psSTRETCHHORIZONTAL(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float4 cl = tex2D(s0,float2(x.x/(1-t),x.y))*step(x.x/(1-t),1);
	cl += tex2D(s1,float2(1-(1-x.x)/t,x.y))*step(0,1-(1-x.x)/t);
	return cl;
}

float4 psSTRETCHDIAGONAL(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float4 cl;
   float t = saturate(Elapse*Time);
   float xx = lerp(x.x,x.x/(1-t),x.y);
   float y = lerp(x.y,x.y/(1-t),x.x);
	cl = tex2D(s0, float2(xx, y))*step(xx, 1)*step(y, 1);
	xx = lerp(1-(1-x.x)/t,x.x,x.y);
	y = lerp(1-(1-x.y)/t,x.y,x.x);
	cl += tex2D(s1, float2(xx, y))*step(0,xx)*step(0, y);
   return cl;
}

//this effect is a bit like a blur 
float2 offsets0[4] = {
   -1,  0,
    0,  1,
    1,  0,
    0, -1,
};

float2 offsets1[4] = {
   -1, -1,
   -1,  1,
    1,  1,
    1, -1,
};

float4 psDIVERGE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float tp = t*4*(1-t);
	tp *= tp;
	float4 sum = 0;
	for (int n = 0; n < 4; n++)
{
	sum += tex2D(s0,x.xy+tp*1*offsets0[n])*.25*(1-t);
	sum += tex2D(s1,x.xy+tp*1*offsets1[n])*.25*(t);
}
     return sum;
}

//the images change in accordence to a spiral //
float Exponent;
float Rings;
float SpiraleSpeed;

float4 psSPIRALE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float t = saturate(Elapse*Time);
	float2 crd = x*2-1;
	float ang = atan2(crd.x,crd.y);
	float rad = pow(dot(crd,crd),Exponent);
	float mul = saturate(sin(ang+Rings*rad+t*t*t*10*SpiraleSpeed)*.5-.5+t*2);
	return tex2D(s0,x)*(1-mul)+tex2D(s1,x)*mul;
}

//lerps between two images one color at a time 
float4 tColor;
float4 psCOLOR(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time);
   float t3 = t*tColor.a;
   float4 c0 = tex2D(s0,x);
   float4 c1 = tex2D(s1,x);
   float4 c = 1;
	c.r = c0.r*(1-saturate(t3-tColor.r))+c1.r*saturate(t3-tColor.r);
	c.g = c0.g*(1-saturate(t3-tColor.g))+c1.g*saturate(t3-tColor.g);
	c.b = c0.b*(1-saturate(t3-tColor.b))+c1.b*saturate(t3-tColor.b);
  return c;
}

//distorts the original image gradually by a sine wave and combines it with the next one //
float NumWaves;
float Amplitude;
float4 psSINWAVE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 cl;
	float t = saturate(Elapse*Time);
    float dis0 = sin(x.x*2*3.141*NumWaves);
    float dis1 = sin(x.x*2*3.141*NumWaves+3.141);
	cl  = tex2D(s0, float2(x.x,x.y*(1-t)+dis0*t*Amplitude))*(1-t);
	cl += tex2D(s1, float2(x.x,x.y*t+dis1*(1-t)*Amplitude))*t;
    return cl;
}

//uses noise to blend between images
float4 psSIMPLENOISE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time)*2-1;
   float n = saturate(tex2D(s2,x).a+t);
   return tex2D(s0,x)*(1-n)+tex2D(s1,x)*n;
}

float4 psDISOLVE(float2 vp:vpos):color{float2 x=(vp+.5)/R;
   float t = saturate(Elapse*Time);
   float n = tex2D(s2,x).a;
   float d = step(n,t);
   return tex2D(s0,x)*(1-d)+tex2D(s1,x)*d;
}


void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}

technique Interpolate 		{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psINTERPOLATE();}}
technique Fade 				{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psFADE();}}
technique Saturate 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSATURATE();}}
technique Invert 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psINVERT();}}
technique Pixelate 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psPIXELLATE();}}
technique WipeHorizontal 	{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psWIPEHORIZONTAL();}}
technique WipeVertical 		{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psWIPEVERTICAL();}}
technique DiagonalSlide 	{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psDIAGONALSLIDE();}}
technique VerticalLines 	{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psVERTICALLINES();}}
technique HorizontalLines 	{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psHORIZONTALLINES();}}
technique StretchHorizontal {pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSTRETCHHORIZONTAL();}}
technique StretchDiagonal 	{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSTRETCHDIAGONAL();}}
technique Diverge 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psDIVERGE();}}
technique Spiralem 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSPIRALE();}}
technique Colored 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psCOLOR();}}
technique SineWave 			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSINWAVE();}}
technique SimpleNoise 		{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psSIMPLENOISE();}}
technique Disolve			{pass P0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 psDISOLVE();}}
