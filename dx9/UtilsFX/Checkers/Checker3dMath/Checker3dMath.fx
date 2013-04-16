//@author:desaxismundi
//@tags:checker,debug
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;
float4x4 tWIT:WorldInverseTranspose;

//light properties
float3 lPos <string uiname="Light Direction";> ={0,-5,2};  
float4 lCol:COLOR <string uiname="Light Color";> ={1.0,1.0,1.0,1.0};
float4 AmbiCol:COLOR <string uiname="Ambient Light Color";> ={0.17,0.17,0.17,1.0};
float4 SurfCol1:COLOR <string uiname="Light Checker Color";> ={1.0,0.4,0.0,1.0};
float4 SurfCol2:COLOR <string uinamepo="Dark Checker Color";> ={0.0,0.2,1.0,1.0};

float Ks <string UIName="Specular";float UIMin=0.0;float UIMax=2.0;> =.5;
float SpecExpon <string UIName= "Specular Power";float UIMin = 1.0;float UIMax = 128.0;> =25;
float SWidth <string UIName="AA Filter Width";float UIMin=0.001;float UIMax=10.0;> =1;
float Scale <string UIName="Checker Size";float UIMin=0.0;float UIMax=5.0;> =.5;
float Balance <string UIName="Darkness Ratio";float UIMin=0.01;float UIMax=0.99;> =.5;

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
    float3 WorldTangent:TEXCOORD4;
    float3 WorldBinorm:TEXCOORD5;
    float4 ObjPos:TEXCOORD6;
};

vs2ps VS(
      float3 PosO:POSITION,
      float4 UV:TEXCOORD0,
      float4 NormO:NORMAL,
      float4 Tan:TANGENT0,
      float4 BinormO:BINORMAL0)
{

    vs2ps OUT = (vs2ps)0;
    OUT.WorldNormal = mul(NormO, tWIT).xyz;
    OUT.WorldTangent = mul(Tan, tWIT).xyz;
    OUT.WorldBinorm = mul(BinormO, tWIT).xyz;
    float4 Po = float4(PosO.x,PosO.y,PosO.z,1.0);
    float3 Pw = mul(Po, tW).xyz;
    OUT.LightVec = lPos - Pw;
    OUT.TexCd = UV;
    OUT.WorldEyeVec = normalize(tVI[3].xyz - Pw);
    float4 hpos = mul(Po, tWVP);
    OUT.ObjPos = Po;
    OUT.HPosition = hpos;
    return OUT;
}

//PS with box-filtered step function
    float4 PS(vs2ps IN):COLOR{
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float edge = Scale*Balance;
    float op = SWidth/Scale;

//x stripes
    float width = abs(ddx(IN.ObjPos.x)) + abs(ddy(IN.ObjPos.x));
    float w = width*op;
    float x0 = IN.ObjPos.x/Scale - (w/2.0);
    float x1 = x0 + w;
    float nedge = edge/Scale;
    float i0 = (1.0-nedge)*floor(x0) + max(0.0, frac(x0)-nedge);
    float i1 = (1.0-nedge)*floor(x1) + max(0.0, frac(x1)-nedge);
    float check = (i1 - i0)/w;
    check = min(1.0,max(0.0,check));

//y stripes
    width = abs(ddx(IN.ObjPos.y)) + abs(ddy(IN.ObjPos.y));
    w = width*op;
    x0 = IN.ObjPos.y/Scale - (w/2.0);
    x1 = x0 + w;
    nedge = edge/Scale;
    i0 = (1.0-nedge)*floor(x0) + max(0.0, frac(x0)-nedge);
    i1 = (1.0-nedge)*floor(x1) + max(0.0, frac(x1)-nedge);
    float s = (i1 - i0)/w;
    check = abs(check - min(1.0,max(0.0,s)));

//z stripes
    width = abs(ddx(IN.ObjPos.z)) + abs(ddy(IN.ObjPos.z));
    w = width*op;
    x0 = IN.ObjPos.z/Scale - (w/2.0);
    x1 = x0 + w;
    nedge = edge/Scale;
    i0 = (1.0-nedge)*floor(x0) + max(0.0, frac(x0)-nedge);
    i1 = (1.0-nedge)*floor(x1) + max(0.0, frac(x1)-nedge);
    s = (i1 - i0)/w;
    check = abs(check - min(1.0,max(0.0,s)));

    float4 dColor = lerp(SurfCol1,SurfCol2,check);
    float3 Vn = normalize(IN.WorldEyeVec);
    float3 Hn = normalize(Vn + Ln);
    float4 lighting = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    float  hdn = lighting.z; // Specular coefficient
    float  ldn = lighting.y; // Diffuse coefficient
    float4 diffContrib = dColor * (ldn*lCol + AmbiCol);
    float4 specContrib = hdn * lCol;
    float4 result = diffContrib + (Ks * specContrib);
    return result;
}

technique checker3d {pass p0{VertexShader=compile vs_2_0 VS();PixelShader=compile ps_2_a PS();}}
