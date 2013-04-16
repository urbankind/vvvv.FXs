float2 R;
float amount=.5;
float4 Rf:COLOR<string uiname="RedFilter";> ={1.0,0.0,0.0,1.0};
float4 Gf:COLOR<string uiname="GreenFilter";> ={0.0,1.0,0.0,1.0};
float4 Bf:COLOR<string uiname="BlueFilter";> ={0.0,0.0,1.0,1.0};
float4 ROf:COLOR<string uiname="RedOrangeFilter";> ={.99,0.263,0.0,1.0};
float4 BGf:COLOR<string uiname="BlueGreenFilter";> ={0.0,1.0,0.7,1.0};
float4 Cf:COLOR<string uiname="CyanFilter";> ={0.0,1.0,0.5,1.0};
float4 Mf:COLOR<string uiname="MagentaFilter";> ={1.0,0.0,0.25,1.0};
float4 Yf:COLOR<string uiname="YellowFilter";> ={1.0,1.0,0.0,1.0};
texture tex0;
sampler s0=sampler_state{Texture=(tex0);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;AddressU=WRAP;AddressV=WRAP;};

float4 p0(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 c=tex2D(s0,x);    
    float4 filtR=c*Rf;
    float4 filtBG=c*BGf;    
    float4 Rnegative=float(filtR.r);
    float4 BGnegative=float((filtBG.g+filtBG.b)/2); 	
    float4 Rout=Rnegative*Rf;
    float4 BGout=BGnegative*BGf;	
    float4 result=Rout+BGout;
    return lerp(c,result,amount);
}

float4 p1(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 c=tex2D(s0,x);     
    float4 filtR=c*Rf;
    float4 filtBG=c*BGf; 
    float4 Rnegative=float(filtR.r);
    float4 BGnegative=float((filtBG.g+filtBG.b)/2); 	
    float4 Rout=Rnegative+Cf;
    float4 BGout=BGnegative+Mf;    
    float4 result=Rout+BGout;
    return lerp(c,result,amount);
}

float4 p2(float2 vp:vpos):color{float2 x=(vp+.5)/R;
    float4 c=tex2D(s0,x);  
    float4 filtG=c*Gf;
    float4 filtB=c*Mf;
    float4 filtR=c*ROf;
    float4 Rnegative=float((filtR.r+filtR.g+filtR.b)/3.0);
    float4 Gnegative=float((filtG.r+filtG.g+filtG.b)/3.0);
    float4 Bnegative=float((filtB.r+filtB.g+filtB.b)/3.0);   
    float4 Rout=Rnegative+Cf;
    float4 Gout=Gnegative+Mf;
    float4 Bout=Bnegative+Yf;   
    float4 result=Rout*Gout*Bout;
    return lerp(c,result,amount);
}

void vs2d(inout float4 vp:POSITION0,inout float2 uv:TEXCOORD0){vp.xy*=2;uv+=.5/R;}
technique Technicolor01{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p0();}}
technique Technicolor02{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p1();}}
technique Technicolor03{pass pp0{vertexshader=compile vs_3_0 vs2d();pixelshader=compile ps_3_0 p2();}}
