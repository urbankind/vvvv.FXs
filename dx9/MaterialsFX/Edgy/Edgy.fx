//@author:desaxismundi
//@tags:edgy,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string UIName="Light Position";> ={10.0,10.0,-10.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
float4 AmbiCol:COLOR <string UIName="Ambient Color";> ={0.1,0.1,0.1,1.0};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={1.0,0.0,0.0,1.0};
float4 EdgeColor:COLOR<string UIName="Edge Color";> ={0.2, 1.0, 0.2, 1.0};
float Ks <string UIName="Specular";float UIMin=0.0;float UIMax=1.0;> =.5;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =30;
float sp <string UIName="Edging Exponent";float UIMin=.1;float UIMax=2;> =.6;
float edgeFade <string UIName="Edging Amount";float UIMin=0.0;float UIMax=1.0;> =.5;
float edgeFadeL <string UIName="Edging Effect on Light";float UIMin=0.0;float UIMax=1.0;> =-.0;

struct vs2ps{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
    float4 Refl:TEXCOORD4;
    float4 DiffColor:COLOR0;
    float4 SpecColor:COLOR1;
};

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
	vs2ps OUT=(vs2ps)0;
    OUT.WorldNormal=mul(NormO, tWIT).xyz;
    float4 Po=half4(PosO.xyz,1);
    float3 Pw=mul(Po,tW).xyz;
    OUT.LightVec=(lPos-Pw);
    OUT.WorldEyeVec=(tVI[3].xyz-Pw);
    OUT.HPosition=mul(Po,tWVP);
    //OUT.UV = IN.UV.xy * float2(uRept,vRept);
    OUT.UV=UV.xy;
    return OUT;
}

float4 psEDGY(vs2ps IN):COLOR{
    float3 Ln=normalize(IN.LightVec);
    float3 Vn=normalize(IN.WorldEyeVec);
    float3 Nn=normalize(IN.WorldNormal);
    float3 Hn=normalize(Vn+Ln);
    float ldn=dot(Ln,Nn);
    float4 lv=lit(ldn,dot(Hn,Nn),SpecExpon);
    float subd=abs(dot(Nn,Vn));
    subd=pow(subd,sp);
    float4 SurfaceColor=lerp(EdgeColor,SurfCol,subd);
    SurfaceColor=lerp(SurfCol,SurfaceColor,edgeFade);
	ldn=max(ldn,0);
    ldn=pow(ldn,sp);
    float4 IncidentColor=lerp(EdgeColor,lCol,ldn);
    IncidentColor=lerp(lCol,IncidentColor,edgeFadeL);
    float4 diffContrib=SurfaceColor*(lv.y*IncidentColor+AmbiCol);
    float4 specContrib=Ks*lv.y*lv.z*IncidentColor;
    //return SurfaceColor;
    return diffContrib+specContrib;
}

technique edgy{pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 psEDGY();}}
