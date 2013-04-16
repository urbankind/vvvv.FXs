float2 R;
float Glowness <string UIName="Glow Strength";float UIMin=0.0;float UIMax=4.0;> =3;

float4x4 tWVP:WorldViewProjection;
float3x3 tWI:WorldInverse;

#define RTT_SIZE 128
float TexelIncrement <string UIName="Texel Stride for Blur";> = 1/RTT_SIZE;
texture t0 <float2 Dimensions={RTT_SIZE, RTT_SIZE};int MIPLEVELS = 1;>;
sampler s0=sampler_state {texture=(t0);AddressU=CLAMP;AddressV=CLAMP;AddressW=CLAMP;MIPFILTER=NONE;MINFILTER=LINEAR;MAGFILTER=LINEAR;};

struct vs2psBLUR{
    float4 Position:POSITION;
    float4 Diffuse:COLOR0;
    float4 TexCoord0:TEXCOORD0;
    float4 TexCoord1:TEXCOORD1;
    float4 TexCoord2:TEXCOORD2;
    float4 TexCoord3:TEXCOORD3;
    float4 TexCoord4:TEXCOORD4;
    float4 TexCoord5:TEXCOORD5;
    float4 TexCoord6:TEXCOORD6;
    float4 TexCoord7:TEXCOORD7;
    float4 TexCoord8:COLOR1;   
};

struct vs2ps{
   	float4 Position:POSITION;
    float4 Diffuse:COLOR0;
    float4 TexCoord0:TEXCOORD0;
};

vs2ps vs(float3 Position:POSITION,float3 TexCoord:TEXCOORD0){
    vs2ps OUT = (vs2ps)0;
	Position.xy*=2;
	TexCoord+=float3(.5/R,1);
    OUT.Position = float4(Position,1);
    OUT.TexCoord0 = float4(TexCoord,1); 
    return OUT;
}

vs2psBLUR vsVertical9tap(float3 Position:POSITION,float3 TexCoord:TEXCOORD0){
    vs2psBLUR OUT = (vs2psBLUR)0;
	Position.xy*=2;
	TexCoord+=float3(.5/R,1);
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x, TexCoord.y, 1);
    OUT.TexCoord0 = float4(Coord.x, Coord.y + TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x, Coord.y + TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y + TexelIncrement * 3, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x, Coord.y + TexelIncrement * 4, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord5 = float4(Coord.x, Coord.y - TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord6 = float4(Coord.x, Coord.y - TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord7 = float4(Coord.x, Coord.y - TexelIncrement * 3, TexCoord.z, 1);
    OUT.TexCoord8 = float4(Coord.x, Coord.y - TexelIncrement * 4, TexCoord.z, 1);
    return OUT;
}

vs2psBLUR vsHorizontal9tap(float3 Position:POSITION,float3 TexCoord:TEXCOORD0){
    vs2psBLUR OUT = (vs2psBLUR)0;
	Position.xy*=2;
	TexCoord+=float3(.5/R,1);
    OUT.Position = float4(Position,1);
    
    float3 Coord = float3(TexCoord.x, TexCoord.y, 1);
    OUT.TexCoord0 = float4(Coord.x + TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x + TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x + TexelIncrement * 3, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x + TexelIncrement * 4, Coord.y, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord5 = float4(Coord.x - TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord6 = float4(Coord.x - TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord7 = float4(Coord.x - TexelIncrement * 3, Coord.y, TexCoord.z, 1);
    OUT.TexCoord8 = float4(Coord.x - TexelIncrement * 4, Coord.y, TexCoord.z, 1);
    return OUT;
}

vs2psBLUR vsVertical5tap(float3 Position:POSITION,float3 TexCoord:TEXCOORD0)
{
    vs2psBLUR OUT = (vs2psBLUR)0;
	Position.xy*=2;
	TexCoord+=float3(.5/R,1);
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x , TexCoord.y , 1);
    OUT.TexCoord0 = float4(Coord.x, Coord.y + TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x, Coord.y + TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x, Coord.y - TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y - TexelIncrement * 2, TexCoord.z, 1);
    return OUT;
}

vs2psBLUR vsHorizontal5tap(float3 Position:POSITION,float3 TexCoord:TEXCOORD0)
{
    vs2psBLUR OUT = (vs2psBLUR)0;
	Position.xy*=2;
	TexCoord+=float3(.5/R,1);
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x, TexCoord.y, 1);
    OUT.TexCoord0 = float4(Coord.x + TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x + TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x - TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x - TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    return OUT;
}

// Relative filter weights indexed by distance from "home" texel
//    This set for 9-texel sampling
#define WT9_0 1.0
#define WT9_1 0.8
#define WT9_2 0.6
#define WT9_3 0.4
#define WT9_4 0.2

// Alt pattern -- try your own!
// #define WT9_0 0.1
// #define WT9_1 0.2
// #define WT9_2 3.0
// #define WT9_3 1.0
// #define WT9_4 0.4

#define WT9_NORMALIZE (WT9_0+2.0*(WT9_1+WT9_2+WT9_3+WT9_4))

float4 psBlurHorizontal9tap(vs2psBLUR IN) : COLOR
{   
    float4 OutCol = tex2D(s0, IN.TexCoord0) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord1) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord2) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord3) * (WT9_4/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord4) * (WT9_0/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord5) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord6) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord7) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord8) * (WT9_3/WT9_NORMALIZE);
    return OutCol;
} 

