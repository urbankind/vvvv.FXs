//transforms
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;

float t:time;
float noiseFreq <float uimin=0.0;float uimax=1.0;float uistep=0.01;> =0.1;
float noiseStrength <float uimin=0.0;float uimax=5.0;float uistep=0.01;> =1;
float timeScale <float uimin=0.0;float uimax=1.0;float uistep=0.01;> =1;
float3 noiseScale =1;
float3 noiseAnim ={0,-0.1,0};
float4 flameColor:COLOR ={0.2,0.2,0.2,1};
float3 flameScale ={1,-1,1};
float3 flameTrans =0;

//samplers
#define VOLUME_SIZE 32
texture Tex0 <string uiname="Noise Texture";>;
sampler3D Samp0=sampler_state{Texture=<Tex0>;MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};
texture Tex1 <string uiname="Texture";>;
sampler2D Samp1=sampler_state{Texture=<Tex1>;MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=Clamp;AddressV=Clamp;};

//vector-valued noise
float4 GenerateNoise4f(float3 Pos:POSITION): COLOR {
	float4 c;
	float3 P = Pos*VOLUME_SIZE;
		c.r = noise(P);
		c.g = noise(P + float3(11, 17, 23));
		c.b = noise(P + float3(57, 93, 65));
		c.a = noise(P + float3(77, 15, 111));
//	return c*0.5+0.5;
	return abs(c);
}

//scalar noise
float GenerateNoise1f(float3 Pos:POSITION): COLOR {
	float3 P = Pos*VOLUME_SIZE;
//	return noise(P)*0.5+0.5;
	return abs(noise(P));
}

struct vertexOutput{
    float4 HPosition:POSITION;
    float3 NoisePos:TEXCOORD0;
    float3 FlamePos:TEXCOORD1;
    float2 UV:TEXCOORD2;
};

vertexOutput flameVS(
	float3 PosO:POSITION,
    float4 UV:TEXCOORD0,
    float4 Tangent:TANGENT0,
    float4 Binormal:BINORMAL0,
    float4 Normal:NORMAL)
{
    vertexOutput OUT;
    float4 objPos = float4(PosO.xyz,1);
    float3 worldPos = mul(objPos, tW).xyz;
    OUT.HPosition = mul(objPos, tWVP);
    float time = fmod(t, 10.0);	// avoid large texcoords
    OUT.NoisePos = worldPos*noiseScale*noiseFreq + time*timeScale*noiseAnim;
	OUT.FlamePos = worldPos*flameScale + flameTrans;
	OUT.UV = UV;
    return OUT;
}

float4 noise3D(uniform sampler3D NoiseMap,float3 P){
//	return tex3D(NoiseMap, P)*2-1;
	return tex3D(NoiseMap, P);
}

float4 turbulence4(uniform sampler3D NoiseMap, float3 P){
	half4 sum = noise3D(NoiseMap,P)*0.5 +
 				noise3D(NoiseMap,P*2)*0.25 +
 				noise3D(NoiseMap,P*4)*0.125 +
				noise3D(NoiseMap,P*8)*0.0625;
	return sum;
}

float4 flamePS(vertexOutput IN):COLOR{
//	return tex3D(NoiseMap,IN.NoisePos) * flameColor;
//  return turbulence4(NoiseMap, IN.NoisePos) * flameColor;
	half2 uv;
	uv.x = length(IN.FlamePos.xz);	// radial distance in XZ plane
	uv.y = IN.FlamePos.y;
//	uv.y += turbulence4(NoiseMap, IN.NoisePos) * noiseStrength;
	uv.y += turbulence4(Samp0,IN.NoisePos)*noiseStrength/uv.x;
	return tex2D(Samp1,uv)*flameColor;
}

technique Fire {pass p0{vertexshader = compile vs_1_1 flameVS();pixelshader = compile ps_2_0 flamePS();}}
