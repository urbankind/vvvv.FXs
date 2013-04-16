//@author:desaxismundi
//@tags:metal,reflection,flakes,material 
//@credits:copyright nVidia corporation

//transforms
float4x3 tWV:WORLDVIEW;
float4x4 tP:PROJECTION;

//material properties
float3 lDir < string UIName="Light Direction"; > =normalize(float3(0.397,0.397,1.027));
float4 lAmb:COLOR < string UIName="Ambient Color"; > ={0.3,0.3,0.3,1.0 };
float4 lDiff:COLOR < string UINam ="Diffuse Color"; > ={1.0,1.0,1.0,1.0 };
float4 lSpec:COLOR < string UIName="Specular Color"; > ={0.7,0.7,0.7,1.0 };
float4 k_a:COLOR <string UIName="Ambien Metal Color";> ={0.2,0.2,0.2,1.0};
float4 k_d:COLOR <string UIName="Diffuse Metal Color";> ={0.1,0.1,0.9,1.0};
float4 k_s:COLOR <string UIName="Specular Metal Color";> ={0.6,0.5,0.1,1.0};
float4 k_r:COLOR <string UIName="Specular Wax Color";> ={0.7,0.7,0.7,1.0};

//sparkle parameters
#define SPRINKLE    1
#define SCATTER     0.5
#define VOLUME_NOISE_SCALE  10

//samplers
texture Tex < string UIName="EnvironmentMapTexture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
//procedural texture that contains a normal map used for the metal sparkles
texture Tex1 <string UIName="NoiseVolumeTexture";
float3 Dimensions={32.0,32.0,32.0};>;
sampler Samp1=sampler_state{Texture=(Tex1);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

// function used to fill the volume noise texture
float4 GenerateSparkle(float3 Pos:POSITION):COLOR{
    float4 Noise = (float4)0;
    //scatter the normal (in vertex space) based on SCATTER
    Noise.rgb = float3(1 - SCATTER * abs(noise(Pos * 500)), SCATTER * noise((Pos + 1) * 500), SCATTER * noise((Pos + 2) * 500));
    Noise.rgb = normalize(Noise.rgb);
    // set the normal to zero with a probability based on SPRINKLE
    if (SPRINKLE < abs(noise(Pos * 600)))
    Noise.rgb = 0;
    // bias the normal
    Noise.rgb = (Noise.rgb + 1)/2;
    // diffuse noise
    Noise.w = abs(noise(Pos * 500)) * 0.0 + 1.0;
    return Noise;
}

struct vs2ps{
    float4 Pos:POSITION;
    float3 Diff:COLOR0;
    float3 Spec:COLOR1;
    float3 Ref:TEXCOORD0;
    float3 NCd:TEXCOORD1;
    float3 Gloss:TEXCOORD2;
    float3 HfVec:TEXCOORD3;
};

vs2ps vs(float3 PosO:POSITION,float3 NormO:NORMAL,float3 Tang:TANGENT0){
    vs2ps Out=(vs2ps)0;
    lDir = -lDir;
    float3 P = mul(float4(PosO, 1), (float4x3)tWV);   // position (view space)
    float3 N = normalize(mul(NormO, (float3x3)tWV));  // normal (view space)
    float3 T = normalize(mul(Tang, (float3x3)tWV));   // tangent (view space)
    float3 B = cross(N, T);                           // binormal (view space)
    float3 R = normalize(2 * dot(N, lDir) * N - lDir);// reflection vector (view space)
    float3 V = -normalize(P);                         // view direction (view space)
    float3 G = normalize(2 * dot(N, V) * N - V);      // glance vector (view space)
    float3 H = normalize(lDir + V);                   // half vector (view space)
    float  f = 0.5 - dot(V, N); f = 1 - 4 * f * f;    // fresnel term

    //position (projected)
    Out.Pos = mul(float4(P, 1), tP);
    //diffuse + ambient (metal)
    Out.Diff = lAmb * k_a + lDiff * k_d * max(0, dot(N, lDir));
    //specular (wax)
    Out.Spec  = saturate(dot(H, N));
    Out.Spec *= Out.Spec;
    Out.Spec *= Out.Spec;
    Out.Spec *= Out.Spec;
    Out.Spec *= Out.Spec;
    Out.Spec *= Out.Spec;
    Out.Spec *= k_r;
    //glossiness (wax)
    Out.Gloss = f * k_r;
    //transform half vector into vertex space
    Out.HfVec = float3(dot(H, N), dot(H, B), dot(H, T));
    Out.HfVec = (1 + Out.HfVec) / 2;  // bias
    //environment cube map coordinates
    Out.Ref = float3(-G.x, G.y, -G.z);
    //volume noise coordinates
    Out.NCd = PosO * VOLUME_NOISE_SCALE;
    return Out;
}

float4 ps(vs2ps In):COLOR{   
    float4 Color = (float4)0;
    float3 Diffuse, Specular, Gloss, Sparkle;
    //volume noise
    float4 Noise = tex3D(Samp1, In.NCd);
    // noisy diffuse of metal
    Diffuse = In.Diff * Noise.a;
    //glossy specular of wax
    Specular  = In.Spec;
    Specular *= Specular;
    Specular *= Specular;  
    //glossy reflection of wax 
    Gloss = texCUBE(Samp, In.Ref) * saturate(In.Gloss);
    //specular sparkle of flakes
    Sparkle  = saturate(dot((saturate(In.HfVec) - 0.5) * 2, (Noise.rgb - 0.5) * 2));
    Sparkle *= Sparkle;
    Sparkle *= Sparkle;
    Sparkle *= Sparkle;                                                                    
    Sparkle *= k_s;      
    //combine the contributions
    Color.rgb = Diffuse + Specular + Gloss + Sparkle;
    Color.w   = 1;
    return Color;
}  

technique TMetallicFlakes {pass P0{VertexShader=compile vs_1_1 vs();PixelShader=compile ps_1_1 ps();}}
