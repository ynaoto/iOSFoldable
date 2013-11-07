//
//  FoldableQuadImageView.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/05.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "FoldableQuadImageView.h"
#import <objc/runtime.h>

@interface CABasicAnimation (XYRotation)

+ (CABasicAnimation*)makeXRotationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34;
+ (CABasicAnimation*)makeYRotationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34;

@end

@implementation CABasicAnimation (XYRotation)

+ (CABasicAnimation*)makeXRotationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34
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

+ (CABasicAnimation*)makeYRotationFrom:(CGFloat)from to:(CGFloat)to m34:(CGFloat)m34
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

@end

@interface FoldController : NSObject
@property (weak, nonatomic) UIView *target;
@property (nonatomic) BOOL folded;

- (id)initWithTarget:(UIView*)target;
- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint;
- (void)unfold;

@end

@implementation FoldController
{
    CABasicAnimation *_unfoldAnim;
    CGPoint _anchorPoint;
}

- (id)initWithTarget:(id)target
{
    self = [super init];
    if (self) {
        self.target = target;
    }
    return self;
}

- (void)applyAnimation:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint
{
    CGRect frame = self.target.frame;
    self.target.layer.anchorPoint = anchorPoint;
    self.target.layer.position = CGPointMake(frame.origin.x + anchorPoint.x * frame.size.width,
                                             frame.origin.y + anchorPoint.y * frame.size.height);
    self.target.layer.zPosition = 1000; // 実験して決めた
    [self.target.layer addAnimation:anim forKey:nil];
}

- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint
{
    if (self.folded) {
        NSLog(@"warning: the view has been folded");
        return;
    }
    
    [self applyAnimation:anim anchorPoint:anchorPoint];
    
    self.folded = YES;
    _unfoldAnim = [anim copy];
    NSNumber *tmp = anim.fromValue;
    _unfoldAnim.fromValue = anim.toValue;
    _unfoldAnim.toValue = tmp;
    _anchorPoint = anchorPoint;
}

- (void)unfold
{
    if (!self.folded) {
        NSLog(@"warning: the view has not been folded");
        return;
    }
    
    [self applyAnimation:_unfoldAnim anchorPoint:_anchorPoint];
    
    self.folded = NO;
}

@end

@interface FoldableQuadImageView () <UIGestureRecognizerDelegate>

@end

@implementation FoldableQuadImageView
{
    BOOL foldedLeftToRight;
    BOOL foldedRightToLeft;
    BOOL foldedTopToBottom;
    BOOL foldedBottomToTop;
    FoldController *topLeftImageViewFoldController;
    FoldController *topRightImageViewFoldController;
    FoldController *bottomLeftImageViewFoldController;
    FoldController *bottomRightImageViewFoldController;
}

- (void)resetZPosition
{
    self.topLeftImageView.layer.zPosition = 0;
    self.topRightImageView.layer.zPosition = 0;
    self.bottomLeftImageView.layer.zPosition = 0;
    self.bottomRightImageView.layer.zPosition = 0;
}

- (void)foldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldDownAnim = [CABasicAnimation makeXRotationFrom:0 to:M_PI m34:-1.0/500];
    [self resetZPosition];
    [topLeftImageViewFoldController fold:foldDownAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [topRightImageViewFoldController fold:foldDownAnim anchorPoint:CGPointMake(0.0, 1.0)];
    
    foldedTopToBottom = YES;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [topRightImageViewFoldController unfold];
    [topLeftImageViewFoldController unfold];
    
    foldedTopToBottom = NO;
}

