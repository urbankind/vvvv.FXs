//@author:desaxismundi
//@tags:wiggle,distort,phong,point
//@credits:copyright nVidia corporation

//transforms
float4x4 tW:WORLD;        
float4x4 tV:VIEW;         
float4x4 tWV:WORLDVIEW;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tP:PROJECTION;
float4x4 tWIT:WorldInverseTranspose;

float Time;
float TimeScale =4;
float Horizontal =.5;
float Vertical =.5;

//light properties
float3 lPos <string uiname="Light Position";> ={0,5,-2};      
float lAtt0 <String uiname="Light Attenuation 0"; float uimin=0.0;> =0;
float lAtt1 <String uiname="Light Attenuation 1"; float uimin=0.0;> =.3;
float lAtt2 <String uiname="Light Attenuation 2"; float uimin=0.0;> =0;
float4 lAmb :COLOR <String uiname="Ambient Color";> ={0.15, 0.15, 0.15, 1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85, 0.85, 0.85, 1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> =25;    
float lRange <String uiname="Light Range"; float uimin=0.0;> =10;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;addressU=Wrap;addressV=wrap;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;
float alpha ;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightDirV:TEXCOORD1;
    float3 NormV:TEXCOORD2;
    float3 ViewDirV:TEXCOORD3;
    float3 PosW:TEXCOORD4;
};

vs2ps VS(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    float3 Nn = normalize(mul(NormO, tWIT).xyz);
    float timeNow = Time*TimeScale;
    float4 Po = float4(PosO.xyz,1);
    float iny = Po.y * Vertical + timeNow;
    float wiggleX = sin(iny) * Horizontal;
    float wiggleY = cos(iny) * Horizontal; // deriv
    Nn.z = Nn.z + wiggleY;
    Nn = normalize(Nn);
    Po.z = Po.z + wiggleX;
    Out.PosW = mul(Po,tW);
    float3 LightDirW = normalize(lPos - Out.PosW);
    Out.LightDirV = mul(LightDirW, tV);
    Out.NormV = normalize(mul(Nn, tWV));
    Out.PosWVP  = mul(Po, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(Out.PosWVP);
    return Out;
}

float4 PS(vs2ps In):COLOR{
    float d = distance(In.PosW, lPos);
    float atten = 0;
    //compute attenuation only if vertex within lightrange
    if (d<lRange)
    {
       atten = 1/(saturate(lAtt0) + saturate(lAtt1) * d + saturate(lAtt2) * pow(d, 2));
    }
    float4 amb = lAmb * atten;
    amb.a = 1;
    float3 H = normalize(In.ViewDirV + In.LightDirV);
    float4 shades = lit(dot(In.NormV, In.LightDirV), dot(In.NormV, H), lPower);
    float4 diff = lDiff * shades.y * atten;
    diff.a = 1;
    float4 spec = lSpec * shades.z * atten;
    spec.a = 1;
    float4 col = tex2D(Samp, In.TexCd) * (amb + diff) + spec;
    col = mul(col, tColor);
    col.a = alpha;
    return col;
}

technique TPhongPoint {pass P0{VertexShader=compile vs_1_1 VS();PixelShader=compile ps_2_0 PS();}}
