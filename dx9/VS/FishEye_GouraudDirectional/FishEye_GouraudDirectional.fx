//transforms
float4x4 tW:WORLD;       
float4x4 tV:VIEW;         
float4x4 tWV:WORLDVIEW;
float4x4 tP:PROJECTION;  
float4x4 tWVP:WORLDVIEWPROJECTION;

float viewParms <string uiname="View Direction";> = {0.5};

//light properties
float3 lDir <string uiname="Light Direction";> ={0,-5,2};      
float4 lAmb :COLOR <String uiname="Ambient Color";> ={0.15,0.15,0.15,1};
float4 lDiff:COLOR <String uiname="Diffuse Color";> ={0.85,0.85,0.85,1};
float4 lSpec:COLOR <String uiname="Specular Color";> ={0.35,0.35,0.35,1};
float lPower <String uiname="Power"; float uimin=0.0;> =25;    
float4x4 tColor <string uiname="Color Transform";>;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
    float4 Diffuse:COLOR0;
    float4 Specular:COLOR1;
    float  z_value:TEXCOORD1;
};

vs2ps VS(float4 PosO:POSITION,float3 NormO:NORMAL,float4 TexCd:TEXCOORD0){
    vs2ps Out = (vs2ps)0;
    float3 LightDirV = normalize(-mul(lDir,tV));
    float3 NormV = normalize(mul(NormO,tWV));
    float4 PosV = mul(PosO,tWV);
    float3 ViewDirV = normalize(-PosV);
    float3 H = normalize(ViewDirV+LightDirV);
    float3 shades = lit(dot(NormV,LightDirV),dot(NormV,H),lPower);
    float4 diff = lDiff*shades.y;
    diff.a = 1;
    float4 spec = lSpec*shades.z;
    spec.a = 1;

    Out.Pos  = mul(PosV,tP);
    Out.TexCd = mul(TexCd,tTex);
    Out.Diffuse = diff+lAmb;
    Out.Specular = spec;
   
    float direction = viewParms;
	Out.Pos = mul(PosO, tWVP);
	Out.Pos.z = Out.Pos.z * direction;	// set z-values to forward or backward
	float L = length( Out.Pos.xyz );	// determine the distance between (0,0,0) and the vertex
	Out.Pos = Out.Pos  / L;		        // divide the vertex position by the distance
	Out.z_value = Out.Pos.z;		    // remember which hemisphere the vertex is in
	Out.Pos .z = Out.Pos.z + 1;		    // add the reflected vector to find the normal vector
	Out.Pos.x = Out.Pos.x / Out.Pos.z;	// divide x coord by the new z-value
	Out.Pos.y = Out.Pos.y / Out.Pos.z;	// divide y coord by the new z-value
	Out.Pos.z = L / 500;		        // set a depth value for correct z-buffering
	Out.Pos.w = 1;
    return Out;
}

float4 PS(vs2ps In):COLOR{
    clip(In.z_value + 0.5);
    float4 col = tex2D(Samp,In.TexCd);
    col.rgb *= In.Diffuse + In.Specular;
    return mul(col,tColor);
}

technique FishEye {pass P0{VertexShader=compile vs_1_1 VS();PixelShader=compile ps_1_4 PS();}}
