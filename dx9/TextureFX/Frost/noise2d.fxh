
#ifndef _H_NOISE2D
#define _H_NOISE2D

#ifndef NOISE2D_SCALE
#define NOISE2D_SCALE 5
#endif /* NOISE2D_SCALE */

// define as "1" for "pure" noise
#ifndef NOISE2D_LIMIT
#define NOISE2D_LIMIT 256
#endif /* NOISE2D_LIMIT */

// function used to fill the volume noise texture
float4 noise_2d(float2 Pos : POSITION) : COLOR
{
    float4 Noise = (float4)0;
    for (int i = 1; i < NOISE2D_LIMIT; i += i) {
        Noise.r += (noise(Pos * NOISE2D_SCALE * i)) / i;
        Noise.g += (noise((Pos + 1)* NOISE2D_SCALE * i)) / i;
        Noise.b += (noise((Pos + 2) * NOISE2D_SCALE * i)) / i;
        Noise.a += (noise((Pos + 3) * NOISE2D_SCALE * i)) / i;
    }
    return (Noise + 0.5);
}

#ifndef NOISE_SHEET_SIZE
#define NOISE_SHEET_SIZE 128
#endif /* NOISE_SHEET_SIZE */

#ifndef NOISE2D_FORMAT
#define NOISE2D_FORMAT "A8B8G8R8"
#endif /* NOISE2D_FORMAT */

texture Noise2DTex  <
    string TextureType = "2D";
    string function = "noise_2d";
    string Format = (NOISE2D_FORMAT);
	string UIName = "2D Noise Texture";
    string UIWidget = "None";
    int width = NOISE_SHEET_SIZE, height = NOISE_SHEET_SIZE;
>;

// samplers
sampler Noise2DSamp = sampler_state 
{
    texture = <Noise2DTex>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

#define NOISE2D(p) tex2D(Noise2DSamp,(p))
#define SNOISE2D(p) (NOISE2D(p)-0.5)

#endif /* _H_NOISE2D */

