//@author:desaxismundi
//@tags:plastic,reflection,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string UIName="Light Direction";> ={0.0,0.0,-1.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
float4 lAmb:COLOR <string UIName="Surface Color";> ={0.1,0.1,0.1,1.0};
float4 lDiff:COLOR <string UIName="Surface Color2";> ={0.8,0.8,1.0,1.0};
float Ks <string UIName="specular intensity";float UIMin=0.0;float UIMax=1.0;> =.5;
float SpecExpon <string UIName="specular power";float UIMin=1.0;float UIMax=128.0;> =30;
float Kr <string UIName="max reflection strength";float UIMin = 0.0;float UIMax = 1.0;> =1;
float KrMin <string UIName= "min reflection strength";float UIMin=0.0;float UIMax=1.0;> =.05;
float FresnelExpon <string UIName= "Expon used in Schlick Fresnel Func";float UIMin=1.0;float UIMax=5.0;> =5;

//samplers
texture  ColorTexture;
sampler2D Samp=sampler_state{Texture=(ColorTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};
texture EnvironmentTexture;
samplerCUBE Samp1=sampler_state{Texture=(EnvironmentTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};

struct vs2ps{
    float3 Position:POSITION;
    float4 UV:TEXCOORD0;
    float4 Normal:NORMAL;
};

struct vertexOutput{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
};

struct vertexShadedOutput{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float4 DiffColor:COLOR0;
    float4 SpecColor:COLOR1;
};

struct vertexShadedFOutput {
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float4 Refl:TEXCOORD1;
    float4 DiffColor:COLOR0;
    float4 SpecColor:COLOR1;
};

void phongLighting(float3 LightVec,float3 ViewVec,float3 Normal,float4 SurfaceColor,out float3 Vn,out float3 Nn,out float4 DiffResult, out float4 SpecResult){
    float3 Ln = normalize(LightVec);
    Vn = normalize(ViewVec);
    Nn = normalize(Normal);
    float3 Hn = normalize(Vn+Ln);
    float4 lv = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffResult = SurfaceColor*(lv.y*lCol+lAmb);
    SpecResult = Ks*lv.z*lCol;
}

float4 fresnelVec(float3 Vn,float3 Nn){
    float vdn=1-abs(dot(Vn,Nn));
    float fres = KrMin+(Kr-KrMin)*pow(vdn,FresnelExpon);
    return float4(reflect(Vn,Nn),fres);
}

vertexOutput pixelShadedVS(vs2ps IN){
    vertexOutput OUT;
    OUT.WorldNormal = mul(IN.Normal,tWIT).xyz;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.LightVec = (lPos-Pw);
    OUT.WorldEyeVec = (tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    OUT.UV = IN.UV.xy;
    return OUT;
}

vertexShadedOutput vertexShadedVS(vs2ps IN){
    vertexShadedOutput OUT;
    float3 Vn, Nn;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    phongLighting((lPos-Pw),(tVI[3].xyz-Pw),mul(IN.Normal,tWIT).xyz,lDiff,Vn,Nn,OUT.DiffColor,OUT.SpecColor);
    OUT.HPosition = mul(Po,tWVP);
    OUT.UV = IN.UV.xy;
    return OUT;
}

vertexShadedFOutput vertexShadedFVS(vs2ps IN){
    vertexShadedFOutput OUT;
    float3 Vn, Nn;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    phongLighting((lPos-Pw),(tVI[3].xyz-Pw),mul(IN.Normal,tWIT).xyz,lDiff,Vn,Nn,OUT.DiffColor,OUT.SpecColor);
    OUT.Refl = fresnelVec(Vn,Nn);
    OUT.HPosition = mul(Po,tWVP);
    OUT.UV = IN.UV.xy;
    return OUT;
}

float4 sharedPS(vertexOutput IN,float4 DiffColor):COLOR{
    float4 diffContrib, specContrib;
    float3 Vn,Nn;
    phongLighting(IN.LightVec,IN.WorldEyeVec,IN.WorldNormal,DiffColor,Vn,Nn,diffContrib,specContrib);
    return diffContrib+specContrib;
}

float4 sharedFPS(vertexOutput IN,float4 DiffColor):COLOR{
    float4 diffContrib,specContrib;
    float3 Vn,Nn;
    phongLighting(IN.LightVec,IN.WorldEyeVec,IN.WorldNormal,DiffColor,Vn,Nn,diffContrib,specContrib);
    float4 rv = fresnelVec(Vn,Nn);
    float4 refl = rv.w*texCUBE(Samp1,rv.xyz);
    return diffContrib+specContrib+refl;
}

float4 untexturedPS(vertexOutput IN):COLOR{
	return sharedPS(IN,lDiff);}

float4 texturedPS(vertexOutput IN):COLOR{
	return sharedPS(IN,(lDiff*tex2D(Samp,IN.UV)));}

float4 untexturedFPS(vertexOutput IN):COLOR{
	return sharedFPS(IN,lDiff);}

float4 texturedFPS(vertexOutput IN):COLOR{
	return sharedFPS(IN,lDiff*tex2D(Samp,IN.UV));}

float4 vertexShadedPS(vertexShadedOutput IN):COLOR{
	return IN.DiffColor*tex2D(Samp,IN.UV.xy)+IN.SpecColor;}

float4 vertexShadedFPS(vertexShadedFOutput IN):COLOR{
    float4 refl = IN.Refl.w*texCUBE(Samp1,IN.Refl.xyz);
    return IN.DiffColor*tex2D(Samp,IN.UV.xy)+IN.SpecColor+refl;
}
float4 vertexShadedF_ntPS(vertexShadedFOutput IN):COLOR{
    float4 refl = IN.Refl.w*texCUBE(Samp1,IN.Refl.xyz);
    return IN.DiffColor+IN.SpecColor+refl;
}

technique plastic_textured {pass p0{VertexShader=compile vs_2_0 pixelShadedVS();PixelShader=compile ps_2_0 texturedPS();}}
technique plastic_untextured {pass p0{VertexShader=compile vs_2_0 pixelShadedVS();PixelShader=compile ps_2_0 untexturedPS();}}
technique plastic_fresnel_untextured {pass p0{VertexShader=compile vs_2_0 pixelShadedVS();PixelShader=compile ps_2_0 untexturedFPS();}}
technique plastic_fresnel_textured {pass p0{VertexShader=compile vs_2_0 pixelShadedVS();PixelShader=compile ps_2_0 texturedFPS();}}
technique vertex_shaded_textured {pass p0{VertexShader=compile vs_1_1 vertexShadedVS();PixelShader=compile ps_1_1 vertexShadedPS();}}
technique vertex_shaded_untextured {pass p0{VertexShader=compile vs_1_1 vertexShadedVS();}}
technique vertex_shaded_fresnel_textured {pass p0{VertexShader=compile vs_1_1 vertexShadedFVS();PixelShader=compile ps_2_0 vertexShadedFPS();}}