- (void)foldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldUpAnim = [CABasicAnimation makeXRotationFrom:0 to:-M_PI m34:1.0/500];
    [self resetZPosition];
    [bottomLeftImageViewFoldController fold:foldUpAnim anchorPoint:CGPointMake(1.0, 0.0)];
    [bottomRightImageViewFoldController fold:foldUpAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedBottomToTop = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [bottomRightImageViewFoldController unfold];
    [bottomLeftImageViewFoldController unfold];
    
    foldedBottomToTop = NO;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldRightAnim = [CABasicAnimation makeYRotationFrom:0 to:M_PI m34:1.0/500];
    [self resetZPosition];
    [topLeftImageViewFoldController fold:foldRightAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [bottomLeftImageViewFoldController fold:foldRightAnim anchorPoint:CGPointMake(1.0, 0.0)];
    
    foldedLeftToRight = YES;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [topLeftImageViewFoldController unfold];
    [bottomLeftImageViewFoldController unfold];
    
    foldedLeftToRight = NO;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldLeftAnim = [CABasicAnimation makeYRotationFrom:0 to:-M_PI m34:-1.0/500];
    [self resetZPosition];
    [topRightImageViewFoldController fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 1.0)];
    [bottomRightImageViewFoldController fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedRightToLeft = YES;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [topRightImageViewFoldController unfold];
    [bottomRightImageViewFoldController unfold];
    
    foldedRightToLeft = NO;
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
    
    if (foldedLeftToRight) {
        // do nothing
    } else if (foldedRightToLeft) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            [self unfoldLeftToRight];
        }
    } else if (foldedTopToBottom) {
        // do nothing
    } else if (foldedBottomToTop) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            [self unfoldTopToBottom];
        }
    } else {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            [self foldLeftToRight];
        } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            [self foldTopToBottom];
        }
    }
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
    
    if (foldedLeftToRight) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            [self unfoldRightToLeft];
        }
    } else if (foldedRightToLeft) {
        // do nothing
    } else if (foldedTopToBottom) {
        // do nothing
    } else if (foldedBottomToTop) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            [self unfoldTopToBottom];
        }
    } else {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            [self foldRightToLeft];
        } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            [self foldTopToBottom];
        }
    }
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

    if (foldedLeftToRight) {
        // do nothing
    } else if (foldedRightToLeft) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            [self unfoldLeftToRight];
        }
    } else if (foldedTopToBottom) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            [self unfoldBottomToTop];
        }
    } else if (foldedBottomToTop) {
        // do nothing
    } else {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            [self foldLeftToRight];
        } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            [self foldBottomToTop];
        }
    }
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

    if (foldedLeftToRight) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            [self unfoldRightToLeft];
        }
    } else if (foldedRightToLeft) {
        // do nothing
    } else if (foldedTopToBottom) {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            [self unfoldBottomToTop];
        }
    } else if (foldedBottomToTop) {
        // do nothing
    } else {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            [self foldRightToLeft];
        } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            [self foldBottomToTop];
        }
    }
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.topLeftImageView.userInteractionEnabled = YES;
        self.topRightImageView.userInteractionEnabled = YES;
        self.bottomLeftImageView.userInteractionEnabled = YES;
        self.bottomRightImageView.userInteractionEnabled = YES;
        
        topLeftImageViewFoldController = [[FoldController alloc] initWithTarget:self.topLeftImageView];
        topRightImageViewFoldController = [[FoldController alloc] initWithTarget:self.topRightImageView];
        bottomLeftImageViewFoldController = [[FoldController alloc] initWithTarget:self.bottomLeftImageView];
        bottomRightImageViewFoldController = [[FoldController alloc] initWithTarget:self.bottomRightImageView];
        
        [self setupGestureRecognizers:self.topLeftImageView
                            tapAction:@selector(topLeft:)
                          swipeAction:@selector(topLeftSwipe:)];
        
        [self setupGestureRecognizers:self.topRightImageView
                            tapAction:@selector(topRight:)
                          swipeAction:@selector(topRightSwipe:)];
        
        [self setupGestureRecognizers:self.bottomLeftImageView
                            tapAction:@selector(bottomLeft:)
                          swipeAction:@selector(bottomLeftSwipe:)];
        
        [self setupGestureRecognizers:self.bottomRightImageView
                            tapAction:@selector(bottomRight:)
                          swipeAction:@selector(bottomRightSwipe:)];
    }
    return self;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
