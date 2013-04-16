//@author:desaxismundi
//@help:emulates displaement mapping 
//@tags:bump,relief,parallax,normal,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tW:WorldViewProjection;
float4x4 tWV:WorldView;
float4x4 tV:View;

//material properties
float4 AmbiColor:COLOR <string UIName="Ambient";> ={0.2,0.2,0.2,1};
float4 DiffColor:COLOR <string UIName="Diffuse";> =1;
float4 SpecColor:COLOR <string UIName="Specular";> ={0.75,0.75,0.75,1};
float3 LampPos <string UIName="Light Position";> ={-150.0,200.0,-125.0};
float PhongExp <string UIName="Phong Exponent";float UIMin=8.0f;float UIStep=8;float UIMax=256.0f;> =128;
float TileCount <string UIName="Tile Repeat";float UIMin=1.0;float UIStep=1.0;float UIMax=32.0;> =8;
float Depth <string UIName="Depth";float UIMin=0.0;float UIStep=0.001;float UIMax=0.25;> =0.1;

//samplers
texture ColorTex;
sampler2D ColorSamp = sampler_state {Texture = <ColorTex>;MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};
texture ReliefTex;
sampler2D ReliefSamp = sampler_state {Texture = <ReliefTex>;MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};

struct vs2ps{
    float4 hpos:POSITION;
	float4 color:COLOR0;
    float2 UV:TEXCOORD0;
    float3 vpos:TEXCOORD1;
    float3 tangent:TEXCOORD2;
    float3 binormal:TEXCOORD3;
    float3 normal:TEXCOORD4;
	float4 lightpos:TEXCOORD5;
};

vs2ps vs(
	float4 pos:POSITION,
    float4 color:COLOR0,
    float3 normal:NORMAL,
    float2 txcoord:TEXCOORD0,
    float3 tangent:TANGENT0,
    float3 binormal:BINORMAL0)
{
	vs2ps OUT=(vs2ps)0;
	float4 Po=float4(pos.xyz,1);
	float3x3 modelviewrot;
	modelviewrot[0]=tWV[0].xyz;
	modelviewrot[1]=tWV[1].xyz;
	modelviewrot[2]=tWV[2].xyz;
	OUT.hpos=mul(Po,tW);
	OUT.vpos=mul(Po,tWV).xyz;
	float4 lp=float4(LampPos.xyz,1);
	OUT.lightpos=mul(lp,tV);
	OUT.tangent=mul(tangent,modelviewrot);
	OUT.binormal=mul(binormal,modelviewrot);
	OUT.normal=mul(normal,modelviewrot);
	OUT.color=color;
	OUT.UV = TileCount*txcoord.xy;
	return OUT;
}

float4 psNORMALMAP(vs2ps IN,uniform sampler2D texmap,uniform sampler2D reliefmap):COLOR{
	float2 uv=IN.UV;
	float4 normal=tex2D(reliefmap,uv);
	normal.xyz-=.5; 
	normal.xyz=normalize(normal.x*IN.tangent-normal.y*IN.binormal+normal.z*IN.normal);
	float4 color=tex2D(texmap,uv);
	float3 v = normalize(IN.vpos);
	float3 l = normalize(IN.lightpos.xyz-IN.vpos);
	float att=saturate(dot(l,IN.normal.xyz));
	float diff=saturate(dot(l,normal.xyz));
	float spec=saturate(dot(normalize(l-v),normal.xyz));
	float4 finalcolor;
	finalcolor.xyz=AmbiColor*color.xyz+att*(color.xyz*DiffColor.xyz*diff+SpecColor.xyz*pow(spec,PhongExp));
	finalcolor.w=1;
	return finalcolor;
}

float4 psPARALLAXMAP(vs2ps IN,uniform sampler2D texmap,uniform sampler2D reliefmap):COLOR{
	float3 v = normalize(IN.vpos);
	float3 l = normalize(IN.lightpos.xyz-IN.vpos);
	float2 uv = IN.UV;
	float3x3 tbn = float3x3(IN.tangent,IN.binormal,IN.normal);
	float height = tex2D(reliefmap,uv).w*.06-.03;
	uv += height * mul(tbn,v);
	float4 normal=tex2D(reliefmap,uv);
	normal.xyz-=.5; 
	normal.xyz=normalize(normal.x*IN.tangent-normal.y*IN.binormal+normal.z*IN.normal);
	float4 color=tex2D(texmap,uv);
	float att=saturate(dot(l,IN.normal.xyz));
	float diff=saturate(dot(l,normal.xyz));
	float spec=saturate(dot(normalize(l-v),normal.xyz));
	float4 finalcolor;
	finalcolor.xyz=AmbiColor*color.xyz+att*(color.xyz*DiffColor.xyz*diff+SpecColor.xyz*pow(spec,PhongExp));
	finalcolor.w=1;
	return finalcolor;
}

