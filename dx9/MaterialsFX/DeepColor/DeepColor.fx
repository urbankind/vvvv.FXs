//@author:desaxismundi
//@help:depth as colors
//@tags:depth,color,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP:WorldViewProjection;

//material properties
float4 NearColor:COLOR <string UIName="Foreground Color";> ={1.0,1.0,1.0,1.0};
float4 FarColor:COLOR <string UIName="Background Color";> ={0.0,0.0,0.0,1.0};
float Hither <string UIName="near distance";> =1;
float Yon <string UIName="far distance";> =3;
float Gamma <string UIName="adjust rolloff";float UIMin=0.1;float UIMax=5.0;> =1;

struct vs2ps{
	float4 pos:POSITION;
	float4 col:COLOR0;
};

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0){
    vs2ps OUT;
    float4 Po=float4(PosO.x,PosO.y,PosO.z,1);
    float4 hpos=mul(Po,tWVP);
    float dl=(hpos.z-Hither)/(Yon-Hither);
    dl=min(dl,1);
    dl=max(dl,0);
    dl=pow(dl,Gamma);
    OUT.col=lerp(NearColor,FarColor,dl);
    OUT.pos=hpos;
    return OUT;
}

technique Depth {pass p0{VertexShader=compile vs_1_1 vs();}}
