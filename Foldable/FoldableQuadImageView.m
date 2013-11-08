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
//    anim.fillMode = kCAFillModeForwards;
//    anim.removedOnCompletion = NO;
    
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
//    anim.fillMode = kCAFillModeForwards;
//    anim.removedOnCompletion = NO;
    
    return anim;
}

@end

@interface UIView (Foldable)
@property (nonatomic) BOOL folded;
@property (nonatomic) CABasicAnimation *unfoldAnim;
@property (nonatomic) CGPoint anchorPoint;

- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint;
- (void)unfold;

@end

@implementation UIView (Foldable)

static const void *kFolded = &kFolded;
static const void *kUnfoldAnim = &kUnfoldAnim;
static const void *kAnchorPoint = &kAnchorPoint;

- (BOOL)folded
{
    return [objc_getAssociatedObject(self, kFolded) boolValue];
}

- (void)setFolded:(BOOL)folded
{
    objc_setAssociatedObject(self, kFolded, [NSNumber numberWithBool:folded], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CABasicAnimation *)unfoldAnim
{
    return objc_getAssociatedObject(self, kUnfoldAnim);
}

- (void)setUnfoldAnim:(CABasicAnimation *)unfoldAnim
{
    objc_setAssociatedObject(self, kUnfoldAnim, unfoldAnim, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)anchorPoint
{
    return [objc_getAssociatedObject(self, kAnchorPoint) CGPointValue];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    objc_setAssociatedObject(self, kAnchorPoint, [CIVector vectorWithCGPoint:anchorPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%s: finished = %d", __FUNCTION__, flag);
    NSLog(@"before %@", [NSValue valueWithCGRect:self.frame]);
    self.transform = CATransform3DGetAffineTransform([anim.toValue CATransform3DValue]);
    NSLog(@"after  %@", [NSValue valueWithCGRect:self.frame]);
//    [self.layer removeAllAnimations];
    [self.superview bringSubviewToFront:self];
}

- (void)applyAnimation:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint
{
    CGRect frame = self.frame;
    self.layer.anchorPoint = anchorPoint;
    self.layer.position = CGPointMake(frame.origin.x + anchorPoint.x * frame.size.width,
                                      frame.origin.y + anchorPoint.y * frame.size.height);
//    self.layer.anchorPoint = CGPointApplyAffineTransform(self.layer.anchorPoint, self.transform);
//    self.layer.position = CGPointApplyAffineTransform(self.layer.position, self.transform);
    self.layer.zPosition = 1000; // 実験して決めた
    anim.delegate = self;
    [self.layer addAnimation:anim forKey:nil];
//    self.layer.transform = [anim.fromValue CATransform3DValue];
//    [UIView animateWithDuration:0.8
//                     animations:^{
//                         CATransform3D transform = [anim.toValue CATransform3DValue];
//                         self.layer.transform = transform;
//                     }
//                     completion:^(BOOL finished) {
//                         [self.superview bringSubviewToFront:self];
//                     }];
}

- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint
{
    if (self.folded) {
        NSLog(@"warning: the view has been folded");
        return;
    }

    [self applyAnimation:anim anchorPoint:anchorPoint];
    
    self.folded = YES;
    self.unfoldAnim = [anim copy];
//    NSNumber *tmp = anim.fromValue;
//    self.unfoldAnim.fromValue = anim.toValue;
//    self.unfoldAnim.toValue = tmp;
//    //self.anchorPoint = anchorPoint;
//    self.anchorPoint = CGPointMake(0, 0);
}

- (void)unfold
{
    if (!self.folded) {
        NSLog(@"warning: the view has not been folded");
        return;
    }

//    self.transform = CGAffineTransformIdentity;
    [self applyAnimation:self.unfoldAnim anchorPoint:self.anchorPoint];
    
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
    [self.topLeftImageView fold:foldDownAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [self.topRightImageView fold:foldDownAnim anchorPoint:CGPointMake(0.0, 1.0)];
    
    foldedTopToBottom = YES;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.topRightImageView unfold];
    [self.topLeftImageView unfold];
    
    foldedTopToBottom = NO;
}

- (void)foldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldUpAnim = [CABasicAnimation makeXRotationFrom:0 to:-M_PI m34:1.0/500];
    [self resetZPosition];
    [self.bottomLeftImageView fold:foldUpAnim anchorPoint:CGPointMake(1.0, 0.0)];
    [self.bottomRightImageView fold:foldUpAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedBottomToTop = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.bottomRightImageView unfold];
    [self.bottomLeftImageView unfold];
    
    foldedBottomToTop = NO;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldRightAnim = [CABasicAnimation makeYRotationFrom:0 to:M_PI m34:1.0/500];
    [self resetZPosition];
    [self.topLeftImageView fold:foldRightAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [self.bottomLeftImageView fold:foldRightAnim anchorPoint:CGPointMake(1.0, 0.0)];
    
    foldedLeftToRight = YES;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.topLeftImageView unfold];
    [self.bottomLeftImageView unfold];
    
    foldedLeftToRight = NO;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldLeftAnim = [CABasicAnimation makeYRotationFrom:0 to:-M_PI m34:-1.0/500];
    [self resetZPosition];
    [self.topRightImageView fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 1.0)];
    [self.bottomRightImageView fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedRightToLeft = YES;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.topRightImageView unfold];
    [self.bottomRightImageView unfold];
    
    foldedRightToLeft = NO;
}

- (void)tap:(UITapGestureRecognizer*)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    NSLog(@"%s: %@", __FUNCTION__, view);

    [self resetZPosition];
    
    if (view == self.topLeftImageView) {
        NSLog(@"topLeftImageView");
        if (!view.folded) {
            [self foldLeftToRight];
        } else if (foldedRightToLeft) {
            [self unfoldRightToLeft];
        } else if (foldedBottomToTop) {
            [self unfoldBottomToTop];
        } else {
            [view unfold];
        }
    } else if (view == self.topRightImageView) {
        NSLog(@"topRightImageView");
        if (!view.folded) {
            [self foldRightToLeft];
        } else if (foldedLeftToRight) {
            [self unfoldLeftToRight];
        } else if (foldedBottomToTop) {
            [self unfoldBottomToTop];
        }
    } else if (view == self.bottomLeftImageView) {
        NSLog(@"bottomLeftImageView");
        if (!view.folded) {
            [self foldLeftToRight];
        } else if (foldedRightToLeft) {
            [self unfoldRightToLeft];
        } else if (foldedTopToBottom) {
            [self unfoldTopToBottom];
        }
    } else if (view == self.bottomRightImageView) {
        NSLog(@"bottomRightImageView");
        if (!view.folded) {
            [self foldRightToLeft];
        } else if (foldedLeftToRight) {
            [self unfoldLeftToRight];
        } else if (foldedTopToBottom) {
            [self unfoldTopToBottom];
        }
    } else {
        NSLog(@"can't happen");
        abort();
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
    
    UIView *view = gestureRecognizer.view;
    
    [self resetZPosition];

    if (foldedLeftToRight && (view == self.topRightImageView || self == self.bottomRightImageView)) {
        [self.topLeftImageView unfold];
        [self.bottomLeftImageView unfold];
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

- (void)topLeft:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: %@", __FUNCTION__, gestureRecognizer.view);

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
        
//        [self setupGestureRecognizers:self.topLeftImageView
//                            tapAction:@selector(topLeft:)
//                          swipeAction:@selector(topLeftSwipe:)];
//        
//        [self setupGestureRecognizers:self.topRightImageView
//                            tapAction:@selector(topRight:)
//                          swipeAction:@selector(topRightSwipe:)];
//        
//        [self setupGestureRecognizers:self.bottomLeftImageView
//                            tapAction:@selector(bottomLeft:)
//                          swipeAction:@selector(bottomLeftSwipe:)];
//        
//        [self setupGestureRecognizers:self.bottomRightImageView
//                            tapAction:@selector(bottomRight:)
//                          swipeAction:@selector(bottomRightSwipe:)];
////////
        [self setupGestureRecognizers:self.topLeftImageView
                            tapAction:@selector(tap:)
                          swipeAction:@selector(topLeftSwipe:)];
        
        [self setupGestureRecognizers:self.topRightImageView
                            tapAction:@selector(tap:)
                          swipeAction:@selector(topRightSwipe:)];
        
        [self setupGestureRecognizers:self.bottomLeftImageView
                            tapAction:@selector(tap:)
                          swipeAction:@selector(bottomLeftSwipe:)];
        
        [self setupGestureRecognizers:self.bottomRightImageView
                            tapAction:@selector(tap:)
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
