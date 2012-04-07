//
//  pathSleepController.m
//  pathsleep
//
//  Created by Eric on 12-2-18.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import "pathSleepController.h"
#import "ColorTrackingGLView.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include "esUtil.h"
#import <QuartzCore/QuartzCore.h>

GLint uniforms[NUM_UNIFORMS];
GLint uniforms1[NUM_UNIFORMS];
GLint uniforms2[NUM_UNIFORMS];
@implementation pathSleepController
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize wakeButton;

- (void)dealloc
{
    [wakeButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"sleep-awake-button.png"];
    UIImage *image1 = [image stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [wakeButton setBackgroundImage:image1 forState:UIControlStateNormal];
    wakeButton.hidden = YES;
    isStart = YES;
    //设置时间间隔为
    animationInterval = 1.0 / 60.0;
    textureStart = 0.0;
    ktexturetime = 0.002;
    translatey = -1.0;
    translatez = -3.0;
   [self LoadTexture:@"sleep-gradient@2x.png" Texture:&gradientTexture withWidth:8.0 withHeight:2048.0];
    //[self LoadTexture:@"sleep-stars@2x.png" Texture:&starTexture withWidth:1024 withHeight:1024];
    [self LoadTexture:@"xueye.jpg" Texture:&starTexture withWidth:1024 withHeight:1024];
    srandom(time(NULL));
    int rand = random()%7+2;
    [self LoadTexture:[NSString stringWithFormat:@"sleep-moon%d@2x.png",rand] Texture:&moonTexture withWidth:512 withHeight:512];
    [self loadVertexShader:@"DirectDisplayShader" fragmentShader:@"DirectDisplayShader" forProgram:&gradientProgram  uniforms:uniforms];
    [self loadVertexShader:@"moonShader" fragmentShader:@"moonShader" forProgram:&moonProgram uniforms:uniforms1];
    [self loadVertexShader:@"starShader" fragmentShader:@"starShader" forProgram:&starProgram uniforms:uniforms2];
    [self startAnimation];
    // Do any additional setup after loading the view from its nib.
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    [animationTimer invalidate];
    self.animationTimer = nil;
}


- (void)setanimationTimer:(NSTimer *)newTimer 
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setanimationInterval:(NSTimeInterval)interval 
{
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}



char*  esLoadPNG ( char *fileName, int *width, int *height )
{
	NSString *filePath = [NSString stringWithUTF8String: fileName];
	NSString *path = [[NSBundle mainBundle] pathForResource: filePath ofType:@"jpg"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    
    *width = CGImageGetWidth(image.CGImage);
    *height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( *height * *width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, *width, *height, 8, 4 * *width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, *width, *height ) );
    CGContextTranslateCTM( context, 0, *height - *height );
    CGContextDrawImage( context, CGRectMake( 0, 0, *width, *height ), image.CGImage );
	
    CGContextRelease(context);
	
	[image release];
    [texData release];
	
	return imageData;    
}


-(void)LoadTexture:(NSString *)fileName Texture:(GLuint *)Texture withWidth:(GLfloat)w withHeight:(GLfloat)h
{
    CGImageRef woodImage;
    size_t width;
    size_t height;
    
    woodImage = [UIImage imageNamed:fileName].CGImage;

	width = w;
	height =h;
    
    if (woodImage) {
        GLubyte *woodImageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        CGContextRef imageContext = CGBitmapContextCreate(woodImageData, 
                                                          width, 
                                                          height, 
                                                          8, 
                                                          width * 4, 
                                                          CGImageGetColorSpace(woodImage), 
                                                          kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), woodImage);
        CGContextRelease(imageContext);
        
        glGenTextures(1, Texture);
        glBindTexture(GL_TEXTURE_2D, *Texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, woodImageData);
        free(woodImageData);        
    }
}

