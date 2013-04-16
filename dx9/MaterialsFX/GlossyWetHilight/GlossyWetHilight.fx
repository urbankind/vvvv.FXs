//@author:desaxismundi
//@tags:gloss,wet,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 LightPos <string UIName="Light Position";> ={100.0,100.0,100.0};
float4 AmbiCol:COLOR <string UIName="Ambient Color";> ={0.1,0.1,0.1,1.0};
float4 DiffCol:COLOR <string UIName="Diffuse Color";> ={1.0,0.0,0.0,1.0};
float4 SpecCol:COLOR <string UIName="Specular Color";> ={0.7,0.7,1.0,1.0};
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =6;
float Ks <string UIName="Specular Strength";float UIMin=0.0;float UIMax=1.5;> =1;
float GlossTopUI <string UIName="Bright Glossy Edge";float UIMin=0.2;float UIMax=1.0;> =.46;
float GlossBotUI <string UIName="Dim Glossy Edge";float UIMin=0.05;float UIMax=0.95;> =.41;
static float GlossTop=max(GlossTopUI,GlossBotUI);
static float GlossBot=min(GlossTopUI,GlossBotUI);
float GlossDrop <string UIName="Glossy Brightness Drop";float UIMin=0.0;float UIMax=1.0;> =.25;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=None;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD5;
};

float GlossyDrop(float v,uniform float top,uniform float bot,uniform float drop){
    return (drop+smoothstep(bot,top,v)*(1-drop));
}

vs2ps vs(float3 Position:POSITION,float3 UV:TEXCOORD0,float4 Normal:NORMAL){
    vs2ps OUT = (vs2ps)0;   
    float4 normal = normalize(Normal);
    OUT.WorldNormal = mul(normal,tWIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.LightVec = normalize(LightPos-Pw);
    OUT.TexCoord = UV.xyxx;
    OUT.WorldView = normalize(tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

void GlossShared(vs2ps IN,out float3 DiffuseContrib,out float3 SpecularContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn+Ln);
    float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib = litV.y*DiffCol+AmbiCol;
    float spec = litV.y*litV.z;
    spec *= (Ks*GlossyDrop(spec,GlossTop,GlossBot,GlossDrop));
    SpecularContrib = spec*SpecCol;
}

float4 ps(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
	GlossShared(IN,diffContrib,specContrib);
    float3 map = tex2D(Samp,IN.TexCoord.xy).xyz;
    float3 result = specContrib+(map*diffContrib);
    return float4(result,1);
}

technique GlossyWetHilight{pass p0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 ps();}}

