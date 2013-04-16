float2 R;
float Desat <string UIName="Desaturation";float UIMin=0.0;float UIMax=1.0;> =.5;
float Toned <string UIName="Toning";float UIMin=0.0;float UIMax=1.0;> =1;
float4 LightColor:COLOR <string UIName="Paper Tone";> ={1,0.9,0.5,1};
float4 DarkColor:COLOR <string UIName="Stain Tone";> ={0.2,0.05,0,1};
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

float4 psSEPIA(float2 vp:vpos):color{float2 x=(vp+.5)/R; 
	float3 scnColor = LightColor * tex2D(s0, x).xyz;
    float3 grayXfer = float3(0.3,0.59,0.11);
    float gray = dot(grayXfer,scnColor);
    float3 muted = lerp(scnColor,gray.xxx,Desat);
    float3 sepia = lerp(DarkColor,LightColor,gray);
    float3 result = lerp(muted,sepia,Toned);
    return float4(result,1);
}  

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique posterize {pass p0{VertexShader=compile vs_2_0 vs2d();PixelShader=compile ps_3_0 psSEPIA();}
}
