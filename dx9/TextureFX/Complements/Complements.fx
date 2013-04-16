float2 R;
float Amount <float uimin=0;float uimax=1;> =0.2;
float4 GuideHue:COLOR={0.0,0.0,1.0,1.0};
float Conc <string uiname="Color Concentration";float uimin=0.1;float uimax=4.0;> =4;
float DesatCorr <string uiname="Desaturate Correction";float uimin=0.0;float uimax=1.0;> =0.2;
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=NONE;MinFilter=LINEAR;MagFilter=LINEAR;};

#include "ColorSpace.fxh"

float hlerp(float h1,float h2,float v){
    float d = abs(h1 - h2);
    if (d <= 0.5) {
	return (float)lerp(h1,h2,v);
    } else if (h1 < h2) {
	return (float)frac(lerp((h1+1),h2,v));
    } else
	return (float)frac(lerp(h1,(h2+1),v));
}

float3 HSVcomplement(float3 InColor){
    float3 complement=InColor;
    complement.x -=0.5;
    if (complement.x<0.0) {complement.x +=1.0;} // faster than hsv_safe()
    return(complement);
}

float4 ComplementsPS(float2 vp:vpos,
uniform float3 GuideHue,
uniform float Amount,
uniform float Concentrate,
uniform float DesatCorr):COLOR
{
	float2 x=(vp+.5)/R;
    float4 rgbaTex=tex2D(s0,x);
    float3 hsvTex=RGBtoHSV(rgbaTex.rgb);
    float3 huePole1=RGBtoHSV(GuideHue); // uniform
    float3 huePole2=HSVcomplement(huePole1); // uniform
    float dist1=abs(hsvTex.x-huePole1.x); if (dist1>.5)dist1=1-dist1;
    float dist2=abs(hsvTex.x-huePole2.x); if (dist2>.5)dist2=1-dist2;
    float dsc=smoothstep(0,DesatCorr,hsvTex.y);
    float3 newHsv=hsvTex;
    if (dist1 < dist2) {
	float c = dsc*Amount*(1-pow((dist1*2),1/Concentrate));
	newHsv.x=hlerp(hsvTex.x,huePole1.x,c);
	newHsv.y=lerp(hsvTex.y,huePole1.y,c);
    } else {
	float c=dsc*Amount*(1-pow((dist2*2),1/Concentrate));
	newHsv.x=hlerp(hsvTex.x,huePole2.x,c);
	newHsv.y=lerp(hsvTex.y,huePole1.y,c);
    }
    float3 newRGB=HSVtoRGB(newHsv);
    return float4(newRGB.rgb,rgbaTex.a);
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Clamp{pass pp0{AddressU[0]=CLAMP;AddressV[0]=CLAMP;vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 ComplementsPS(GuideHue,Amount,Conc,DesatCorr);}}

