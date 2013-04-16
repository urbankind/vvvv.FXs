//@author:desaxismundi
//@help:woodlike material
//@tags:wood,material
//@credits:copyright nVidia corporation

//transforms
float4x3 tWV:WORLDVIEW;
float4x4 tP:PROJECTION;

//material properties
float3 lDir <string UIName="Light Direction";> ={0.577,-0.577,0.577};
float4 lAmb:COLOR <string UIName="Ambient Color";> ={0.3,0.3,0.3,1.0};
float4 lDiff:COLOR <string UIName="Diffuse Color";> ={1.0,1.0,1.0,1.0};
float4 lSpec:COLOR <string UIName="Specular Color";> ={0.6,0.6,0.6,1.0};
float4 k_a:COLOR <string UIName="AmbientReflexionColor";> ={0.2,0.2,0.2,1.0};
float4 k_d:COLOR <string UIName="DiffuseReflexionColor";> ={1.0,0.7,0.2,1.0};
float4 k_s:COLOR <string UIName="SpecularReflexionColor";> ={1.0,1.0,1.0,1.0};
int n:SPECULARPOWER=64;  // power

//samplers
texture LinearTexture;
sampler Samp=sampler_state{texture=<LinearTexture>;AddressU=WRAP;AddressV=WRAP;AddressW=WRAP;MIPFILTER=LINEAR;MINFILTER=LINEAR;MAGFILTER=LINEAR;};
texture NoiseTexture;
sampler Samp1=sampler_state{texture=<NoiseTexture>;AddressU=WRAP;AddressV=WRAP;AddressW=WRAP;MIPFILTER=LINEAR;MINFILTER= LINEAR;MAGFILTER=LINEAR;};

#define DARK .3
#define LIGHT 1
//model dependent wood parameters
#define RINGSCALE 10
#define POINTSCALE 2
#define TURBULENCE 1
#define VOLUME_SIZE 32
float PointScale=POINTSCALE;
float RingScale=RINGSCALE;
float Turbulence=TURBULENCE;

float4 Linear(float2 Pos:POSITION):COLOR{return float4(Pos, Pos);
}

float4 GenerateNoise(float3 Pos:POSITION):COLOR{
    float4 Noise = (float4)0;
    for (int i = 1; i < 256; i += i)
    {
        Noise.r += abs(noise(Pos*500*i))/i;
        Noise.g += abs(noise((Pos+1)*500*i))/i;
        Noise.b += abs(noise((Pos+2)*500*i))/i;
        Noise.a += abs(noise((Pos+3)*500*i))/i;
    }   
    return Noise;
}

struct vs2ps{
    float4 Pos:POSITION;
    float3 Diff:COLOR0;
    float3 Spec:COLOR1;
    float3 Tex0:TEXCOORD0;               
    float3 Tex1:TEXCOORD1;               
    float2 Tex2:TEXCOORD2;               
};

vs2ps vs(float3 Pos:POSITION,float3 Norm:NORMAL){
    vs2ps Out=(vs2ps)0;
    float3 L = -lDir;
    float3 P = mul(float4(Pos,1),(float4x3)tWV);    // position (view space)
    float3 N = normalize(mul(Norm,(float3x3)tWV));   // normal (view space)
    float3 R = normalize(2*dot(N,L)*N-L);      // reflection vector (view space)
    float3 V = -normalize(P);                         // view direction (view space)
    Out.Pos  = mul(float4(P,1),tP);             // position (projected)
    Out.Diff = lAmb*k_a+lDiff*k_d*max(0,dot(N,L)); // diffuse + ambient
    Out.Spec = lSpec*k_s*pow(max(0,dot(R,V)),n/4);   // specular
    Out.Tex1 = .5*Pos*PointScale; 
    Out.Tex0 = Out.Tex1*Turbulence;        
    Out.Tex2 = RingScale*length(Out.Tex1.xz);
    return Out;
}

float4 psWOOD(vs2ps In):COLOR{
    float4 Color;
    float3 PP = In.Tex1+.2*(tex3D(Samp1,frac(In.Tex1))-.5);
    float r;

    r = RINGSCALE*length(PP.xz);
    r += .1*tex3D(Samp1,r);
    r = frac(r);

    Color.rgb = In.Diff*lerp(DARK,LIGHT,saturate(.8-.6*r))
              + In.Spec;
    Color.w   = 1;
    return Color;
}  

technique Woodc {pass P0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_2_0 psWOOD();}}

