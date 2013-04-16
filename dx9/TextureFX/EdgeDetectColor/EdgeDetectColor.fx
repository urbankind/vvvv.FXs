float2 R;
float NPixels <string UIName="Steps";float UIMin=1.0;float UIMax=5.0;> = 1.5;
float Threshhold <float UIMin=0.01;float UIMax=0.5;> =.2;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

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

float4 edgeDetectPS(vs2ps IN):COLOR {
	float4 cc00 = tex2D(s0,IN.UV00);
	float4 cc01 = tex2D(s0,IN.UV01);
	float4 cc02 = tex2D(s0,IN.UV02);
	float4 cc10 = tex2D(s0,IN.UV10);
	float4 cc12 = tex2D(s0,IN.UV12);
	float4 cc20 = tex2D(s0,IN.UV20);
	float4 cc21 = tex2D(s0,IN.UV21);
	float4 cc22 = tex2D(s0,IN.UV22);
	float4 sx = 0;
	sx -= cc00;
	sx -= cc01 * 2;
	sx -= cc02;
	sx += cc20;
	sx += cc21 * 2;
	sx += cc22;
	float4 sy = 0;
	sy -= cc00;
	sy += cc02;
	sy -= cc10 * 2;
	sy += cc12 * 2;
	sy -= cc20;
	sy += cc22;
	float4 dist = (sx*sx+sy*sy);	// per-channel
	float4 result = 1;
	result = float4((dist.x<=Threshhold*Threshhold),(dist.y<=Threshhold*Threshhold),(dist.z<=Threshhold*Threshhold),(dist.w<=Threshhold*Threshhold));
	return 1-result;
}

technique Main {pass p0{VertexShader=compile vs_1_1 edgeVS();PixelShader=compile ps_2_0 edgeDetectPS();}}

