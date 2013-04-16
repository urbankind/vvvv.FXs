float2 R;
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state {Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};
sampler SampPoint=sampler_state{Texture=(Tex);MipFilter=POINT;MinFilter=POINT;MagFilter=POINT;};
bool PointFilter;
float Factor;

float4 psDILATE3X3(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 col;
	float2 Pixelsize= 1/R;	
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
           tmpSample = tex2D(Samp,x+(Pixelsize*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(Pixelsize*Factor)*neighbours[i]);
        col = min(col, tmpSample);}
    	return col;  
    }


float4 psDILATE5X5(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 col;
	float2 Pixelsize= 2/R;	
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
           tmpSample = tex2D(Samp,x+(Pixelsize*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(Pixelsize*Factor)*neighbours[i]);
        col = min(col,tmpSample);}
   		return col; 
    }

float4 psDILATE7X7(float2 vp:vpos):color{float2 x=(vp+.5)/R;
	float4 col;
	float2 Pixelsize= 2/R;	
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
           tmpSample = tex2D(Samp,x+(Pixelsize*Factor)*neighbours[i]);
        }
        else tmpSample = tex2D(SampPoint,x+(Pixelsize*Factor)*neighbours[i]);
        col = min(col,tmpSample);}
    	return col; 
    }

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}

technique Dilate3x3 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psDILATE3X3();}}
technique Dilate5x5 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psDILATE5X5();}}
technique Dilate7x7 {pass P0 {VertexShader = compile vs_1_1 vs2d();PixelShader = compile ps_3_0 psDILATE7X7();}}
