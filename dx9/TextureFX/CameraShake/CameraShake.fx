float4x4 tWVP: WORLDVIEWPROJECTION;
float time;
float Speed <string UIName="Overall Speed";float UIMin=-1.0;float UIMax=100.0;> =21;
float Shake <string UIName="Shakiness";float UIMin=0.0;float UIMax=1.0;> =.25;
float Sharpness <string UINmae="Snappiness";float UIMin=0.1;float UIMax=3.0;> =2.2;
float2 TimeDelta <string UIName="Time Deltas for X, Y";> ={1,.2};
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};
#include "vnoise.fxh"

struct vs2ps{
    float4 vp:POSITION;
    float2 uv:TEXCOORD0;
};

vs2ps ShakerVS(float3 PosO:POSITION,float2 x:TEXCOORD0){
	vs2ps OUT=(vs2ps)0;
    OUT.vp=mul(float4(PosO,1),tWVP);
    float2 dn=Speed*time*TimeDelta;
    float2 noisePos=(float2)(0.5)+dn;
    float2 i=Shake*float2(vnoise2D(noisePos,NTab),vnoise2D(noisePos.yx,NTab));	
    i=sign(i)*pow(i,Sharpness);
    OUT.uv=x.xy+i;
    return OUT;
}

float4 PS(vs2ps IN):COLOR{
    float4 col=tex2D(Samp,IN.uv);
    return col;
}

technique TShake {pass p0{VertexShader=compile vs_2_0 ShakerVS();PixelShader=compile ps_2_0 PS();}}
