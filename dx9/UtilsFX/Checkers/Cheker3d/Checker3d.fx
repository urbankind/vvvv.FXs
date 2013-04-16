//@author:desaxismundi
//@help:3D Checker showing anti-aliasing using ddx/ddy
//@tags:checker,debug
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;
float4x4 tWIT : WorldInverseTranspose;

//light properties
half3 lDir <string UIName="Lamp Direction";> ={0.7,-0.7,-0.7};
float4 AmbiCol:COLOR <string UIName="Ambient Light Color";> ={0.07,0.07,0.07,1};
float4 BrightCol:COLOR <string UIName="Light Checker Color";> ={1.0,0.8,0.3,1.0};
float4 DarkCol:COLOR <string UIName="Dark Checker Color";> ={0.0,0.2,0.4,1.0};
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =20;
float Ks <string UIName="Specular";float UIMin=0.0;float UIMax=1.0;> =.8;
float Balance <string UIName="Light::Dark Ratio";float uimin=0.0;float uimax=1.0;> =.31;
float Scale<string UIName="Checker Size";float uimin=0.01;float uimax=5.0;> =3.4;

//procedural texture
#define TEX_SIZE 64

texture Tex <string uiname="stripeTex";>;
sampler2D Samp=sampler_state{Texture =(Tex);MinFilter=LINEAR;MagFilter=LINEAR;        MipFilter=LINEAR;AddressU=WRAP;AddressV=CLAMP;};

float4 MakeStripe(float2 Pos:POSITION,float ps:PSIZE):COLOR{
   float v = 0;
   float nx = Pos.x+ps; // keep the last column full-on, always
   v = nx > Pos.y;
   return float4(v.xxxx);
}

struct vs2ps{
    float4 HPos:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 WNorm:TEXCOORD1;
    float3 WView:TEXCOORD2;
};

vs2ps VS(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT = (vs2ps)0;
    float4 Po = float4(PosO.x,PosO.y,PosO.z,1.0);    // object space
    float4 hpos  = mul(Po, tWVP);        // position (projected)
    OUT.HPos  = hpos;
    float4 Pw = mul(Po, tW); // world coords
    OUT.TexCd = Pw * Scale;
    float4 Nn = normalize(NormO);
    OUT.WView = normalize(tVI[3].xyz - Pw);
    OUT.WNorm = mul(Nn, tWIT).xyz;
    return OUT;
}

float4 PS(vs2ps IN):COLOR{
    float stripex = tex2D(Samp,float2(IN.TexCd.x,Balance)).x;
    float stripey = tex2D(Samp,float2(IN.TexCd.y,Balance)).x;
    float stripez = tex2D(Samp,float2(IN.TexCd.z,Balance)).x;
    float check = abs(abs(stripex - stripey) - stripez);
    float3 dColor = lerp(BrightCol,DarkCol,check).xyz;
    float3 Nn = normalize(IN.WNorm);
    float3 Vn = normalize(IN.WView);
    float3 Hn = normalize(Vn - lDir);
    float4 litV = lit(dot(-lDir,Nn),dot(Hn,Nn),SpecExpon);
    float spec = litV.z*check*Ks;
	float3 result = (dColor * (AmbiCol + litV.yyy)) + spec.xxx;
    return float4(result.xyz,1.0);
}

technique checker3dm {pass p0{VertexShader = compile vs_2_0 VS();PixelShader = compile ps_2_0 PS();}}
