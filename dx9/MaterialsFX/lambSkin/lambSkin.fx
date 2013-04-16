//@author:desaxismundi
//@help:a lambertian-like surface with light "bleed-through"
//@tags:skin,material
//@credits:copyright nVidia corporation

//transforms
float4x4 WorldIT:WorldInverseTranspose;
float4x4 WorldViewProj:WorldViewProjection;
float4x4 World:World;

//material properties
float3 LightPos:POSITION <string UIName="Lamp Position";> ={0.0,0.0,-1.0};
float4 AmbiColor:COLOR <string UIName="Ambient";> ={0.1,0.1,0.1,1.0};
float4 DiffColor:COLOR <string UIName="Surface Diffuse";> ={0.9,1.0,0.9,1.0};
float4 SubColor:COLOR <string UIName="Subsurface \"Bleed-thru\" Color";> ={1.0,0.2,0.2,1.0};
float RollOff <string UIName="Subsurface Rolloff Range";float UIMin=0.0;float UIMax=0.99;> =.2;

//sampler
texture ColorTexture;
sampler2D ColorSampler=sampler_state{Texture=(ColorTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=WRAP;AddressV=WRAP;};

struct shadedvs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float4 diffCol:COLOR0;
};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
};

void lambskin(float3 N,float3 L,out float4 Diffuse,out float4 Subsurface) {
    float ldn = dot(L,N);
    float diffComp = max(0,ldn);
    Diffuse = float4((diffComp*DiffColor).xyz,1);
    float subLamb = smoothstep(-RollOff,1,ldn)-smoothstep(0,1,ldn);
    subLamb = max(0,subLamb);
    Subsurface = subLamb*SubColor;
}

shadedvs2ps lambVS(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL) {
    shadedvs2ps OUT;
    float3 Nn = normalize(mul(Normal,WorldIT).xyz);
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,World).xyz;
    float3 Ln = normalize(LightPos-Pw);
    float4 diffContrib;
    float4 subContrib;
	lambskin(Nn,Ln,diffContrib,subContrib);
    OUT.diffCol = diffContrib+AmbiColor+subContrib;
    OUT.TexCoord = UV;
    OUT.HPosition = mul(Po,WorldViewProj);
    return OUT;
}

vs2ps vs(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL) {
    vs2ps OUT;
    float4 normal = normalize(Normal);
    OUT.WorldNormal = mul(normal,WorldIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,World).xyz;
    OUT.LightVec = normalize(LightPos-Pw);
    OUT.TexCoord = UV;
    OUT.HPosition = mul(Po,WorldViewProj);
    return OUT;
}

void lambPSshared(vs2ps IN,out float4 DiffuseContrib,out float4 SubContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
	lambskin(Nn,Ln,DiffuseContrib,SubContrib);
}

float4 lambPS(vs2ps IN):COLOR{
	float4 diffContrib;
	float4 subContrib;
	lambPSshared(IN,diffContrib,subContrib);
	float4 litC = diffContrib+AmbiColor+subContrib;
	return litC;
}

float4 lambPSt(vs2ps IN):COLOR{
	float4 diffContrib;
	float4 subContrib;
	lambPSshared(IN,diffContrib,subContrib);
	float4 litC = diffContrib+AmbiColor+subContrib;
	return (litC*tex2D(ColorSampler,IN.TexCoord.xy));
}

technique UntexturedVS {pass p0{VertexShader=compile vs_1_1 lambVS();
		// no pixel shader needed
		SpecularEnable = false;
		ColorArg1[ 0 ] = Diffuse;
		ColorOp[ 0 ]   = SelectArg1;
		ColorArg2[ 0 ] = Specular;
		AlphaArg1[ 0 ] = Diffuse;
		AlphaOp[ 0 ]   = SelectArg1;
	}
}

technique TexturedVS {pass p0 {VertexShader=compile vs_1_1 lambVS();
		// no pixel shader needed
		SpecularEnable = false;
	    Texture[0] = <ColorTexture>;
	    MinFilter[0] = Linear;
	    MagFilter[0] = Linear;
	    MipFilter[0] = None;
        ColorArg1[ 0 ] = Texture;
        ColorOp[ 0 ] = Modulate;
        ColorArg2[ 0 ] = Diffuse;}
}

technique UntexturedPS {pass p0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 lambPS();}}
technique TexturedPS {pass p0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 lambPSt();}}

