//@author:desaxismundi
//@tags:wiggle,distort
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light properties
float3 lPos <string UIName="Light Position";> ={-1.0,1.0,-1.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1};
float4 AmbiCol:COLOR <string UIName="Ambient Light Color";> ={0.2,0.2,0.2,1};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={0.9,0.68,0.543,1};

float SpecExpon <string UIName="Specular Exponent";float UIMin=1.0;float UIMax=128.0;> =5;
float Time;
float Speed <float UIMin=0.1;float UIMax=10;> =4;
float Horizontal <float UIMin=0.001;float UIMax=10;> =.5;
float Vertical <float UIMin=0.001;float UIMax=10.0;float UIStep=0.1;> =.5;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=None;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord0:TEXCOORD0;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

vs2ps vsWIGGLE(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT = (vs2ps)0;
    float3 Nn = normalize(mul(NormO, tWIT).xyz);
    float timeNow = Time*Speed;
    float4 Po = float4(PosO.xyz,1);
    float iny = Po.y * Vertical + timeNow;
    float wiggleX = sin(iny) * Horizontal;
    float wiggleY = cos(iny) * Horizontal; // deriv
    Nn.y = Nn.y + wiggleY;
    Nn = normalize(Nn);
    Po.x = Po.x + wiggleX;
    OUT.HPosition = mul(Po, tWVP);
    float3 Pw = mul(Po, tW).xyz;
    float3 Ln = normalize(lPos - Pw);
    float ldn = dot(Ln,Nn);
    float diffComp = max(0,ldn);
    float3 diffContrib = SurfCol * ( diffComp * lCol + AmbiCol);
    OUT.diffCol = float4(diffContrib,1);
    OUT.TexCoord0 = UV;
    float3 Vn = normalize(tVI[3].xyz - Pw);
    float3 Hn = normalize(Vn + Ln);
    float hdn = pow(max(0,dot(Hn,Nn)),SpecExpon);
    OUT.specCol = float4(hdn * lCol);
    return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float4 result = IN.diffCol*tex2D(Samp,IN.TexCoord0)+IN.specCol;
    return result;
}

technique MrWiggle {pass p0{VertexShader = compile vs_1_1 vsWIGGLE();PixelShader = compile ps_1_1 ps();}}

