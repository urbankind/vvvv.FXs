//@author:desaxismundi
//@tags:scaredy,distort
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light properties
float3 LightDirD <string UIName="Light Direction";> ={-1.0,1.0,-1.0};
float4 LightColorD:COLOR <string UIName="Distant Light Color";> ={0.2,0.3,1.0,1.0};
float LightIntensityD <string UIName="Distant Light Strength";> =.5;
float4 AmbiColor:COLOR <string UIName="Ambient Color";> ={0.1,0.1,0.1,1.0};
float4 SurfColor:COLOR <string UIName="Surface Color";> ={0.8,0.8,1.0,1.0};

float Ks <string UIName="specular intensity";float UIMin=0.0;float UIMax=1.0;> =.5;
float SpecExpon < string UIName="specular power";float UIMin=1.0;float UIMax=128.0;> =30;
float Suction <string UIName="Force";float UIMin=0.0;float UIMax=0.2;> =.05;
float PushMax <string UIName="Push Max";float UIMin=0.0;float UIMax=2.5;> =.8;

float4 MouseL;
float3 MousePos;

struct vertexOutput{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
};

vertexOutput pushVS(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL,uniform float3 LightDir){
    vertexOutput OUT;
    OUT.WorldNormal = mul(Normal, tWIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po, tW).xyz;
    OUT.WorldEyeVec = (tVI[3].xyz - Pw);
    float4 Ph = mul(Po, tWVP);
    OUT.HPosition = Ph;
	float2 dm = 2*(float2(MousePos.x-.5,0.5-MousePos.y)) - (Ph.xy/Ph.w);
	float dx = Suction/dot(dm,dm);
	dx = min(PushMax,dx*Ph.w);
	dx = (MouseL.z * dx) + (MouseL.z-1)*dx;
	OUT.HPosition.xy -= (dx*dm);
    OUT.UV = UV.xy;
    OUT.LightVec = -LightDir;
    return OUT;
}

// this portion shared for all lamps
float4 sharedPS(vertexOutput IN,float4 DiffColor,float3 LightColor,float Intensity){
    float3 Ln = normalize(IN.LightVec);
    float3 Vn = normalize(IN.WorldEyeVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Hn = normalize(Vn + Ln);
    float4 lv = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    float4 diffContrib = DiffColor * float4((Intensity*lv.y*LightColor + AmbiColor),1);
    float4 specContrib = Ks * lv.z * float4(Intensity*LightColor,0);
    return diffContrib + specContrib;
}

// lamps without falloff
float4 lampPS(vertexOutput IN,uniform float3 LightColor,uniform float Intensity):COLOR{
    return sharedPS(IN,SurfColor,LightColor,Intensity);
}

technique TryTheMouseButton {pass p0 {VertexShader=compile vs_2_0 pushVS(LightDirD);PixelShader=compile ps_2_0 lampPS(LightColorD,LightIntensityD);}
}

