float2 R;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float Time;
#include "vnoise.fxh"

float Speed <float UIMin=-1.0;float UIMax=100.0;> =21;
float TimeSpacing <float UIMin=0.0;float UIMax=0.2;> =.1;
float Shake <float UIMin=0.0;float UIMax=1.0;> =.25;
float Sharpness <float UIMin=0.1;float UIMax=3.0;> =2.2;
float2 TimeDelta ={1,.2};

struct vs2ps{
   	float4 Position:POSITION;
    float2 UV:TEXCOORD0;
};

vs2ps vs(float3 Position:POSITION, float3 TexCoord:TEXCOORD0){
    vs2ps OUT;
    OUT.Position = float4(Position, 1);
    OUT.UV = TexCoord.xy;
    return OUT;
}

vs2ps vsSHAKER(float3 Position:POSITION, float2 TexCoord:TEXCOORD0,uniform float TimeOff){
    vs2ps OUT;
	Position.xy*=2;TexCoord+=.5/R;
    OUT.Position = float4(Position, 1);
    float2 dn = Speed*(Time+TimeOff*TimeSpacing)*TimeDelta;
	float2 off = float2(R.xy);
    //float2 noisePos = TexCoord+off+dn;
    float2 noisePos = (float2)(0.5)+off+dn;
    float2 i = Shake*float2(vnoise2D(noisePos, NTab),
							vnoise2D(noisePos.yx, NTab));
    i = sign(i) * pow(i,Sharpness);
    OUT.UV = TexCoord.xy+i;
    return OUT;
}

float4 ps(vs2ps IN):COLOR{   
	float4 texCol = tex2D(s0, IN.UV);
	return texCol;
} 

#define C0 1.0
#define C1 2.0
#define C2 4.0
#define C3 8.0
#define C4 16.0

#define CS (C0+C1+C2+C3+C4)

float4 CombinePS(vs2ps IN):COLOR{   
	float4 texCol0 = tex2D(s0, IN.UV)*(C0/CS);
	float4 texCol1 = tex2D(s0, IN.UV)*(C1/CS);
	float4 texCol2 = tex2D(s0, IN.UV)*(C2/CS);
	float4 texCol3 = tex2D(s0, IN.UV)*(C3/CS);
	float4 texCol4 = tex2D(s0, IN.UV)*(C4/CS);
	return (texCol0+texCol1+texCol2+texCol3+texCol4);
}  

technique Main {pass Shake0 {VertexShader=compile vs_2_0 vsSHAKER(0);PixelShader=compile ps_2_0 ps();}
    			pass Shake1 {VertexShader=compile vs_2_0 vsSHAKER(1);PixelShader=compile ps_2_0 ps();}
    			pass Shake2 {VertexShader=compile vs_2_0 vsSHAKER(2);PixelShader=compile ps_2_0 ps();}
   	 			pass Shake3 {VertexShader=compile vs_2_0 vsSHAKER(3);PixelShader=compile ps_2_0 ps();}
    			pass Shake4 {VertexShader=compile vs_2_0 vsSHAKER(4);PixelShader=compile ps_2_0 ps();}
    			pass Combine{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 CombinePS();}
}
