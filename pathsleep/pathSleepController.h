//
//  pathSleepController.h
//  pathsleep
//
//  Created by Eric on 12-2-18.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    GRADIENT_TEXTURE,
    GRADIENT_TIME,
    GRADIENT_START,
    MOON_TEXTURE,
    MOON_MATRIX,
    STARS_TEXTURE,
    NUM_UNIFORMS
};

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};
@interface pathSleepController : UIViewController
{
    GLuint gradientProgram,moonProgram,starProgram;
    GLuint gradientTexture,moonTexture,starTexture;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
    
    BOOL isStart;
    
    float textureStart;
    GLfloat ktexturetime;
    float translatey;
    float translatez;
}
@property(assign) NSTimer *animationTimer;
@property NSTimeInterval animationInterval;
- (void)drawFrame;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer uniforms:(GLint *)uniforms;
-(void)LoadTexture:(NSString *)fileName Texture:(GLuint *)Texture withWidth:(GLfloat)w withHeight:(GLfloat)h;
- (void)setanimationInterval:(NSTimeInterval)interval;
- (void)setanimationTimer:(NSTimer *)newTimer;
- (void)startAnimation;
- (void)stopAnimation;
- (IBAction)Wake:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *wakeButton;
@end
