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

+ (CABasicAnimation*)makeXRotationAnimation:(CGFloat)r;
+ (CABasicAnimation*)makeYRotationAnimation:(CGFloat)r;

@end

@implementation CABasicAnimation (XYRotation)

static const int kLargeNum = 1000000; // M_PI の回転が、どちらむきになるかがわからないのを防ぐ
static const CFTimeInterval kDuration = 0.8;

+ (CABasicAnimation*)makeXRotationAnimation:(CGFloat)r
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D transform = CATransform3DIdentity;
    anim.toValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, (kLargeNum-1)*r/kLargeNum, 1.0, 0.0, 0.0)];
    anim.duration = kDuration;
    anim.repeatCount = 1;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    return anim;
}

+ (CABasicAnimation*)makeYRotationAnimation:(CGFloat)r
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D transform = CATransform3DIdentity;
    anim.toValue = [NSNumber valueWithCATransform3D:CATransform3DRotate(transform, (kLargeNum-1)*r/kLargeNum, 0.0, 1.0, 0.0)];
    anim.duration = kDuration;
    anim.repeatCount = 1;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    return anim;
}

@end

@interface CALayer (Foldable)
@property (nonatomic) BOOL folded;
@property (nonatomic) CABasicAnimation *unfoldAnim;

- (void)fold:(CABasicAnimation*)anim;
- (void)unfold;

@end

@implementation CALayer (Foldable)

static const void *kFolded = &kFolded;
static const void *kUnfoldAnim = &kUnfoldAnim;

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

- (void)fold:(CABasicAnimation*)anim
{
    if (self.folded) {
        NSLog(@"warning: the view has been folded");
        return;
    }

    [self addAnimation:anim forKey:nil];
    
    self.folded = YES;
    self.unfoldAnim = [anim copy];
    self.unfoldAnim.toValue = nil; // just remove the animation
}

- (void)unfold
{
    if (!self.folded) {
        NSLog(@"warning: the view has not been folded");
        return;
    }

    [self addAnimation:self.unfoldAnim forKey:nil];
    
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

- (void)foldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldDownAnim = [CABasicAnimation makeXRotationAnimation:-M_PI];
    [self.topLeftLayer fold:foldDownAnim];
    [self.topRightLayer fold:foldDownAnim];
    
    foldedTopToBottom = YES;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.topRightLayer unfold];
    [self.topLeftLayer unfold];
    
    foldedTopToBottom = NO;
}

- (void)foldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldUpAnim = [CABasicAnimation makeXRotationAnimation:M_PI];
    [self.bottomLeftLayer fold:foldUpAnim];
    [self.bottomRightLayer fold:foldUpAnim];
    
    foldedBottomToTop = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.bottomRightLayer unfold];
    [self.bottomLeftLayer unfold];
    
    foldedBottomToTop = NO;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldRightAnim = [CABasicAnimation makeYRotationAnimation:M_PI];
    [self.topLeftLayer fold:foldRightAnim];
    [self.bottomLeftLayer fold:foldRightAnim];
    
    foldedLeftToRight = YES;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.topLeftLayer unfold];
    [self.bottomLeftLayer unfold];
    
    foldedLeftToRight = NO;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldLeftAnim = [CABasicAnimation makeYRotationAnimation:-M_PI];
    [self.topRightLayer fold:foldLeftAnim];
    [self.bottomRightLayer fold:foldLeftAnim];
    
    foldedRightToLeft = YES;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.topRightLayer unfold];
    [self.bottomRightLayer unfold];
    
    foldedRightToLeft = NO;
}

- (BOOL)isTopLeft:(CGPoint)p
{
    return (p.x <= self.frame.size.width / 2) && (p.y <= self.frame.size.height / 2);
}

- (BOOL)isTopRight:(CGPoint)p
{
    return (self.frame.size.width / 2 <= p.x) && (p.y <= self.frame.size.height / 2);
}

- (BOOL)isBottomLeft:(CGPoint)p
{
    return (p.x <= self.frame.size.width / 2) && (self.frame.size.height / 2 <= p.y);
}

- (BOOL)isBottomRight:(CGPoint)p
{
    return (self.frame.size.width / 2 <= p.x) && (self.frame.size.height / 2 <= p.y);
}

- (void)tap:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);

    CGPoint p = [gestureRecognizer locationInView:self];
    if ([self isTopLeft:p]) {
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
    } else if ([self isTopRight:p]) {
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
    } else if ([self isBottomLeft:p]) {
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
    } else if ([self isBottomRight:p]) {
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
    } else {
        NSLog(@"can't happen");
        abort();
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %u", __FUNCTION__, gestureRecognizer.direction);
    
    CGPoint p = [gestureRecognizer locationInView:self];
    UISwipeGestureRecognizerDirection direction = gestureRecognizer.direction;
    if ([self isTopLeft:p]) {
        if (foldedLeftToRight) {
            // do nothing
        } else if (foldedRightToLeft) {
            if (direction == UISwipeGestureRecognizerDirectionRight) {
                [self unfoldLeftToRight];
            }
        } else if (foldedTopToBottom) {
            // do nothing
        } else if (foldedBottomToTop) {
            if (direction == UISwipeGestureRecognizerDirectionDown) {
                [self unfoldTopToBottom];
            }
        } else {
            if (direction == UISwipeGestureRecognizerDirectionRight) {
                [self foldLeftToRight];
            } else if (direction == UISwipeGestureRecognizerDirectionDown) {
                [self foldTopToBottom];
            }
        }
    } else if ([self isTopRight:p]) {
        if (foldedLeftToRight) {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                [self unfoldRightToLeft];
            }
        } else if (foldedRightToLeft) {
            // do nothing
        } else if (foldedTopToBottom) {
            // do nothing
        } else if (foldedBottomToTop) {
            if (direction == UISwipeGestureRecognizerDirectionDown) {
                [self unfoldTopToBottom];
            }
        } else {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                [self foldRightToLeft];
            } else if (direction == UISwipeGestureRecognizerDirectionDown) {
                [self foldTopToBottom];
            }
        }
    } else if ([self isBottomLeft:p]) {
        if (foldedLeftToRight) {
            // do nothing
        } else if (foldedRightToLeft) {
            if (direction == UISwipeGestureRecognizerDirectionRight) {
                [self unfoldLeftToRight];
            }
        } else if (foldedTopToBottom) {
            if (direction == UISwipeGestureRecognizerDirectionUp) {
                [self unfoldBottomToTop];
            }
        } else if (foldedBottomToTop) {
            // do nothing
        } else {
            if (direction == UISwipeGestureRecognizerDirectionRight) {
                [self foldLeftToRight];
            } else if (direction == UISwipeGestureRecognizerDirectionUp) {
                [self foldBottomToTop];
            }
        }
    } else if ([self isBottomRight:p]) {
        if (foldedLeftToRight) {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                [self unfoldRightToLeft];
            }
        } else if (foldedRightToLeft) {
            // do nothing
        } else if (foldedTopToBottom) {
            if (direction == UISwipeGestureRecognizerDirectionUp) {
                [self unfoldBottomToTop];
            }
        } else if (foldedBottomToTop) {
            // do nothing
        } else {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                [self foldRightToLeft];
            } else if (direction == UISwipeGestureRecognizerDirectionUp) {
                [self foldBottomToTop];
            }
        }
    } else {
        NSLog(@"can't happen");
        abort();
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
        self.userInteractionEnabled = YES;
        [self setupGestureRecognizers:self
                            tapAction:@selector(tap:)
                          swipeAction:@selector(swipe:)];
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
