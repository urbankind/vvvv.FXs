//@author:desaxismundi
//@tags:twister,distort
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light properties
float3 lPos = {-1.0,1.0,-1.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1};
float4 AmbiCol:COLOR <string UIName="Ambient Light Color";> ={0.2,0.2,0.2,1};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={0.1,0.5,0.4,1};

float SpecExpon <string UIName="specular power";float UIMin=1.0;float UIMax=128.0;> =42;
float Time;
float TimeScaleH <float UIMin=0.1;float UIMax=10;> =1;
float TimeScaleV <float UIMin=0.1;float UIMax=10;> =2.7;
float Wobble <float UIMin=0;float UIMax=2.0;> =.2;
float Horizontal <float UIMin=0;float UIMax=2.0;> =.1;
float Vertical <float UIMin=0.01;float UIMax=10.0;> =.2;

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord0:TEXCOORD0;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

vs2ps vsTWISTER(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL){
    vs2ps OUT;
    float3 Nn = normalize(mul(Normal, tWIT).xyz);
    float timeNowV = (Time*TimeScaleV);
    float timeNowH = (Time*TimeScaleH);
    float4 Po = float4(Position.xyz,1);
    float iny = Po.y * Vertical + timeNowV;
    float inxz = sqrt(dot(Po.xz,Po.xz)) * Horizontal * timeNowH;
    float hScale = Wobble * (1.0+sin(inxz));
    float wiggleX = sin(iny) * hScale;
    float wiggleY = cos(iny) * hScale;
    Po.x = Po.x + wiggleX;
    Nn.y = Nn.y + wiggleY;
    Nn = normalize(Nn);
    Po.z = Po.z + wiggleY;
    OUT.HPosition = mul(Po, tWVP);
    Nn.y = Nn.y + wiggleX;
    Nn = normalize(Nn);
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

technique MrTwister {pass p0{VertexShader=compile vs_1_1 vsTWISTER();}}
