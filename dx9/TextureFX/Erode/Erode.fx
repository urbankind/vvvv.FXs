float2 R;
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
sampler SampPoint=sampler_state{Texture=(Tex);MipFilter=POINT;MinFilter=POINT;MagFilter=POINT;};
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

float Factor;
bool PointFilter;

float4 psERODE3X3(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  float4 col;
    if (!PointFilter){
       col = tex2D(Samp,x);
    }
    else col = tex2D(SampPoint,x);

    float2 neighbours[8]={
        -1,-1,
        0,-1,
        1,-1,
        -1,0,
        1,0,
        -1,1,
        0,1,
        1,1,
};

    for (int i = 0; i < 8; i++){
        float4 tmpSample;
         if (!PointFilter){
           tmpSample = tex2D(Samp,x+(1/R*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(1/R*Factor)*neighbours[i]);
        col = max(col, tmpSample);}
    	return col;  
    }


float4 psERODE5X5(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  float4 col;
    if (!PointFilter){
       col = tex2D(Samp,x);
    }
    else col = tex2D(SampPoint,x);

    float2 neighbours[12]={
        -1,-2,
        0,-2,
        1,-2,
        -2,-1,
        2,-1,
        -2,0,
        2,0,
        -2,1,
    	2,1,
        -1,2,
        0,2,
    	1,2,
 };

    for (int i = 0; i < 8; i++){
        float4 tmpSample;
         if (!PointFilter){
           tmpSample = tex2D(Samp,x+(1/R*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(1/R*Factor)*neighbours[i]);
        col = max(col, tmpSample);}
   		return col; 
    }

float4 psERODE7X7(float2 vp:vpos):color{float2 x=(vp+.5)/R;
  float4 col;
    if (!PointFilter){
       col = tex2D(Samp,x);
    }
    else col = tex2D(SampPoint,x);

    float2 neighbours[16]={
        -1,3,
        0,-3,
        1,-3,
        -2,-2,
        2,-2,
        -3,-1,
        3,-1,
        -3,0,
    	3,0,
        -3,1,
        3,1,
        -2,-2,
        2,-2,
        -1,3,
        0,3,
        1,3,
};

    for (int i = 0; i < 8; i++){
        float4 tmpSample;
         if (!PointFilter){
           tmpSample = tex2D(Samp,x+(1/R*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(1/R*Factor)*neighbours[i]);
        col = max(col, tmpSample);}
    	return col; 
    }

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Erode3x3 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psERODE3X3();}}
technique Erode5x5 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psERODE5X5();}}
technique Erode7x7 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psERODE7X7();}}

