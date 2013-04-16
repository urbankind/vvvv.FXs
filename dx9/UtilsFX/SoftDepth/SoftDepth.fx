//transforms
float4x4 tWIT:WORLDINVERSETRANSPOSE;
float4x4 tWVP:WORLDVIEWPROJECTION;

float Near <float UIMin=0.001;float UIMax=70.0;> =1;
float Far <float UIMin=0.3;float UIMax=120.0;> =10;

struct vs2ps{
    float4 Pos:POSITION;
    float4 col:COLOR0;
    float4 Norm:NORMAL;
};

vs2ps vs(vs2ps In,float4 Pos:POSITION,float2 TexC:TEXCOORD){
    vs2ps Out = (vs2ps)0;
    float4 Po = float4(Pos.xyz,1);
    float4 Ph = mul(Po,tWVP);
    Out.Pos = Ph;
    // these three could be "static"
    float TrueFar = max(Near,Far);
    float TrueNear = min(Near,Far);
    float DepthRange = max((TrueFar-TrueNear),0.01);
    float g = (Ph.z-TrueNear)/DepthRange;
    Out.col = float4(g,g,g,1.0);
    //transform position
    Pos = mul(Pos,tWVP);
    Out.Pos = Pos;
    return Out;
}

float4 ps(float2 TexC:TEXCOORD0,float4 dist:COLOR0):COLOR{
    float4 col=dist;
    col.a=1;
    return col;
}

technique Depth {pass p0 {VertexShader=compile vs_3_0 vs();PixelShader=compile ps_1_4 ps();}}
