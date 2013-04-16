//Same as "edgeDetect" but with the kernel values
float2 R;
float NPixels <string UIName="Steps";float UIMin=1.0;float UIMax =5.0;> =1.5;
float Threshhold <float UIMin=0.01;float UIMax=0.5;> =.2;
texture t0 <string uiname="Texture";>;
sampler s0=sampler_state {Texture=(t0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};

struct vs2ps{
   	float4 Position:POSITION;
    float2 UV00:TEXCOORD0;
    float2 UV01:TEXCOORD1;
    float2 UV02:TEXCOORD2;
    float2 UV10:TEXCOORD3;
    float2 UV12:TEXCOORD4;
    float2 UV20:TEXCOORD5;
    float2 UV21:TEXCOORD6;
    float2 UV22:TEXCOORD7;
};

vs2ps edgeVS(float3 Position:POSITION,float2 TexCoord:TEXCOORD0){
    vs2ps OUT;  
	Position.xy*=2;TexCoord+=.5/R;
	OUT.Position = float4(Position,1);
	float2 off = float2(R.xy);
    float2 ctr = float2(TexCoord.xy+off); 
	float2 ox = float2(NPixels/R.x,0);
	float2 oy = float2(0,NPixels/R.y);
	OUT.UV00 = ctr - ox - oy;
	OUT.UV01 = ctr - oy;
	OUT.UV02 = ctr + ox - oy;
	OUT.UV10 = ctr - ox;
	OUT.UV12 = ctr + ox;
	OUT.UV20 = ctr - ox + oy;
	OUT.UV21 = ctr + oy;
	OUT.UV22 = ctr + ox + oy;
    return OUT;
}

float getGray(float4 c){return(dot(c.rgb,((0.33333).xxx)));
}

float4 edgeDetectPS(vs2ps In):color{
	float4 CC;
	CC = tex2D(s0,In.UV00); float g00 = getGray(CC);
	CC = tex2D(s0,In.UV01); float g01 = getGray(CC);
	CC = tex2D(s0,In.UV02); float g02 = getGray(CC);
	CC = tex2D(s0,In.UV10); float g10 = getGray(CC);
	CC = tex2D(s0,In.UV12); float g12 = getGray(CC);
	CC = tex2D(s0,In.UV20); float g20 = getGray(CC);
	CC = tex2D(s0,In.UV21); float g21 = getGray(CC);
	CC = tex2D(s0,In.UV22); float g22 = getGray(CC);
	float sx = 0;
	sx -= g00;
	sx -= g01*2;
	sx -= g02;
	sx += g20;
	sx += g21*2;
	sx += g22;
	float sy = 0;
	sy -= g00;
	sy += g02;
	sy -= g10*2;
	sy += g12*2;
	sy -= g20;
	sy += g22;
	float dist =(sx*sx+sy*sy);
	float result = 1;
	if (dist>Threshhold*Threshhold) {result = 0;}
	return result.xxxx;
}

technique Main {pass p0{VertexShader = compile vs_1_1 edgeVS();PixelShader = compile ps_2_0 edgeDetectPS();}
}
