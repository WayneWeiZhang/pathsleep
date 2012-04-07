attribute vec4 position;
attribute vec4 inputTextureCoordinate;
uniform mat4 u_mvpMatrix;
varying vec2 textureCoordinate;

void main()
{
	gl_Position = u_mvpMatrix * position;
	textureCoordinate = inputTextureCoordinate.xy;
    
}