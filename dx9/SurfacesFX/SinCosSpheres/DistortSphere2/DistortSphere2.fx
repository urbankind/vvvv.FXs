//transforms
float4x4 tV:VIEW;
float4x4 tWV:WORLDVIEW;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 TT <String uiname="Transform before function";>;

//material properties
float3 lDir <string uiname="Light Direction";> = {0,-5,2};   
float  lPower <String uiname="Power"; float uimin=0.0;> =25; 
float4 lAmb:COLOR <String uiname="Ambient Color";>  ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float4x4 tColor <string uiname="Color Transform";>;
float time;
float3 count;
float3 phase;
float3 amount;
float radius =1;

//sampler
texture Tex <string uiname="Texture";>;
sampler s0=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

float3 sphere(float u,float v){
    float x = cos(v)*sin(u);
    float y = sin(v)*sin(u);
    float z = cos(u);
    float r = radius;
    r+=sin(0.25*x*count.x+time+phase.x)*amount.x;
    r+=cos(u*count.y+phase.y)*amount.y;
    return float3(x*r, y*r, z*r);
}

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightDirV:TEXCOORD1;
    float3 NormV:TEXCOORD2;
    float3 ViewDirV:TEXCOORD3;
    float3 Pos:TEXCOORD4;
};

#define TWOPI 6.28318531
#define PI 3.14159265
#define gridSpaceX 0.01
#define gridSpaceY 0.01

vs2ps VS(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out=(vs2ps)0;
    PosO=mul(PosO, TT);
    float x,y,z,u,v;
    float u2,v2;
    float3 tang,bitang;
    u = (PosO.x + 0.5) * PI;
    v = (PosO.y + 0.5) * TWOPI;
    u2 = (PosO.x + gridSpaceX + 0.5) * PI;
    v2 = (PosO.y + gridSpaceY + 0.5) * TWOPI;
    PosO.xyz = sphere(u, v);
    tang   = sphere(u2, v);
    bitang = sphere(u, v2);
    tang   -= PosO.xyz;
    bitang -= PosO.xyz;
    NormO = cross(tang, bitang);
    Out.LightDirV = normalize(-mul(lDir, tV));
    Out.NormV = normalize(mul(NormO, tWV));
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

float4 PS(vs2ps In):COLOR{
    lAmb.a = 1;
    float3 H = normalize(In.ViewDirV + In.LightDirV);
    float3 shades = lit(dot(In.NormV, In.LightDirV), dot(In.NormV, H), lPower);
    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float3 R = normalize(2 * dot(In.NormV, In.LightDirV) * In.NormV - In.LightDirV);
    float3 V = normalize(In.ViewDirV);
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;
    float4 col = tex2D(s0, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return mul(col, tColor);
}

technique main {pass p0 {VertexShader=compile vs_3_0 VS();PixelShader=compile ps_2_0 PS();}}
