float2 R;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float Time;
float Speed <float UIMin=-1.0;float UIMax=20.0;> =1.3;
float TimeSpacing <float UIMin=0.0;float UIMax=0.2;> =.04;
float Shake <float UIMin=0.0;float UIMax=0.1;> =.01;
float Sharpness <float UIMin=0.1;float UIMax=3.0;> =.4;
float2 TimeDelta ={1,.2};

#include "vnoise.fxh"

struct vs2ps{
   	float4 Position:POSITION;
    float4 UV:TEXCOORD0;
    float4 UV2:TEXCOORD1;
};

vs2ps vsSHAKER(float3 Position:POSITION, float2 TexCoord:TEXCOORD0,uniform float TimeOff) {
    vs2ps OUT;
	Position.xy*=2;TexCoord+=.5/R;
    OUT.Position = float4(Position, 1);
	float4 off = float2(R.x,R.y).xyxy;
    float4 dn = Speed*float4(TimeDelta,TimeDelta)*
    				   float4((Time+TimeOff*TimeSpacing).xx,
           				      (Time+(TimeOff+1)*TimeSpacing).xx);
    float4 noisePos = (float4)(0.5)+off+dn;
    float4 i = Shake*float4(vnoise2D(noisePos.xy, NTab),
							vnoise2D(noisePos.yx, NTab),
							vnoise2D(noisePos.zw, NTab),
							vnoise2D(noisePos.wz, NTab));
    i = sign(i) * pow(i,Sharpness);
    OUT.UV = TexCoord.xyxy +i;
    dn = Speed*float4(TimeDelta,TimeDelta)*
    				   float4((Time+(TimeOff+2)*TimeSpacing).xx,
           				      (Time+(TimeOff+3)*TimeSpacing).xx);
    noisePos = (float4)(0.5)+off+dn;
    i = Shake*float4(vnoise2D(noisePos.xy, NTab),
					 vnoise2D(noisePos.yx, NTab),
					 vnoise2D(noisePos.zw, NTab),
					 vnoise2D(noisePos.wz, NTab));
    i = sign(i) * pow(i,Sharpness);
    OUT.UV2 = TexCoord.xyxy +i;
    return OUT;
}

#define C0 1.0
#define C1 2.0
#define C2 4.0
#define C3 8.0

#define CS (C0+C1+C2+C3)

#define W0 (C0/CS)
#define W1 (C1/CS)
#define W2 (C2/CS)
#define W3 (C3/CS)

float4 ps(vs2ps IN):COLOR{   
	float4 texCol0 = tex2D(s0, IN.UV.xy)*W0;
	float4 texCol1 = tex2D(s0, IN.UV.zw)*W1;
	float4 texCol2 = tex2D(s0, IN.UV2.xy)*W2;
	float4 texCol3 = tex2D(s0, IN.UV2.zw)*W3;
	return (texCol0+texCol1+texCol2+texCol3);
}  

technique Main {pass p0{VertexShader=compile vs_2_0 vsSHAKER(0);PixelShader=compile ps_2_0 ps();}}