float RayIntersectRm(in sampler2D reliefmap,in float2 dp,in float2 ds){
   const int linear_search_steps=15;
   float size=1/linear_search_steps;
   float depth=0;
   for( int i=0;i<linear_search_steps-1;i++ )
   {
		float4 t=tex2D(reliefmap,dp+ds*depth);
		if (depth<t.w)
			depth+=size;
   }
   const int binary_search_steps=5;
   for( int i=0;i<binary_search_steps;i++ )
   {
		size*=.5;
		float4 t=tex2D(reliefmap,dp+ds*depth);
		if (depth<t.w)
			depth+=2*size;
		depth-=size;
   }
   return depth;
}

float RayIntersectRmLin(in sampler2D reliefmap,in float2 dp,in float2 ds){
   const int linear_search_steps=15;
   float size=1/linear_search_steps;
   float depth=0;
   for( int i=0;i<linear_search_steps-1;i++ )
   {
		float4 t=tex2D(reliefmap,dp+ds*depth);
		if (depth<t.w)
			depth+=size;
   }
   return depth;
}

float4 psRELIEFMAPSHADOWS(vs2ps IN,uniform sampler2D texmap,uniform sampler2D reliefmap):COLOR{
	float4 t,c;
	float3 p,v,l,s;
	float2 dp,ds,uv;
	float d,a;
	p  = IN.vpos;
	v  = normalize(p);
	a  = dot(IN.normal,-v);
	s  = float3(dot(v,IN.tangent.xyz), dot(v,IN.binormal.xyz), a);
	s  *= Depth/a;
	ds = s.xy;
	dp = IN.UV;
	d  = RayIntersectRm(reliefmap,dp,ds);
	uv=dp+ds*d;
	t=tex2D(reliefmap,uv);
	c=tex2D(texmap,uv);
	t.xyz-=.5;
	t.xyz=normalize(t.x*IN.tangent.xyz-t.y*IN.binormal.xyz+t.z*IN.normal);
	p += v*d/(a*Depth);
	l=normalize(p-IN.lightpos.xyz);
	float att=saturate(dot(-l,IN.normal));
	float diff=saturate(dot(-l,t.xyz));
	float spec=saturate(dot(normalize(-l-v),t.xyz));

	dp+= ds*d;
	a  = dot(IN.normal,-l);
	s  = float3(dot(l,IN.tangent.xyz),dot(l,IN.binormal.xyz),a);
	s *= Depth/a;
	ds = s.xy;
	dp-= ds*d;
	float dl = RayIntersectRmLin(reliefmap,dp,s.xy);
	if (dl<d-0.05) // if pixel in shadow
	{
	  diff*=dot(AmbiColor.xyz,float3(1,1,1))*0.333333;
	  spec=0;
	}

	float4 finalcolor;
	finalcolor.xyz=AmbiColor*c+att*(c*DiffColor*diff+SpecColor.xyz*pow(spec,PhongExp));
	finalcolor.w=1.0;
	return finalcolor;
}

float4 psRELIEFMAP(vs2ps IN,uniform sampler2D texmap,uniform sampler2D reliefmap):COLOR{
	float4 t,c;
	float3 p,v,l,s;
	float2 dp,ds,uv;
	float d,a;
	p  = IN.vpos;
	v  = normalize(p);
	a  = dot(IN.normal,-v);
	s  = float3(dot(v,IN.tangent.xyz), dot(v,IN.binormal.xyz), a);
	s  *= Depth/a;
	ds = s.xy;
	dp = IN.UV; 
	d  = RayIntersectRm(reliefmap,dp,ds);
	uv=dp+ds*d;
	t=tex2D(reliefmap,uv);
	c=tex2D(texmap,uv);
	t.xyz-=.5;
	t.xyz=normalize(t.x*IN.tangent.xyz-t.y*IN.binormal.xyz+t.z*IN.normal);
	p += v*d/(a*Depth);
	l=normalize(p-IN.lightpos.xyz);
	float att=saturate(dot(-l,IN.normal));
	float diff=saturate(dot(-l,t.xyz));
	float spec=saturate(dot(normalize(-l-v),t.xyz));
	float4 finalcolor;
	finalcolor.xyz=AmbiColor*c+att*(c*DiffColor*diff+SpecColor.xyz*pow(spec,PhongExp));
	finalcolor.w=1;
	return finalcolor;
}

technique normal_mapping {pass p0{vertexshader=compile vs_3_0 vs();pixelshader=compile ps_3_0 psNORMALMAP(ColorSamp,ReliefSamp);}}
technique parallax_mapping {pass p0{vertexshader=compile vs_3_0 vs();pixelshader=compile ps_3_0 psPARALLAXMAP(ColorSamp,ReliefSamp);}}
technique relief_mapping {pass p0{vertexshader=compile vs_3_0 vs();pixelshader=compile ps_3_0 psRELIEFMAP(ColorSamp,ReliefSamp);}}
technique relief_mapping_shadows {pass p0{vertexshader=compile vs_3_0 vs();pixelshader=compile ps_3_0 psRELIEFMAPSHADOWS(ColorSamp,ReliefSamp);}}
