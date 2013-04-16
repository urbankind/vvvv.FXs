//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:bubble, vnoise
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;
float4x4 TT;
float gridSpaceX;
float gridSpaceY;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

//material properties
float reflectStrength <string UIName="Reflection";float UIMin=0.0;float UIMax=2.0;> =1;
float refractStrength <string UIName="Refraction";float UIMin=0.0;float UIMax=2.0;> =1;
float3 etas <string UIName="Refraction indices";> ={0.80,0.82,0.84 };
float TurbDensity <string uiname="Turbulence Density";float UIMin=0.01;float UIMax=8.0;> =2.27;
float Disp <string uiname="Displacement";float UIMin=0.0;float UIMax=2.0;> =1.6;
float Sharp <string uiname="Sharpness";float UIMin=0.1;float UIMax=5.0;> =1.9;
float timer:TIME;
float Speed <float UIMin=0.01;float UIMax=1.0;> =.3;
float radius <string uiname="Sphere Radius";> =1;
//float4 dd[5] ={0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5};

//samplers
texture Tex <string uiname="CubeTexture";>;
samplerCUBE Samp=sampler_state{Texture=(Tex);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};
texture Tex2 <string uiname="FresnelTexture";>;
sampler2D Samp2=sampler_state{Texture=(Tex2);MinFilter=Linear;MagFilter=Linear;MipFilter=None;
//float2 Dimensions < { 256.0f, 1.0f};
};

float3 sphere(float u,float v){
    float x=radius*cos(v)*sin(u);
    float y=radius*sin(v)*sin(u);
    float z=radius*cos(u);
    return float3(x,y,z);
}

#define TWOPI 6.28318531
#define PI 3.14159265
#include "vnoise-table.fxh"
#include "vnoise.fxh"

float3 vNoiseFunc3D(float u,float v){
    float4 PosO = float4(sphere(u, v), 1);
    float4 noisePos = TurbDensity*mul(PosO+(Speed*timer),NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz,NTab)+1)*.5;
    // displacement along normal
    float ni = pow(abs(i),Sharp);
    i -=.5;
    //i = sign(i) * pow(i,Sharpness);
    // we will use our own "normal" vector because the default geom is a sphere
    float4 Nn = float4(normalize(PosO).xyz,0);
    return  PosO-(Nn*(ni-.5)*Disp);
}

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 WorldNormal:TEXCOORD1;
    float3 WorldView:TEXCOORD2;
};

vs2ps vsBUBBLE3D(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
	float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;
	
    vs2ps OUT=(vs2ps)0;
    PosO=mul(PosO,TT);
    u=(PosO.x+.5)*PI;
    v=(PosO.y+.5)*TWOPI;
    u2=(PosO.x+gridSpaceX+.5)*PI;
    v2=(PosO.y+gridSpaceY+.5)*TWOPI;
   
    PosO.xyz=vNoiseFunc3D(u,v);
    tang=vNoiseFunc3D(u2,v);
    bitang=vNoiseFunc3D(u,v2);
    tang -=PosO.xyz;
    bitang -=PosO.xyz;
    NormO=cross(tang,bitang);
  
    OUT.WorldNormal=mul(NormO,(float3x3)tWIT);
    float3 Pw=mul(PosO,tW).xyz;
    OUT.TexCoord=TexCd;
    OUT.WorldView=tVI[3].xyz-Pw;
    OUT.HPosition=mul(PosO,tWVP);
    return OUT;
}

//modified refraction function that returns boolean for total internal reflection
float3 refract2( float3 I,float3 N,float eta,out bool fail){
	float IdotN=dot(I,N);
	float k=1-eta*eta*(1-IdotN*IdotN);
	//return k < 0 ? (0,0,0) : eta*I - (eta*IdotN + sqrt(k))*N;
	fail=k<0;
	return eta*I-(eta*IdotN+sqrt(k))*N;
}
//approximate Fresnel function
float fresnel(float NdotV, float bias, float power){return bias+(1-bias)*pow(1-max(NdotV,0),power);}
//function to generate a texture encoding the Fresnel function
float4 generateFresnelTex(float NdotV:POSITION):COLOR{return fresnel(NdotV,.2,4);}

float4 ps(vs2ps IN):COLOR{
    float3 N=normalize(IN.WorldNormal);
    float3 V=normalize(IN.WorldView);
    float3 R=reflect(-V,N);
    float4 reflColor=texCUBE(Samp,R);
	//half fresnel = fresnel(dot(N, V), 0.2, 4.0);
	float fresnel=tex2D(Samp2,dot(N,V));
	//wavelength colors
	const float4 colors[3]={
    	{1,0,0,0},
    	{0,1,0,0},
    	{0,0,1,0},
	};
	// transmission
 	float4 transColor=0;
  	bool fail=false;
    for(int i=0; i<3; i++) {
    	float3 T=refract2(-V,N,etas[i],fail);
    	transColor +=texCUBE(Samp,T)*colors[i];
	}
    return lerp(transColor*refractStrength,reflColor*reflectStrength,fresnel);
}

technique Bubble3Dnoise {pass p0 {VertexShader=compile vs_3_0 vsBUBBLE3D();PixelShader=compile ps_2_0 ps();}}
