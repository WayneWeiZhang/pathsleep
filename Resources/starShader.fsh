#define EPSILON 0.000011

precision highp float;
varying vec2 textureCoordinate;

uniform sampler2D grdient_texture;
uniform float gradient_time;
uniform float gradient_start;


/*
vec4 maskPixel(vec4 pixelColor, vec4 maskColor)
{
    float  d;
    vec4   calculatedColor;
    
    // Compute distance between current pixel color and reference color
    d = distance(normalizeColor(pixelColor.rgb), normalizeColor(maskColor.rgb));
    
    // If color difference is larger than threshold, return black.
    //    calculatedColor =  (d < threshold)  ?  vec4(0.0)  :  vec4(1.0);
    //    calculatedColor =  (d < threshold)  ?  vec4(0.0)  :  vec4(1.0,2.0,3.0,4.0);
    float av =( pixelColor.x + pixelColor.y + pixelColor.x )/3.0;
    // calculatedColor.rgb = vec3(av,av,av);
    
    //    red = red *2;
    //    green = green*0.8;
    //    blue = blue  ;
    
    //if(pixelColor.z > 0.0)
    calculatedColor.rgb = vec3(pixelColor.x*1.2,pixelColor.y*0.8,pixelColor.z);
    //els
    //    calculatedColor.rgb = pixelColor.rgb+vec3(0,0.7,0);
    
	//Multiply color by texture
	return calculatedColor;
}
*/


vec3 normalizeColor(vec3 color)
{
    return color / max(dot(color, vec3(1.0/3.0)), 0.3);
}


vec4 coordinateMask(vec4 maskColor, vec2 coordinate)
{
  
    return maskColor * vec4(coordinate, vec2(1.0));
}

void main()
{
    vec4 color = texture2D(grdient_texture,textureCoordinate);
    gl_FragColor = vec4(color.r,color.g,color.b,color.a*0.1);
   // gl_FragColor = vec4(0.1,0.0,0.3,color.a *1.0);
}
