//
//  ViewController.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "ViewController.h"
#import "QuadImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet QuadImageView *quadImageView;

@end

@implementation ViewController

- (void)topLeft:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    UIView *view;
    CGRect frame;
    
    view = self.quadImageView.topLeftImageView;
    [self.quadImageView bringSubviewToFront:view];
    frame = view.frame;

    view.layer.anchorPoint = CGPointMake(1.0, 0.5);
    view.layer.position = CGPointMake(frame.origin.x + 1.0 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    view.layer.zPosition = 1000; // 実験して決めた

    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    /*
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0/500; // make it 3D flavor
    transform = CATransform3DRotate(transform, M_PI, 0.0, 1.0, 0.0);
    anim.toValue = [NSNumber valueWithCATransform3D:transform];
     */
    //anim.fromValue = [NSNumber numberWithDouble:0];
    anim.toValue = [NSNumber numberWithDouble:M_PI];
    anim.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateY];
    
    anim.duration = 1.0;
    anim.repeatCount = 1;
    anim.cumulative = YES;
    anim.additive = YES;
    anim.removedOnCompletion = NO;
    
    [view.layer addAnimation:anim forKey:@"a"];

    //view.layer.transform = transform;

    /*
    view.layer.anchorPoint = CGPointMake(0.5, 0.5);
    view.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
     */

    /*
    CGFloat r = M_PI;
    CGFloat m34 = 1.0/500;
    
    //[self.view bringSubviewToFront:view]; // これをやらないと終了時の順番が正しくない
    //[self.quadImageView bringSubviewToFront:view]; // これをやらないと終了時の順番が正しくない
    view.layer.zPosition = 1000; // 実験して決めた
    [UIView animateWithDuration:1.0
                     animations:^{
                         CATransform3D transform = CATransform3DIdentity;
                         transform.m34 = m34; // make it 3D flavor
                         transform = CATransform3DRotate(transform, r, 0.0, 1.0, 0.0);
                         view.layer.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         view.layer.zPosition = 0;
                         //[self.quadImageView bringSubviewToFront:view]; // これをやらないと終了時の順番が正しくない
                         view.layer.anchorPoint = CGPointMake(0.5, 0.5);
                         //view.layer.position = CGPointMake(frame.origin.x + 3 * frame.size.width / 2, frame.origin.y + frame.size.height / 2);
                     }
     ];
     */
}

- (void)topRight:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)bottomLeft:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)bottomRight:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.quadImageView.topLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.topRightImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomRightImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gestureRecognizer;
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topLeft:)];
    [self.quadImageView.topLeftImageView addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topRight:)];
    [self.quadImageView.topRightImageView addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomLeft:)];
    [self.quadImageView.bottomLeftImageView addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomRight:)];
    [self.quadImageView.bottomRightImageView addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
