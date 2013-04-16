float2 R;
float DotsCount = 8.0 ;
texture tex0;
sampler s0=sampler_state {Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
texture DotTex <float3 Dimensions={16.0,16.0,32.0 };string UIName="Dot Volume Texture";>;
sampler3D DotSampler=sampler_state{texture=<DotTex>;AddressU=Wrap;AddressV=Wrap;AddressW=Clamp;MinFilter=Linear;MipFilter=Linear;MagFilter=Linear;};

float4 make_tones(float3 Pos:POSITION, float3 Size:PSIZE):COLOR{
	float2 delta =Pos.xy-float2(.5,.5);
	float d=dot(delta,delta);
	float rSquared=(Pos.z*Pos.z)/2;
	float n2=(d<rSquared)?1:0;
	return float4(n2,n2,n2,1);
	//return float4(Pos,1.0);
}

#define IMG_DIVS 4
#define DOWNSIZE (1/IMG_DIVS)

float4 psTONE1(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 scnC = tex2D(s0,x);
    float lum = dot(float3(.2,.7,.1),scnC.xyz);
    float3 lx = float3((DotsCount*IMG_DIVS*x.xy),lum);
    float4 dotC = tex3D(DotSampler,lx);
    float4 result = float4(dotC.xyz,1.0);
    return result;
}

float4 psTONE2(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 scnC = tex2D(s0,x);
    float lum = dot(float3(.2,.7,.1),scnC.xyz);
    float3 lx = float3((DotsCount*IMG_DIVS*x.xy),lum);
    float4 dotC = tex3D(DotSampler,lx)+tex2D(s0,x);
    float4 result = float4(dotC.xyz,1.0);
    return result;
}

float4 psTONE3(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 scnC = tex2D(s0,x);
    float lum = dot(float3(.2,.7,.1),scnC.xyz);
    float3 lx = float3((DotsCount*IMG_DIVS*x.xy),lum);
    float4 dotC = tex3D(DotSampler,lx)*tex2D(s0,x);
    float4 result = float4(dotC.xyz,1.0);
    return result;
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique tone1{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psTONE1();}}
technique tone2{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psTONE2();}}
technique tone3{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 psTONE3();}}