- (void)drawStar
{
    
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	//glDisable(GL_DEPTH_TEST);
   // glEnable(GL_SMOOTH);

    glDepthFunc(GL_NEVER);
	//glEnable(GL_COLOR_MATERIAL);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);					// Set The Blending Function For Translucency
	glEnable(GL_BLEND);
     
    glUseProgram(starProgram);
    
   // glColor4f(1.0,1.0,1.0,1.0);
    CGFloat s = 1.0;
    
    GLfloat squareVertices[] = {
        -1.0 * s, -1.0 * s+ 0.5,-1.0f,//左下
        1.0f* s, -1.0 * s+ 0.5,-1.0f,//右下
        -1.0* s,  1.0 * s+ 0.5,-1.0f,//左上
        1.0* s,  1.0 * s+ 0.5,-1.0f,//右上
    };
    
    GLfloat textureVertices[] = {
        0.0f,  0.0f,//左上
        1.0f, 0.0f,//右上
        0.0f,  1.0f,//左下
        1.0f, 1.0f,//右下
        
    };
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, starTexture);
    
    glUniform1i(uniforms2[GRADIENT_TEXTURE],0);	
    glUniform1f(uniforms2[GRADIENT_TIME],0.6);
    glUniform1f(uniforms2[GRADIENT_START],0.0);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 
}




- (void)drawMoon
{
    
    glDepthFunc(GL_LESS);
	glEnable(GL_COLOR_MATERIAL);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);					// Set The Blending Function For Translucency
	glEnable(GL_BLEND);
    glUseProgram(moonProgram);
    
   // glColor4f(1.0,0.0,0.0,1.0);
    CGFloat s = 1.0;
    
     GLfloat squareVertices[] = {
        -1.0 * s, -1.0 * s,-3.0f,//左下
        1.0f* s, -1.0 * s,-3.0f,//右下
        -1.0* s,  1.0 * s,-3.0f,//左上
        1.0* s,  1.0 * s,-3.0f,//右上
    };
    
	 GLfloat textureVertices[] = {
        0.0f,  0.0f,//左上
        1.0f, 0.0f,//右上
        0.0f,  1.0f,//左下
        1.0f, 1.0f,//右下
        
    };
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, moonTexture);
    
    glUniform1i(uniforms1[GRADIENT_TEXTURE],0);	
    glUniform1f(uniforms1[GRADIENT_TIME],0.6);
    glUniform1f(uniforms1[GRADIENT_START],0.0);
    
    ESMatrix perspective;
    ESMatrix modelview;
    ESMatrix VMatrix;
    CGFloat w_h = self.view.frame.size.width/self.view.frame.size.height;
    float aspect = w_h;
    esMatrixLoadIdentity( &perspective );
    esPerspective( &perspective, 30.0f, aspect, 1.0f, 80.0f );
    esMatrixLoadIdentity(&modelview);
    
    esTranslate(&modelview,0.0,translatey,translatez);
   
    
    esMatrixMultiply( &VMatrix, &modelview, &perspective );
    glUniformMatrix4fv(uniforms1[MOON_MATRIX], 1, GL_FALSE, (GLfloat*)&VMatrix.m[0][0] );
    
    
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
     translatey += 0.008;
    translatez += 0.008;
    if (isStart)
    {
        if (translatey>0.7)
        {
            translatey = 0.0;
        }
        if (translatez>0)
        {
            translatez = -5.0;
        }
    }
    

    
}


- (void)drawGradient
{
    
    glDepthFunc(GL_LESS);
	glEnable(GL_COLOR_MATERIAL);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);					// Set The Blending Function For Translucency
	glEnable(GL_BLEND);
    
    
    glUseProgram(gradientProgram);
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,//左下
        1.0f, -1.0f,//右下
        -1.0f,  1.0f,//左上
        1.0f,  1.0f,//右上
    };
    
	static const GLfloat textureVertices[] = {
        0.0f,  0.0f,//左上
        1.0f, 0.0f,//右上
        0.0f,  1.0f,//左下
        1.0f, 1.0f,//右下
        
    };
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, gradientTexture);
    
    glUniform1i(uniforms[GRADIENT_TEXTURE],0);	
    glUniform1f(uniforms[GRADIENT_TIME],0.6);
    glUniform1f(uniforms[GRADIENT_START],textureStart);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    textureStart += ktexturetime;
    if (textureStart>0.3)
    {
        
    }
    if (textureStart>0.4)
    {
         
        ktexturetime = -0.002;
        [self stopAnimation];
        if (isStart) 
        {
            wakeButton.hidden = NO;
        }
    }
}


