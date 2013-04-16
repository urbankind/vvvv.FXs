
float param1 = 1;
float param2 = 1;
float param3 = 1;
float param4 = 1;

#define TWOPI 6.28318531
#define PI    3.14159265

///////////////////////////////////////////////
float3 SteinbachScrew(float u,float v){
	float x = param1*(u)*cos(v);
	float y = param1*(u)*sin(v);
	float z = param1*(v)*cos(u);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Sine(float u,float v){
	float x = param1*sin(u);
	float y = param1*sin(v);
	float z = param1*sin(u+v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Paraboloid(float u,float v){
	float x = param1*pow((u/param2),0.5)*cos(v);
	float y = param1*pow((u/param2),0.5)*sin(v);
	float z = (u);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 HyperHelicoid(float u,float v){
	float x = param1*(sin(v)*cos(param3*u))/(1+cosh(u)*cosh(v));
	float y = param1*(sin(v)*sin(param3*u))/(1+cosh(u)*cosh(v));
	float z = (cosh(v)*sinh(u))/(1+cosh(u)*cosh(v));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Hyperboloid(float u,float v){
	float x = param1*pow((1+pow(u,2)),0.5)*cos(v);
	float y = param2*pow((1+pow(u,2)),0.5)*sin(v);
	float z = param3*(u);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Eight(float u,float v){
	float x = cos(u)*sin(2*v);
	float y = sin(u)*sin(2*v);
	float z = sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Corkscrew(float u,float v){
	float x = param1*cos(u)*cos(v);
	float y = param1*sin(u)*cos(v);
	float z = param1*sin(v)+param2*u;
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Roman2Boy(float u,float v){
	float x = (pow(2,0.5)*cos(2*u)*pow(cos(v),2)+cos(u)*sin(2*v))/(2-param1*pow(2,0.5)*sin(3*u)*sin(2*v));
	float y = (pow(2,0.5)*sin(2*u)*pow(cos(v),2)+sin(u)*sin(2*v))/(2-param1*pow(2,0.5)*sin(3*u)*sin(2*v));
	float z = (3*pow(cos(v),2))/(2-param1*pow(2,0.5)*sin(3*u)*sin(2*v));
//when param1 = 0 = Roman surface/when = 1 = Boy surface
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 TwistedPipe(float u,float v){
	float x = cos(v)*(2+cos(u))/sqrt(1+pow(sin(v),2));
	float y = sin(v+TWOPI/3)*(2+cos(u+TWOPI/3))/sqrt(1+pow(sin(v),2));
	float z = sin(v-TWOPI/3)*(2+cos(u-TWOPI/3))/sqrt(1+pow(sin(v),2));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Stiletto(float u,float v){
	float x = (2+cos(u))*pow(cos(v),3)*sin(v);
	float y = (2+cos(u+TWOPI/3))*pow(cos(v+TWOPI/3),2)*pow(sin(v+TWOPI/3),2);
	float z = -(2+cos(u-TWOPI/3))*pow(cos(v+TWOPI/3),2)*pow(sin(v+TWOPI/3),2);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 BohemianDome(float u,float v){
	float x = param1*cos(u);
	float y = param1*sin(u)+param2*cos(v);
	float z = param3*sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Folium(float u,float v){
	float x = cos(u)*(2*v/PI-tanh(v));
	float y = cos(u+TWOPI/3)/cosh(v);
	float z = cos(u-TWOPI/3)/cosh(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 MaedersOwl(float u,float v){
	float x = v*cos(u)-0.5*pow(v,2)*cos(2*u);
	float y = -v*sin(u)-0.5*pow(v,2)*sin(2*u);
	float z = 4*pow(v,1.5)*cos(3*u/2)/3;
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 AstroidalEllipsoid(float u,float v){
	float x = pow(cos(u)*cos(v),3);
	float y = pow(sin(u)*cos(v),3);
	float z = pow(sin(v),3);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 TriaxialTritorus(float u,float v){
	float x = sin(u)*(1+cos(v));
	float y = sin(u+TWOPI/3)*(1+cos(v+TWOPI/3));
	float z = sin(u+2*TWOPI/3)*(1+cos(v+2*TWOPI/3));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 LimpetTorus(float u,float v){
	float x = cos(u)/(sqrt(2)+sin(v));
	float y = sin(u)/(sqrt(2)+sin(v));
	float z = 1/(sqrt(2)+cos(v));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 TriaxialHexatorus(float u,float v){
	float x = sin(u)/(sqrt(2)+cos(v));
	float y = sin(u+TWOPI/3)/(sqrt(2)+cos(v+TWOPI/3));
	float z = cos(u-TWOPI/3)/(sqrt(2)+cos(v-TWOPI/3));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 CrossCap(float u,float v){
	float x = cos(u)*sin(2*v);
	float y = sin(u)*sin(2*v);
	float z = pow(cos(v),2)-pow(cos(u),2)*pow(sin(v),2);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Handkerchief(float u,float v){
	float x = u;
	float y = v;
	float z = pow(u,3)/3+u*pow(v,2)+param1*(pow(u,2)-pow(v,2));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Bow(float u,float v){
	float x = (2+param1*sin(TWOPI*u))*sin(2*TWOPI*v);
	float y = (2+param1*sin(TWOPI*u))*cos(2*TWOPI*v);
	float z = param1*cos(TWOPI*u)+3*cos(TWOPI*v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Apple(float u,float v){
	float x = cos(u)*(4+3.8*cos(v));
	float y = sin(u)*(4+3.8*cos(v));
	float z = (cos(v)+sin(v)-1)*(1+sin(v))*log(1-PI*v/10)+7.5*sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Springs(float u,float v){
	float x = (1-param1*cos(v))*cos(u);
	float y = (1-param1*cos(v))*sin(u);
	float z = param2*(sin(v)+param3*u /PI);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Tear(float u,float v){
	float x = param1*(1-cos(u))*sin(u)*cos(v);
	float y = param1*(1-cos(u))*sin(u)*sin(v);
	float z = cos(u);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Moebius(float u,float v){
	float x = cos(u)+v*cos(u/2)*cos(u);
	float y = sin(u)+v*cos(u/2)*sin(u);
	float z = v*sin(u/2);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Horn(float u,float v){
	float x = (2+u*cos(v))*sin(TWOPI*u);
	float y = (2+u*cos(v))*cos(TWOPI*u+2*u);
	float z = u*sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Cresent(float u,float v){
	float x = (2+sin(TWOPI*u)*sin(TWOPI*v))*sin(3*PI*v);
	float y = (2+sin(TWOPI*u)*sin(TWOPI*v))*cos(3*PI*v);
	float z = cos(TWOPI*u)*sin(TWOPI*v)+4*v-2;
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Slippers(float u,float v){
	float x = (2+cos(u))*pow(cos(v),3)*sin(v);
	float y = (2+cos(u+TWOPI/3))*pow(cos(TWOPI/3+v),2)*pow(sin(TWOPI/3+v),2);
	float z = -(2+cos(u-TWOPI/3))*pow(cos(TWOPI/3-v),2)*pow(sin(TWOPI/3-v),3);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Kuen(float u,float v){
	float x = (2*(cos(v)+(v*sin(v)))*sin(u))/(1+pow(v,2)*pow(sin(u),2));
	float y = (2*(sin(v)-(v*cos(v)))*sin(u))/(1+pow(v,2)*pow(sin(u),2));
	float z = (log(tan(u/2))+((2*cos(u))))/(1+pow(v,2)*pow(sin(u),2));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Shell(float u,float v){
	float x = param1*(1-(u/(TWOPI)))*cos(param4*u)*(1+cos(v))+param3*cos(param4*u);
	float y = param1*(1-(u/(TWOPI)))*sin(param4*u)*(1+cos(v))+param3*sin(param4*u);
	float z = param2*(u/(TWOPI))+param1*(1-(u/(TWOPI)))*sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 PisotTriaxial(float u,float v){
	float x = 0.655866*cos(1.03002+u)*(2+cos(v));
	float y = 0.754878*cos(1.40772-u)*(2+0.868837*cos(2.43773+v));
	float z = 0.868837*cos(2.43773+u)*(2+0.495098*cos(0.377696-v));
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 KleinCycloid(float u,float v){
	float x = cos(u/param3)*cos(u/param2)*(param1+cos(v))+sin(u/param2)*sin(v)*cos(v);
	float y = sin(u/param3)*cos(u/param2)*(param1+cos(v))+sin(u/param2)*sin(v)*cos(v);
	float z = -sin(u/param2)*(param1+cos(v))+cos(u/param2)*sin(v)*cos(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 KleinBottle(float u,float v){
	float r = 4*(1-cos(u)/2);
	float x = 6*cos(u)*(1+sin(u))+r*cos(v+PI);
	float y = 16*sin(u);
	float z = r*sin(v);
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Bour(float u,float v){
	float x = pow(u,param1-1)*cos((param1-1)*v)/(2*(param1-1))- pow(u,param1+1)*cos((param1+1)*v)/(2*(param1+1));
    float y = pow(u,param1-1)*sin((param1-1)*v)/(2*(param1-1))+ pow(u,param1+1)*sin((param1+1)*v)/(2*(param1+1));
    float z = pow(u,param1)*cos(param1*v)/param1;
	return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Figure8Torus(float u,float v){
	float x = cos(u)*(param3+sin(v)*cos(u)-sin(2*v)*sin(u)/2);
    float y = sin(u)*(param3+sin(v)*cos(u)-sin(2*v)*sin(u)/2);
    float z = sin(u)*sin(v)+cos(u)*sin(2*v)/2;
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 EllipticTorus(float u,float v){
    float x = (param3+cos(v))*cos(u);
    float y = (param3+cos(v))*sin(u);
    float z = sin(v)+cos(v);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Tractrix(float u,float v){
    float x = cos(u)*(v-tanh(v));
    float y = cos(u)/cosh(v);
    float z = pow(x,2)-pow(y,2)+2*x*y*pow(tanh(u),2);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Catenoid(float u,float v){
    float x = param3*cosh(v/param3)*cos(u);
    float y = param3*cosh(v/param3)*sin(u);
    float z = v;
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Helicoid(float u,float v){
    float x = param3*v*cos(u);
    float y = param3*v*sin(u);
    float z = u;
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Scherk(float u,float v){
    float x = u;
    float y = v;
    float z = log(cos(param3*u)/cos(param3*v))/param3;
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Dini(float u,float v){
    float x = param1*cos(u)*sin(v);
    float y = param1*sin(u)*sin(v);
    float z = param1*(cos(v)+log(tan(v/2)))+param2*u;
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Catalan(float u,float v){
    float x = param3*(u-cosh(v)*sin(u));
    float y = param3*(1-cosh(v)*cos(u));
    float z = -4*param3*sin(u/2)*sinh(v/2);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Fish(float u,float v){
    float x = (cos(u)-cos(2*u))*cos(v)/4;
    float y = (sin(u)-sin(2*u))*sin(v)/4;
    float z = cos(u);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 DoubleCone(float u,float v){
    float x = v*cos(u);
    float y = (v-1)*cos(u+TWOPI/3);
    float z = (1-v)*cos(u-TWOPI/3);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 TriaxialTeardrop(float u,float v){
    float x = (1-cos(u))*cos(u+TWOPI/3)*cos(v+TWOPI/3)/2;
    float y = (1-cosh(u))*cos(u+TWOPI/3)*cos(v-TWOPI/3)/2;
    float z = cos(u-TWOPI/3);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Jet(float u,float v){
    float x = (1-cosh(u))*sin(u)*cos(v)/2;
    float y = (1-cosh(u))*sin(u)*sin(v)/2;
    float z = cosh(u);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 BentHorns(float u,float v){
    float x = (2+cos(u))*(v/3-sin(v));
    float y = (2+cos(u-TWOPI/3))*(cos(v)-1);
    float z = (2+cos(u+TWOPI/3))*(cos(v)-1);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Ennepers(float u,float v){
    float x = u-pow(u,3)/3+u*pow(v,2);
    float y = v-pow(v,3)/3+v*pow(u,2);
    float z = pow(u,2)-pow(v,2);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Pillow(float u,float v){
    float x = cos(u);
    float y = cos(v);
    float z = sin(u)*sin(v);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 MonkeySaddle(float u,float v){
    float x = u;
    float y = v;
    float z = pow(u,3)-3*u*pow(v,2);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Kidney(float u,float v){
    float x = cos(u)*(3*cos(v)-cos(3*v));
    float y = sin(u)*(3*cos(v)-cos(3*v));
    float z = 3*sin(v)-sin(3*v);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Henneburg(float u,float v){
    float x = 2*sinh(u)*cos(v)-2*sinh(3*u)*cos(3*v)/3;
    float y = 2*sinh(u)*sin(v)+2*sinh(3*u)*sin(3*v)/3;
    float z = 2*cosh(2*u)*cos(2*v);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Snail(float u,float v){
    float x = u*cos(v)*sin(u);
    float y = u*cos(u)*cos(v);
    float z = -u*sin(v);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Lemniscape(float u,float v){
    float cosvSqrtAbsSin2u = cos(v)*sqrt(abs(sin(2*u)));
    float x = cosvSqrtAbsSin2u*cos(u);
    float y = cosvSqrtAbsSin2u*sin(u);
    float z = pow(x,2)-pow(y,2)+2*x*y*pow(tan(v),2);
    return float3(x,y,z);
}
///////////////////////////////////////////////
float3 Tranguloid(float u,float v){
   float3 p;
   p.x = sin(3*u)*2/(2+cos(v));
   p.y = (sin(u)+2*sin(2*u))*2/(2+cos(v+TWOPI/param1));
   p.z = (cos(u)-2*cos(2*u))*(2+cos(v))*((2+cos(v+TWOPI/3))*0.25);
   return p;
}
/////////