//@author:desaxismundi
//@tags:gouraud,blinn,fog

//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;         
float4x4 tWV:WORLDVIEW;
float4x4 tP:PROJECTION; 

//material properties
float3 lDir <string uiname="Light Direction";> ={0,-5,2};      
float4 lAmb:COLOR <String uiname="Ambient Color";> ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float lPower <String uiname="Power"; float uimin=0.0;> =25;  
//fog
float4 FogColor:COLOR <string UIName="Fog Color";> ={1.0,1.0,1.0,1.0};
float Hither <string UIName= "far distance";> =3;
float Yon <string UIName="near distance";> =1;
float Gamma <string UIName="Fog Power";float UIMin=0.1;float UIMax=5.0;> =1;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float4 Fogged:COLOR0;
    float4 Specular:COLOR1;
};

vs2ps vs(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
     float4 Po = float4(PosO.x,PosO.y,PosO.z,1);
    float3 LightDirV = normalize(-mul(lDir,tV));
    float3 NormV = normalize(mul(NormO,tWV));
    float4 PosV = mul(PosO,tWV);
    float3 ViewDirV = normalize(-PosV);
    float3 H = normalize(ViewDirV+LightDirV);
    float3 shades = lit(dot(NormV,LightDirV),dot(NormV,H),lPower);
    float dl = (PosV.z-Hither)/(Yon-Hither);
    dl = min(dl,1);
    dl = max(dl,0);
    dl = pow(dl,Gamma);
    float4 diff = lDiff*shades.y;
    diff.a = 1;
    float4 spec = lSpec*shades.z;
    spec.a = 1;
    
    Out.PosWVP  = mul(PosV,tP);
    Out.TexCd = mul(TexCd,tTex);
    float4 Diffuse = diff+lAmb;
    Out.Fogged = lerp(FogColor,(Diffuse+spec),dl);
    return Out;
}

float4 ps(vs2ps In):COLOR{
    float4 col = tex2D(Samp,In.TexCd);
    col.rgb *= In.Fogged;
    return mul(col,tColor);
}

technique GouraudDirectional {pass P0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_1_4 ps();}}
