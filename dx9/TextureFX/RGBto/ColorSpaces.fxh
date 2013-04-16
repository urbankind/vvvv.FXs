
float3 rgb2cmy(float3 rgbColor){
	return (float3(1,1,1)-rgbColor);
}

float3 cmy2rgb(float3 cmyColor){
	return (float3(1,1,1)-cmyColor);
}

float4 cmy2cmyk(float3 cmyColor){
	float k = ((float)1);
	k = min(k,cmyColor.x);
	k = min(k,cmyColor.y);
	k = min(k,cmyColor.z);
	float4 cmykColor;
	cmykColor.xyz = (cmyColor - (float3)k)/((float3)(((float)1.0)-k).xxx);
	cmykColor.w = k;
	return (cmykColor);
}

float3 cmyk2cmy(float4 cmykColor){
	float3 k = cmykColor.www;
	return ((cmykColor.xyz * (float3(1,1,1)-k)) + k);
}


float4 rgb2cmyk(float3 rgbColor) { return cmy2cmyk(rgb2cmy(rgbColor)); }
float3 cmyk2rgb(float4 cmykColor) { return cmy2rgb(cmyk2cmy(cmykColor)); }

float __min_channel(float3 v){
	float t = (v.x<v.y) ? v.x : v.y;
	t = (t<v.z) ? t : v.z;
	return t;
}

float __max_channel(float3 v){
	float t = (v.x>v.y) ? v.x : v.y;
	t = (t>v.z) ? t : v.z;
	return t;
}

float3 rgb2hsv(float3 RGB){
    float3 HSV = (0.0).xxx;
    float minVal = __min_channel(RGB);
    float maxVal = __max_channel(RGB);
    float delta = maxVal - minVal;             //Delta RGB value 
    HSV.z = maxVal;
    if (delta != 0) {                    // If gray, leave H & S at zero
       HSV.y = delta / maxVal;
       float3 delRGB;
       delRGB = ( ( ( maxVal.xxx - RGB ) / 6.0 ) + ( delta / 2.0 ) ) / delta;
       if      ( RGB.x == maxVal ) HSV.x = delRGB.z - delRGB.y;
       else if ( RGB.y == maxVal ) HSV.x = ( 1.0/3.0) + delRGB.x - delRGB.z;
       else if ( RGB.z == maxVal ) HSV.x = ( 2.0/3.0) + delRGB.y - delRGB.x;
       if ( HSV.x < 0.0 ) { HSV.x += 1.0; }
       if ( HSV.x > 1.0 ) { HSV.x -= 1.0; }
    }
    return (HSV);
}

float3 hsv2rgb(float3 HSV){
    float3 RGB = HSV.z;
    if ( HSV.y != 0 ) {
       float var_h = HSV.x * 6;
       float var_i = floor(var_h); //Or ... var_i = floor( var_h )
       float var_1 = HSV.z * (1.0 - HSV.y);
       float var_2 = HSV.z * (1.0 - HSV.y * (var_h-var_i));
       float var_3 = HSV.z * (1.0 - HSV.y * (1-(var_h-var_i)));
       if      (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
       else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
       else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
       else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
       else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
       else                 { RGB = float3(HSV.z, var_1, var_2); }
   }
   return (RGB);
}

float3 rgb2yuv(float3 RGB){
	float y = dot(RGB,float3(0.299,0.587,0.114));
	float u = (RGB.z - y) * 0.565;
	float v = (RGB.x - y) * 0.713;
    return float3(y,u,v);
}

float3 yuv2rgb(float3 YUV){
   float u = YUV.y;
   float v = YUV.z;
   float r = YUV.x + 1.403*v;
   float g = YUV.x - 0.344*u - 1.403*v;
   float b = YUV.x + 1.770*u;
   return float3(r,g,b);
}
