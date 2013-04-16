//@author:desaxismundi
//@tags:cage,checker,debug
//@credits:copyright nVidia corporation

//transforms
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;

#define STRIPE_TEX_SIZE 128
#define DEFAULT_BALANCE (0.5)

float4 BriCol:COLOR <string uiname="Wire Color";> ={1.0,0.8,0.0,1.0};
float4 EmpCol:COLOR <string uiname="Empty Space Color";> ={0.0,0.0,0.0,0.0};
float Bal <string uiname="Relative Width of Wire";float uimin=0.0;float uimax=1.0;> =.1;
float Scale <string uiname="Size of Pattern";float uimin=0.0;float uimax=20.0;> =5.1;

//sampler
texture Tex  <string uiname="Texture";>;
sampler2D Samp=sampler_state{Texture = (Tex);MinFilter=Linear;MipFilter=Linear;MagFilter=Linear;AddressU=Wrap;AddressV=Clamp;};

//base function: "Balance" is in W term
float stripe(float4 XYZW){return tex2D(Samp,XYZW.xw).x;}
float stripe(float4 XYZW,float Balance) {return stripe(float4(XYZW.xyz,Balance));}
float stripe(float3 XYZ,float Balance) {return stripe(float4(XYZ.xyz,Balance));}
float stripe(float2 XY,float Balance) {return stripe(float4(XY.xyy,Balance));}
float stripe(float X,float Balance) {return stripe(float4(X.xxx,Balance));}

//use default balance (can't do float4 version, would interfere): //
float stripe(float3 XYZ) {return stripe(float4(XYZ.xyz,DEFAULT_BALANCE));}
float stripe(float2 XY) {return stripe(float4(XY.xyy,DEFAULT_BALANCE));}
float stripe(float X) {return stripe(float4(X.xxx,DEFAULT_BALANCE));}

float checker3D(float4 XYZW){
    float stripex = tex2D(Samp,XYZW.xw).x;
    float stripey = tex2D(Samp,XYZW.yw).x;
    float stripez = tex2D(Samp,XYZW.zw).x;
    float check = abs(abs(stripex-stripey)-stripez);
    return check;
}

float checker3D(float3 XYZ,float Balance) {return checker3D(float4(XYZ.xyz,Balance));}
float checker3D(float4 XYZW,float Balance) {return checker3D(float4(XYZW.xyz,Balance));}

float checker3D(float3 XYZ) {return checker3D(float4(XYZ.xyz,DEFAULT_BALANCE));}
float checker3D(float2 XY) {return checker3D(float4(XY.xyy,DEFAULT_BALANCE));}
float checker3D(float X) {return checker3D(float4(X.xxx,DEFAULT_BALANCE));}

/////////////
float3 checker3Drgb(float4 XYZW){
    float3 result;
    result.x = tex2D(Samp,XYZW.xw).x;
    result.y = tex2D(Samp,XYZW.yw).x;
    result.z = tex2D(Samp,XYZW.zw).x;
    return result;
}

float3 checker3Drgb(float3 XYZ,float Balance) {return checker3Drgb(float4(XYZ.xyz,Balance));}
float3 checker3Drgb(float3 XYZ) {return checker3Drgb(float4(XYZ.xyz,DEFAULT_BALANCE));}

//procedural texture
float4 MakeStripeTex(float2 Pos : POSITION,float ps : PSIZE):COLOR{
   float v = 0;
   float nx = Pos.x+ps; // keep the last column full-on, always
   v = nx > Pos.y;
   return float4(v.xxxx);
}

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
};

vs2ps VS(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 Norm:NORMAL){
    vs2ps OUT;
    float4 Po = float4(PosO.xyz,1.0);
    float4 hpos  = mul(Po,tWVP);
    OUT.Pos  = hpos;
    float4 Pw = mul(Po,tW);
    OUT.TexCd = Pw * Scale;
    return OUT;
}

float4 PS(vs2ps IN):COLOR{
    float stripex =tex2D(Samp,float2(IN.TexCd.x,Bal)).x;
    float stripey =tex2D(Samp,float2(IN.TexCd.y,Bal)).x;
    float stripez = tex2D(Samp,float2(IN.TexCd.z,Bal)).x;
    float check = stripex * stripey * stripez;
    float4 dColor = lerp(BriCol,EmpCol,check);
    return dColor;
}

technique cage {pass p0{VertexShader = compile vs_2_0 VS();PixelShader = compile ps_2_a PS();}}
