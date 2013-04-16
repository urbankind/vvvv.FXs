float2 R;
float NPixels <string UIName="Steps";float UIMin=1.0;float UIMax=5.0;> =1.5;
float Threshhold <float UIMin = 0.01f;float UIMax=0.5;> =.2;
texture t0 <string uiname="Texture";>;
sampler s0=sampler_state {Texture=(t0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};

float getGray(float4 c){return(dot(c.rgb,((0.33333).xxx)));
}

float4 p0(float2 vp:vpos):color{float2 x=(vp+.5)/R; 
	float2 ox = float2(NPixels/R.x,0);
	float2 oy = float2(0,NPixels/R.y);
	float2 PP = x.xy - oy;
	float4 CC = tex2D(s0,PP-ox); 
	float g00 = getGray(CC);
	CC = tex2D(s0,PP);    
	float g01 = getGray(CC);
	CC = tex2D(s0,PP+ox); 
	float g02 = getGray(CC);
			PP = x.xy;
			CC = tex2D(s0,PP-ox); 
	float g10 = getGray(CC);
	CC = tex2D(s0,PP);    
	float g11 = getGray(CC);
	CC = tex2D(s0,PP+ox); 
	float g12 = getGray(CC);
	PP = x.xy + oy;
	CC = tex2D(s0,PP-ox); 
	float g20 = getGray(CC);
	CC = tex2D(s0,PP);    
	float g21 = getGray(CC);
	CC = tex2D(s0,PP+ox); 
	float g22 = getGray(CC);
	float K00 = -1;
	float K01 = -2;
	float K02 = -1;
	float K10 = 0;
	float K11 = 0;
	float K12 = 0;
	float K20 = 1;
	float K21 = 2;
	float K22 = 1;
	float sx = 0;
	float sy = 0;
	sx += g00 * K00;
	sx += g01 * K01;
	sx += g02 * K02;
	sx += g10 * K10;
	sx += g11 * K11;
	sx += g12 * K12;
	sx += g20 * K20;
	sx += g21 * K21;
	sx += g22 * K22; 
	sy += g00 * K00;
	sy += g01 * K10;
	sy += g02 * K20;
	sy += g10 * K01;
	sy += g11 * K11;
	sy += g12 * K21;
	sy += g20 * K02;
	sy += g21 * K12;
	sy += g22 * K22; 
	float dist=sqrt(sx*sx+sy*sy);
	float result=1;
	if (dist>Threshhold) {result = 0;}
	return result.xxxx;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique EdgeDetect{pass pp0{VertexShader=compile vs_1_1 vs2d();PixelShader=compile ps_3_0 p0();}
}

