//
//  ViewController.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "ViewController.h"
#import "QuadImageView.h"

@interface ViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet QuadImageView *quadImageView;

@end

@implementation ViewController
{
    BOOL foldedLeftToRight;
    BOOL foldedRightToLeft;
    BOOL foldedTopToBottom;
    BOOL foldedBottomToTop;
}

- (CABasicAnimation*)setupXRotationAnimationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34; // make it 3D flavor
    anim.fromValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, from, 1.0, 0.0, 0.0)];
    anim.toValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, to, 1.0, 0.0, 0.0)];
    anim.duration = 0.8;
    anim.repeatCount = 1;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    return anim;
}

- (CABasicAnimation*)setupYRotationAnimationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34; // make it 3D flavor
    anim.fromValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, from, 0.0, 1.0, 0.0)];
    anim.toValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, to, 0.0, 1.0, 0.0)];
    anim.duration = 0.8;
    anim.repeatCount = 1;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    return anim;
}

- (void)resetZPosition
{
    self.quadImageView.topLeftImageView.layer.zPosition = 0;
    self.quadImageView.topRightImageView.layer.zPosition = 0;
    self.quadImageView.bottomLeftImageView.layer.zPosition = 0;
    self.quadImageView.bottomRightImageView.layer.zPosition = 0;
}

- (void)applyAnimation:(CABasicAnimation*)anim view:(UIView*)view anchorPoint:(CGPoint)anchorPoint
{
    CGRect frame = view.frame;
    view.layer.anchorPoint = anchorPoint;
    view.layer.position = CGPointMake(frame.origin.x + anchorPoint.x * frame.size.width,
                                      frame.origin.y + anchorPoint.y * frame.size.height);
    view.layer.zPosition = 1000; // 実験して決めた
    [view.layer addAnimation:anim forKey:nil];
}

- (void)foldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *anim = [self setupXRotationAnimationFrom:0 to:M_PI m34:-1.0/500];
    [self resetZPosition];
    [self applyAnimation:anim view:self.quadImageView.topLeftImageView anchorPoint:CGPointMake(0.5, 1.0)];
    [self applyAnimation:anim view:self.quadImageView.topRightImageView anchorPoint:CGPointMake(0.5, 1.0)];
    
    foldedLeftToRight = YES;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *anim = [self setupYRotationAnimationFrom:0 to:M_PI m34:1.0/500];
    [self resetZPosition];
    [self applyAnimation:anim view:self.quadImageView.topLeftImageView anchorPoint:CGPointMake(1.0, 0.5)];
    [self applyAnimation:anim view:self.quadImageView.bottomLeftImageView anchorPoint:CGPointMake(1.0, 0.5)];

    foldedLeftToRight = YES;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);

    CABasicAnimation *anim = [self setupYRotationAnimationFrom:0 to:-M_PI m34:-1.0/500];
    [self resetZPosition];
    [self applyAnimation:anim view:self.quadImageView.topRightImageView anchorPoint:CGPointMake(0.0, 0.5)];
    [self applyAnimation:anim view:self.quadImageView.bottomRightImageView anchorPoint:CGPointMake(0.0, 0.5)];
    
    foldedRightToLeft = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    foldedBottomToTop = NO;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    foldedTopToBottom = NO;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);

    CABasicAnimation *anim = [self setupYRotationAnimationFrom:-M_PI to:0 m34:-1.0/500];
    [self resetZPosition];
    [self applyAnimation:anim view:self.quadImageView.topRightImageView anchorPoint:CGPointMake(0.0, 0.5)];
    [self applyAnimation:anim view:self.quadImageView.bottomRightImageView anchorPoint:CGPointMake(0.0, 0.5)];
    
    foldedRightToLeft = NO;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);

    CABasicAnimation *anim = [self setupYRotationAnimationFrom:M_PI to:0 m34:1.0/500];
    [self resetZPosition];
    [self applyAnimation:anim view:self.quadImageView.topLeftImageView anchorPoint:CGPointMake(1.0, 0.5)];
    [self applyAnimation:anim view:self.quadImageView.bottomLeftImageView anchorPoint:CGPointMake(1.0, 0.5)];

    foldedLeftToRight = NO;
}

- (void)topLeft:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    if (foldedLeftToRight) {
        // do nothing
    } else if (foldedRightToLeft) {
        [self unfoldLeftToRight];
    } else if (foldedTopToBottom) {
        // do nothing
    } else if (foldedBottomToTop) {
        [self unfoldTopToBottom];
    } else {
        [self foldLeftToRight];
    }
}

- (void)topLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
}

- (void)topRight:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    if (foldedLeftToRight) {
        [self unfoldRightToLeft];
    } else if (foldedRightToLeft) {
        // do nothing
    } else if (foldedTopToBottom) {
        // do nothing
    } else if (foldedBottomToTop) {
        [self unfoldTopToBottom];
    } else {
        [self foldRightToLeft];
    }
}

- (void)topRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
}

- (void)bottomLeft:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    if (foldedLeftToRight) {
        // do nothing
    } else if (foldedRightToLeft) {
        [self unfoldLeftToRight];
    } else if (foldedTopToBottom) {
        [self unfoldBottomToTop];
    } else if (foldedBottomToTop) {
        // do nothing
    } else {
        [self foldLeftToRight];
    }
}

- (void)bottomLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
}

- (void)bottomRight:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    if (foldedLeftToRight) {
        [self unfoldRightToLeft];
    } else if (foldedRightToLeft) {
        // do nothing
    } else if (foldedTopToBottom) {
        [self unfoldBottomToTop];
    } else if (foldedBottomToTop) {
        // do nothing
    } else {
        [self foldRightToLeft];
    }
}

- (void)bottomRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setupGestureRecognizers:(UIView*)view tapAction:(SEL)tapAction swipeAction:(SEL)swipeAction
{
    UIGestureRecognizer *gestureRecognizer;
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:tapAction];
    [view addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:swipeAction];
    ((UISwipeGestureRecognizer*)gestureRecognizer).direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:swipeAction];
    ((UISwipeGestureRecognizer*)gestureRecognizer).direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:swipeAction];
    ((UISwipeGestureRecognizer*)gestureRecognizer).direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:swipeAction];
    ((UISwipeGestureRecognizer*)gestureRecognizer).direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:gestureRecognizer];
    
    for (UIGestureRecognizer *g in view.gestureRecognizers) {
        g.delegate = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.quadImageView.topLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.topRightImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomRightImageView.userInteractionEnabled = YES;
    
    [self setupGestureRecognizers:self.quadImageView.topLeftImageView
                        tapAction:@selector(topLeft:)
                      swipeAction:@selector(topLeftSwipe:)];

    [self setupGestureRecognizers:self.quadImageView.topRightImageView
                        tapAction:@selector(topRight:)
                      swipeAction:@selector(topRightSwipe:)];

    [self setupGestureRecognizers:self.quadImageView.bottomLeftImageView
                        tapAction:@selector(bottomLeft:)
                      swipeAction:@selector(bottomLeftSwipe:)];

    [self setupGestureRecognizers:self.quadImageView.bottomRightImageView
                        tapAction:@selector(bottomRight:)
                      swipeAction:@selector(bottomRightSwipe:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
