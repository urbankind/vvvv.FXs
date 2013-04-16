#ifndef NOISE_SCALE
#define NOISE_SCALE 5
#endif /* NOISE_SCALE */
// predefine as 1 for "pure" noise
#ifndef NOISE3D_LIMIT
#define NOISE3D_LIMIT 256
#endif /* NOISE3D_LIMIT */
// function used to fill the volume noise texture
float4 noise_3d(float3 Pos : POSITION):COLOR
{
    float4 Noise = (float4)0;
    for (int i = 1; i < NOISE3D_LIMIT; i += i) {
        Noise.r += (noise(Pos * NOISE_SCALE * i)) / i;
        Noise.g += (noise((Pos + 1)* NOISE_SCALE * i)) / i;
        Noise.b += (noise((Pos + 2) * NOISE_SCALE * i)) / i;
        Noise.a += (noise((Pos + 3) * NOISE_SCALE * i)) / i;
    }
    return (Noise+0.5);
}

#ifndef NOISE_VOLUME_SIZE
#define NOISE_VOLUME_SIZE 32
#endif /* NOISE_VOLUME_SIZE */

texture NoiseTex  <
    string TextureType = "VOLUME";
    string function = "noise_3d";
	string UIName = "3D Noise Texture";
    string UIWidget = "None";
    int width = NOISE_VOLUME_SIZE, height = NOISE_VOLUME_SIZE, depth = NOISE_VOLUME_SIZE;
>;

// samplers
sampler NoiseSamp = sampler_state 
{
    texture = <NoiseTex>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

#define NOISE3D(p) tex3D(NoiseSamp,(p))
#define SNOISE3D(p) (NOISE3D(p)-0.5)
