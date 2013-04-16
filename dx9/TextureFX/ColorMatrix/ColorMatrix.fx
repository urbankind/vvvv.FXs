float2 R;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float Brightness <float UIMin=0.0;float UIMax=5.0;> =1;
float Contrast <float UIMin=-5.0;float UIMax=5.0;> =1;
float Saturation <float UIMin=-5.0;float UIMax =5.0;> =1;
float Hue <float UIMin=0.0;float UIMax=360.0;> =0;

struct vs2ps{
   	float4 Position:POSITION;
    float2 TexCoord0:TEXCOORD0;
    float4x3 colorMatrix:TEXCOORD1;
};

float4x4 scaleMat(float s)
{
	return float4x4(
		s, 0, 0, 0,
		0, s, 0, 0,
		0, 0, s, 0,
		0, 0, 0, 1);
}

float4x4 translateMat(float3 t)
{
	return float4x4(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		t, 1);
}

float4x4 rotateMat(float3 d, float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	d = normalize(d);
	return float4x4(
		d.x*d.x*(1 - c) + c,		d.x*d.y*(1 - c) - d.z*s,	d.x*d.z*(1 - c) + d.y*s,	0,
		d.x*d.y*(1 - c) + d.z*s,	d.y*d.y*(1 - c) + c,		d.y*d.z*(1 - c) - d.x*s,	0, 
		d.x*d.z*(1 - c) - d.y*s,	d.y*d.z*(1 - c) + d.x*s,	d.z*d.z*(1 - c) + c,		0, 
		0, 0, 0, 1 );
}

vs2ps colorControlsVS(float4 Position:POSITION,float2 TexCoord:TEXCOORD0){
    vs2ps OUT = (vs2ps)0;
	Position.xy*=2;TexCoord+=.5/R;
    OUT.Position = Position;
    float2 texelSize = 1/R;
    OUT.TexCoord0 = TexCoord+texelSize*.5;
    float4x4 brightnessMatrix = scaleMat(Brightness);
    float4x4 contrastMatrix = translateMat(-0.5);
    contrastMatrix = mul(contrastMatrix, scaleMat(Contrast) );
    contrastMatrix = mul(contrastMatrix, translateMat(0.5) );
    // saturation
    // weights to convert linear RGB values to luminance
    const float rwgt = 0.3086;
    const float gwgt = 0.6094;
    const float bwgt = 0.0820;
    float s = Saturation;
    float4x4 saturationMatrix = float4x4(
		(1.0-s)*rwgt + s,	(1.0-s)*rwgt,   	(1.0-s)*rwgt,		0,
		(1.0-s)*gwgt, 		(1.0-s)*gwgt + s, 	(1.0-s)*gwgt,		0,
		(1.0-s)*bwgt,    	(1.0-s)*bwgt,  		(1.0-s)*bwgt + s,	0,
		0.0, 0.0, 0.0, 1.0);
	// hue - rotate around (1, 1, 1)
	float4x4 hueMatrix = rotateMat(float3(1, 1, 1), radians(Hue));
//	OUT.colorMatrix = brightnessMatrix;
//	OUT.colorMatrix = contrastMatrix;
//	OUT.colorMatrix = saturationMatrix;
//	OUT.colorMatrix = hueMatrix;

	// composite together matrices
	float4x4 m;
	m = brightnessMatrix;
	m = mul(m, contrastMatrix);
	m = mul(m, saturationMatrix);
	m = mul(m, hueMatrix);
	OUT.colorMatrix = m;
    return OUT;
}

float4 colorControlsPS(vs2ps IN):COLOR{   
	float4 scnColor = tex2D(s0,IN.TexCoord0);
	float4 c;
	// this compiles to 3 dot products:
	c.rgb = mul(half4(scnColor.rgb, 1), (half4x3) IN.colorMatrix);
	c.a = scnColor.a;
	return c;
}  

technique ColorControls {pass p0 {VertexShader=compile vs_2_0 colorControlsVS();PixelShader=compile ps_2_0 colorControlsPS();}}