float4 psBlurVertical9tap(vs2psBLUR IN) : COLOR
{   
    float4 OutCol = tex2D(s0, IN.TexCoord0) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord1) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord2) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord3) * (WT9_4/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord4) * (WT9_0/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord5) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord6) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord7) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord8) * (WT9_3/WT9_NORMALIZE);
    return Glowness*OutCol;
} 

// Relative filter weights indexed by distance from "home" texel
//    This set for 5-texel sampling
#define WT5_0 1.0
#define WT5_1 0.8
#define WT5_2 0.4

#define WT5_NORMALIZE (WT5_0+2.0*(WT5_1+WT5_2))

float4 psBlurHorizontal5tap(vs2psBLUR IN):COLOR{   
    float4 OutCol = tex2D(s0, IN.TexCoord0) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord1) * (WT5_2/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord2) * (WT5_0/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord3) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord4) * (WT5_2/WT5_NORMALIZE);
    return OutCol;
} 

float4 psBlurVertical5tap(vs2psBLUR IN):COLOR{   
    float4 OutCol = tex2D(s0, IN.TexCoord0) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord1) * (WT5_2/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord2) * (WT5_0/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord3) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(s0, IN.TexCoord4) * (WT5_2/WT5_NORMALIZE);
    return Glowness*OutCol;
} 

float4 psGLOW(vs2ps IN):COLOR{   
	float4 tex = tex2D(s0, float2(IN.TexCoord0.x, IN.TexCoord0.y));
	return tex;
}  

technique Glow_9Tap {pass BlurGlowBuffer_Horz{VertexShader=compile vs_2_0 vsHorizontal9tap();PixelShader=compile ps_2_0 psBlurHorizontal9tap();}
    				 pass BlurGlowBuffer_Vert{VertexShader=compile vs_2_0 vsVertical9tap();PixelShader=compile ps_2_0 psBlurVertical9tap();}
   					 pass GlowPass{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 psGLOW();}}

technique Glow_5Tap {pass BlurGlowBuffer_Horz{VertexShader=compile vs_2_0 vsHorizontal5tap();PixelShader=compile ps_2_0 psBlurHorizontal5tap();}
    				 pass BlurGlowBuffer_Vert{VertexShader=compile vs_2_0 vsVertical5tap();PixelShader=compile ps_2_0 psBlurVertical5tap();}
    				 pass GlowPass{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 psGLOW();}}

