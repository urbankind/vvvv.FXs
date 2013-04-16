//@author:desaxismundi
//@tags:blobby,distort
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tWI:WorldInverse;
float4x4 tVI:ViewInverse;

//light
float3 lPos <string UIName="Light Position";> ={1,1,-1};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
float4 AmbiCol:COLOR <string UIName="Ambient Light Color";> ={0.2,0.2,0.2,1.0};
float4 SurfCol:COLOR<string UIName="Surface Color";> ={0.1,0.5,0.4,1.0};

float4 BlobCenter1 = {4.0, 2.0, 3.0,1.0};
float BlobRadius1 <float UIMin=0.1;float UIMax=10.0;> =2;
float BlobGradient1 <float UIMin=0.1;float UIMax=10.0;> =1;
float BlobStrength1 <float UIMin=0.0;float UIMax=1.0;> =1;

//samplers
texture halfAngleMap;
sampler2D halfAngleSampler=sampler_state{Texture=(halfAngleMap);MinFilter=Linear;MagFilter=Linear;MipFilter=None;AddressU=Clamp;AddressV=Clamp;};
texture normalMap;
sampler2D normalSampler=sampler_state{Texture=(normalMap);MinFilter=Linear;MagFilter=Linear;MipFilter=None;AddressU=Clamp;AddressV=Clamp;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord0:TEXCOORD0;
    float4 TexCoord1:TEXCOORD1;
    float4 diffCol:COLOR0;
};

vs2ps theBlobVS(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL){
	vs2ps OUT;
    float3 worldNormal = mul(tWIT,Normal).xyz;
    worldNormal = normalize(worldNormal);
    float4 objSpacePos = float4(Position.x,Position.y,Position.z,1.0);
    float3 worldSpacePos = mul(objSpacePos, tW).xyz;
    // now apply blob
    float3 delta = worldSpacePos - BlobCenter1.xyz;
    float d = sqrt(dot(delta,delta));
    float g1 = min(BlobRadius1,BlobGradient1);
    float ramp = BlobStrength1*(1.0 - smoothstep((BlobRadius1-g1),BlobRadius1,d));
    delta = delta / d;  // in other words, now normalized
    float3 targetPos = BlobCenter1.xyz + BlobRadius1 * delta;
    worldSpacePos = lerp(worldSpacePos,targetPos,ramp);
    float ddw = dot(delta,worldNormal);
    if (ddw<0.0) { delta = -delta; }
    worldNormal = lerp(worldNormal,delta,ramp);
    // now update obj-space pos for later stuff
    float4 temp = float4(worldSpacePos.x,worldSpacePos.y,worldSpacePos.z,1.0);
    objSpacePos = mul(temp, tWI);
    float3 LightVec = normalize(lPos - worldSpacePos);
    float ldn = dot(LightVec,worldNormal);
    float diffComp = max(0,ldn);
    float4 diffContrib = SurfCol * ( diffComp * lCol + AmbiCol);
    OUT.diffCol = diffContrib;
    OUT.diffCol.w = 1.0;
    // OUT.TexCoord2 = IN.UV;
    float3 EyePos = tVI[3].xyz;
    float3 vertToEye = normalize(EyePos - worldSpacePos);
    float3 halfAngle = normalize(vertToEye + LightVec);
    float4 halfIndices = float4(0.5+dot(LightVec,halfAngle)/2.0,0.5+dot(worldNormal,halfAngle)/2.0,0.0,1.0);
    float4 normIndices = float4(0.5+dot(LightVec,worldNormal)/2.0,0.5+dot(worldNormal,vertToEye)/2.0,0.0,1.0);
    OUT.TexCoord0 = halfIndices;
    OUT.TexCoord1 = normIndices;
    //transform into homogeneous-clip space
    OUT.HPosition = mul(objSpacePos, tWVP);
    return OUT;
}

float4 theBlobCTPS(vs2ps IN):COLOR {
    float4 nspec = tex2D(halfAngleSampler,IN.TexCoord0.xy) * 
				   tex2D(normalSampler,IN.TexCoord1.xy) * lCol;
    float4 result = IN.diffCol + nspec;
    return result;
}

technique ps11 {pass p0{VertexShader=compile vs_1_1 theBlobVS();PixelShader=compile ps_1_1 theBlobCTPS();}}
