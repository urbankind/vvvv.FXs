//@author:desaxismundi
//@help:3d noise on the vertex shader
//@tags:vnoise
//@credits:copyright nVidia corporation

//transforms
float4x4 WorldViewProj:WORLDVIEWPROJECTION;
float4x4 NoiseMatrix = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

float timer;
float Displacement <float UIMin=0.0;float UIMax=2.0;> =1;
float Sharpness <float UIMin = 0.1;float UIMax = 5.0;> =1;
float4 dd[5] = {0,2,3,1, 2,2,2,2, 3,3,3,3, 4,4,4,4, 5,5,5,5 };

struct vs2ps{
    float4 HPosition:POSITION;
    float4 Color0:COLOR0;
};

#include "vnoise-table.fxh"
#include "vnoise.fxh"

vs2ps VS1(float4 Position:POSITION,float4 Normal:NORMAL,float4 TexCoord0:TEXCOORD0) {
    vs2ps OUT;
    float4 noisePos = mul(Position+timer,NoiseMatrix);
    float i = (vnoise3D(noisePos.xyz, NTab) + 1.0f) * 0.5f;
    OUT.Color0 = float4(i, i, i, 1.0f);
    // displacement along normal
    i = i - 0.5;
    i = sign(i) * pow(i,Sharpness);
    float4 position = Position + (Normal * i * Displacement);
    position.w = 1.0f;
    OUT.HPosition = mul(position,WorldViewProj);
    return OUT;
}

vs2ps VS2(float4 Position:POSITION,float4 Normal:NORMAL,float4 TexCoord0:TEXCOORD0) {
    vs2ps OUT;
    float4 noisePos = mul(Position+timer,NoiseMatrix);
    float i = (vnoise2D(noisePos.xyz, NTab) + 1.0f) * 0.5f;
    OUT.Color0 = float4(i, i, i, 1.0f);
    // displacement along normal
    i = i - 0.5;
    i = sign(i) * pow(i,Sharpness);
    float4 position = Position + (Normal * i * Displacement);
    position.w = 1.0f;
    OUT.HPosition = mul(position,WorldViewProj);
    return OUT;
}

vs2ps VS3(float4 Position:POSITION,float4 Normal:NORMAL,float4 TexCoord0:TEXCOORD0) {
    vs2ps OUT;
    float4 noisePos = mul(Position+timer,NoiseMatrix);
    float i = (vnoise1D(noisePos.xyz, NTab) + 1.0f) * 0.5f;
    OUT.Color0 = float4(i, i, i, 1.0f);
    // displacement along normal
    i = i - 0.5;
    i = sign(i) * pow(i,Sharpness);
    float4 position = Position + (Normal * i * Displacement);
    position.w = 1.0f;
    OUT.HPosition = mul(position,WorldViewProj);
    return OUT;
}

technique Tvnoise3D {pass p0{VertexShader = compile vs_2_0 VS1();}}
technique Tvnoise2D {pass p0{VertexShader = compile vs_2_0 VS2();}}
technique Tvnoise1D {pass p0{VertexShader = compile vs_2_0 VS3();}}

