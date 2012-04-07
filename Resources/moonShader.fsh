#define EPSILON 0.000011

precision highp float;
varying vec2 textureCoordinate;

uniform sampler2D grdient_texture;
uniform float gradient_time;
uniform float gradient_start;

/*
vec3 normalizeColor(vec3 color)
{
    return color / max(dot(color, vec3(1.0/3.0)), 0.3);
}
 */
/*
vec4 maskPixel(vec4 pixelColor, vec4 maskColor)
{
    float  d;
	vec4   calculatedColor;
    d = distance(normalizeColor(pixelColor.rgb), normalizeColor(maskColor.rgb));
    
    calculatedColor =  (d > threshold)  ?  vec4(0.0)  :  vec4(1.0);
    
	return calculatedColor;
}
*/
vec4 coordinateMask(vec4 maskColor, vec2 coordinate)
{
    
    return maskColor * vec4(coordinate, vec2(1.0));
}

void main()
{
    //gl_FragColor = texture2D(grdient_texture,textureCoordinate);
    vec4 color = texture2D(grdient_texture,textureCoordinate);
    gl_FragColor = vec4(color.r,color.g,color.b,color.a);
    
}