- (void)drawFrame
{   
    ColorTrackingGLView *glView = (ColorTrackingGLView *)self.view;
    glEnable(GL_DEPTH_TEST);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
    glClearColor(0.0,0.0,0.0,1.0);
    [glView setDisplayFramebuffer];
    //TODO
    
    [self drawGradient];
    [self drawStar];
    [self drawMoon];
   
    [glView presentFramebuffer];
    
}   



#pragma mark -
#pragma mark OpenGL ES 2.0 setup methods

- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer uniforms:(GLint *)uniforms;
{
    GLuint vertexShader, fragShader;
	
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    *programPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShaderName ofType:@"vsh"];
    NSLog(@"%@",vertShaderPathname);
    //    NSLog(@"compile vertex vertexShaderName[%@]vertShaderPathname[%@]",
    //          vertexShaderName,vertShaderPathname);
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex ");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*programPointer, vertexShader);
    
    // Attach fragment shader to program.
    glAttachShader(*programPointer, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*programPointer, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*programPointer, ATTRIB_TEXTUREPOSITON, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:*programPointer])
    {
        NSLog(@"Failed to link program: %d", *programPointer);
        
        if (vertexShader)
        {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*programPointer)
        {
            glDeleteProgram(*programPointer);
            *programPointer = 0;
        }
        
        return FALSE;
    }

    uniforms[GRADIENT_TEXTURE] = glGetUniformLocation(*programPointer, "grdient_texture");
    uniforms[GRADIENT_TIME] = glGetUniformLocation(*programPointer, "gradient_time");
    uniforms[GRADIENT_START] = glGetUniformLocation(*programPointer, "gradient_start");
    uniforms[MOON_TEXTURE] = glGetUniformLocation(*programPointer, "moon_texture");
    uniforms[MOON_MATRIX] = glGetUniformLocation(*programPointer, "u_mvpMatrix");
    uniforms[STARS_TEXTURE] = glGetUniformLocation(*programPointer, "stars_texture");
    // Release vertex and fragment shaders.
    if (vertexShader)
	{
        glDeleteShader(vertexShader);
	}
    if (fragShader)
	{
        glDeleteShader(fragShader);		
	}
    
    return TRUE;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader %@",file);
        return FALSE;
    }
    NSLog(@"success to load vertex shader %@",file);
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (CAAnimation *)getOpacityAnimation:(CGFloat)fromOpacity
                           toOpacity:(CGFloat)toOpacity
{
    CABasicAnimation *pulseAnimationx = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimationx.duration = 2.0;
    pulseAnimationx.fromValue = [NSNumber numberWithFloat:fromOpacity];
    pulseAnimationx.toValue = [NSNumber numberWithFloat:toOpacity];
    
    pulseAnimationx.autoreverses = NO;
    pulseAnimationx.fillMode=kCAFillModeForwards;
    pulseAnimationx.removedOnCompletion = NO;
    pulseAnimationx.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    return pulseAnimationx;
    
}


-(void)dismiss
{
    [self stopAnimation];
    glDeleteTextures(1, &gradientTexture);
    glDeleteTextures(1, &moonTexture);
    glDeleteTextures(1, &starTexture);
    [self.view removeFromSuperview];
}

- (IBAction)Wake:(id)sender
{
    UIButton *button =(UIButton *)sender;
    button.hidden = YES;
    isStart = NO;
    [self.view.layer addAnimation:[self getOpacityAnimation:1.0
                                               toOpacity:0.0] forKey:@"opacity"];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
    [self startAnimation];
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
