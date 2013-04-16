//@author:desaxismundi
//@tags:surfaces,phong,3D
//http://local.wasp.uwa.edu.au/~pbourke/surfaces_curves/
//http://mathworld.wolfram.com/topics/Surfaces.html

//transforms
float4x4 tV:VIEW;        
float4x4 tWV:WORLDVIEW;
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 TT;

float viewParms <string uiname="Fish Eye direction";> = {0.5};	// ***.z = 1 for forward hemisphere, = -1 for backward hemisphere

//light properties
float3 lDir <string uiname="Light Direction";> ={0,-5,2};       
float4 lAmb:COLOR <String uiname="Ambient Color";> ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float lPower <String uiname="Power"; float uimin=0.0;> =25;   
float4x4 tColor <string uiname="Color Transform";>;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 PosWVP:POSITION;
    float4 TexCd:TEXCOORD0;
    float3 LightDirV:TEXCOORD1;
    float2 UV:TEXCOORD2;
    float3 ViewDirV:TEXCOORD3;
    float3 Pos:TEXCOORD4;
	float  z_value:TEXCOORD5;
};

#include "surfaces.fxh"

float gridSpaceX;
float gridSpaceY;

float gridOffsetX;
float gridOffsetY;

float gridScaleX = 1;
float gridScaleY = 1;

////////////////////////////////////////////////////////////////////////
vs2ps vsFIGURE8TORUS(float4 PosO:POSITION,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    PosO = mul(PosO,TT);
    
    float x,y,z,u,v,pi;
    gridScaleX *= -PI;
    gridScaleY *= PI ;

    u = (PosO.x+gridOffsetX)*gridScaleX;
    v = (PosO.y+gridOffsetY)*gridScaleY;
    Out.UV = float2(u,v);
	
    PosO.xyz=Figure8Torus(u,v);
    PosO.w=1;

    Out.LightDirV = normalize(-mul(lDir,tV));
    Out.PosWVP = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.ViewDirV = -normalize(mul(PosO,tWV));
	
    float direction = viewParms;		        // this determines the front or back hemisphere

   	// divide by w to normalize
	Out.PosWVP = mul(PosO,tWVP);
	Out.PosWVP.z = Out.PosWVP.z*direction;	// set z-values to forward or backward
	float L = length(Out.PosWVP.xyz);	        // determine the distance between (0,0,0) and the vertex
	Out.PosWVP = Out.PosWVP/L;		        // divide the vertex position by the distance
	Out.z_value = Out.PosWVP.z;		            // remember which hemisphere the vertex is in
	Out.PosWVP.z = Out.PosWVP.z+1;		    // add the reflected vector to find the normal vector
	Out.PosWVP.x = Out.PosWVP.x/Out.PosWVP.z;	// divide x coord by the new z-value
	Out.PosWVP.y = Out.PosWVP.y/Out.PosWVP.z;	// divide y coord by the new z-value
	Out.PosWVP.z = L/500;		                // set a depth value for correct z-buffering
	Out.PosWVP.w = 1;
	return Out;
}

/////////////////////////////////////////////////////////
float4 psFIGURE8TORUS(vs2ps In):COLOR{
    float u1,v1,u2,v2;
    float3 tang,bitang;
    float3 NormO,NormV;
    //to get neighbour in u direction
    u1 = In.UV.x + gridSpaceX; //(In.PosO.x + gridSpaceX + gridOffsetX) * gridScaleX;
    u2 = In.UV.x - gridSpaceX; //(In.PosO.x - gridSpaceX + gridOffsetX) * gridScaleX;
    //to get neighbour in v direction
    v1 = In.UV.y + gridSpaceY; //(In.PosO.y + gridSpaceY + gridOffsetY) * gridScaleY;
    v2 = In.UV.y - gridSpaceY; //(In.PosO.y - gridSpaceY + gridOffsetY) * gridScaleY;
    //get tangents
    tang   = (Figure8Torus(u1, In.UV.y) - Figure8Torus(u2, In.UV.y));
    bitang = (Figure8Torus(In.UV.x, v1) - Figure8Torus(In.UV.x, v2));
    //get normal
    NormO = cross(tang, bitang);
    //normal in view space
    NormV = mul(float4(NormO, 0), tWV);
    NormV = normalize(NormV);
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0
    lAmb.a = 1;
    //halfvector
    float3 H = normalize(In.ViewDirV + In.LightDirV);
    //compute blinn lighting
    float3 shades = lit(dot(NormV, In.LightDirV), dot(NormV, H), lPower);
    float4 diff = lDiff * shades.y;
    diff.a = 1;
    //reflection vector (view space)
    float3 R = normalize(2 * dot(NormV, In.LightDirV) * NormV - In.LightDirV);
    //normalized view direction (view space)
    float3 V = normalize(In.ViewDirV);
    //calculate specular light
    float4 spec = pow(max(dot(R, V),0), lPower*.2) * lSpec;
    float4 col = tex2D(Samp, In.TexCd);
    col.rgb *= (lAmb + diff) + spec;
    return mul(col, tColor);
}


technique TFigure8Torus {pass P0{VertexShader=compile vs_1_1 vsFIGURE8TORUS();PixelShader = compile ps_2_a psFIGURE8TORUS();}}
