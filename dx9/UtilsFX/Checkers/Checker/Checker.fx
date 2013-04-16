//@author:desaxismundi
//@tags:checker,debug
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP:WorldViewProjection;

//material properties
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
float4 dCol:COLOR <string UIName="Dark Color";> ={0.0,0.0,0.0,1.0};
float Scale <string UIName="Checker Size";float uimin = 0.0;float uimax = 50.0;> =5.1;
float Blur <string UIName="Blur";float uimin = 0.0;float uimax = 10.0;> =1;

struct vs2ps{
    float4 HPos:POSITION;
    float3 TexCd:TEXCOORD0;
};

vs2ps VS(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps Out = (vs2ps)0;
    float4 P = float4(PosO, 1.0);
    Out.HPos  = mul(P, tWVP);
    Out.TexCd = PosO * Scale;
    return Out;
}

float4 PS(vs2ps IN):COLOR{
	float3 d = max(abs(ddx(IN.TexCd)), abs(ddy(IN.TexCd)));
	d *= Blur;
	d = smoothstep(0.25 - d, 0.25 + d, abs(frac(IN.TexCd) - 0.5));
	float check = d.x;
	check = lerp(check, 1.0 - check, d.y);
	check = lerp(check, 1.0 - check, d.z);
    return lerp(lCol, dCol, check);
}

technique Checker {pass p0{VertexShader=compile vs_2_0 VS();PixelShader=compile ps_2_a PS();}}
