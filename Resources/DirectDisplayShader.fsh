#define EPSILON 0.000011

precision highp float;
varying vec2 textureCoordinate;

uniform sampler2D grdient_texture;
uniform float gradient_time;
uniform float gradient_start;
void main()
{
    /*
    vec4 top = texture2D(videoFrame,vec2(textureCoordinate.x,textureCoordinate.y - 1.0));
    vec4 down = texture2D(videoFrame,vec2(textureCoordinate.x,textureCoordinate.y + 1.0));
    vec4 left = texture2D(videoFrame,vec2(textureCoordinate.x,textureCoordinate.y));
    vec4 down = texture2D(videoFrame,vec2(textureCoordinate.x,textureCoordinate.y + 1.0));
    */
	//gl_FragColor = texture2D(grdient_texture, textureCoordinate);
    vec4 color = texture2D(grdient_texture, vec2(textureCoordinate.x,textureCoordinate.y*gradient_time + gradient_start));
    gl_FragColor = vec4(color.r,color.g,color.b,color.a);
}

vec3 normalizeColor(vec3 color)
{
    return color / max(dot(color, vec3(1.0/3.0)), 0.3);
}

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
    //else
    //    calculatedColor.rgb = pixelColor.rgb+vec3(0,0.7,0);
    
	//Multiply color by texture
	return calculatedColor;
}
