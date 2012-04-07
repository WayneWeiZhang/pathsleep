//
//  HHViewController.m
//  pathsleep
//
//  Created by Eric on 12-2-18.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import "HHViewController.h"
#import "pathSleepController.h"
#import <QuartzCore/QuartzCore.h>
#import "WiAdView.h"
@implementation HHViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WiAdView* adView = [WiAdView adViewWithResId:@"4844096a1364e610" style:kWiAdViewStyleBanner320_50];
    adView.center = CGPointMake(160.0,25.0);
    adView.delegate = self;
    adView.refreshInterval = 31;
    adView.adBgColor = [UIColor colorWithRed:1.0f green:(CGFloat)0x66/255 blue:(CGFloat)0x33/255 alpha:1.0f];
    [self.view addSubview:adView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"request-close.png"]];
    [self.view addSubview:imageView];
    imageView.center = CGPointMake(310,adView.center.y);
    
    [adView requestAd];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)gosleep:(id)sender
{
    kIsAdShow;
    pathSleepController *share = [[pathSleepController alloc] initWithNibName:@"pathSleepController" bundle:nil];
    //[self presentModalViewController:share animated:YES];
    [self.view addSubview:share.view];
/*
    [share.view.layer addAnimation:[self getOpacityAnimation:0.8
                                                  toOpacity:1.0] forKey:@"opacity"];
    */
   // [share release];

}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
