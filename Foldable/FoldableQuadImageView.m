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

@interface CALayer (Foldable)
@property (nonatomic) BOOL folded;
@property (nonatomic) CABasicAnimation *unfoldAnim;

- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint;
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

- (void)applyAnimation:(CABasicAnimation*)anim
{
    self.zPosition = 1000; // 実験して決めた
    [self addAnimation:anim forKey:nil];
}

- (void)fold:(CABasicAnimation*)anim anchorPoint:(CGPoint)anchorPoint
{
    if (self.folded) {
        NSLog(@"warning: the view has been folded");
        return;
    }

    CGRect frame = self.frame;
    self.position = CGPointMake(frame.origin.x + anchorPoint.x * frame.size.width,
                                frame.origin.y + anchorPoint.y * frame.size.height);
    self.anchorPoint = anchorPoint;
    [self applyAnimation:anim];
    
    self.folded = YES;
    self.unfoldAnim = [anim copy];
    NSNumber *tmp = anim.fromValue;
    self.unfoldAnim.fromValue = anim.toValue;
    self.unfoldAnim.toValue = tmp;
}

- (void)unfold
{
    if (!self.folded) {
        NSLog(@"warning: the view has not been folded");
        return;
    }

    [self applyAnimation:self.unfoldAnim];
    
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
    self.topLeftLayer.zPosition = 0;
    self.topRightLayer.zPosition = 0;
    self.bottomLeftLayer.zPosition = 0;
    self.bottomRightLayer.zPosition = 0;
}

- (void)foldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldDownAnim = [CABasicAnimation makeXRotationFrom:0 to:M_PI m34:-1.0/500];
    [self resetZPosition];
    [self.topLeftLayer fold:foldDownAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [self.topRightLayer fold:foldDownAnim anchorPoint:CGPointMake(0.0, 1.0)];
    
    foldedTopToBottom = YES;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.topRightLayer unfold];
    [self.topLeftLayer unfold];
    
    foldedTopToBottom = NO;
}

- (void)foldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldUpAnim = [CABasicAnimation makeXRotationFrom:0 to:-M_PI m34:1.0/500];
    [self resetZPosition];
    [self.bottomLeftLayer fold:foldUpAnim anchorPoint:CGPointMake(1.0, 0.0)];
    [self.bottomRightLayer fold:foldUpAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedBottomToTop = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.bottomRightLayer unfold];
    [self.bottomLeftLayer unfold];
    
    foldedBottomToTop = NO;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldRightAnim = [CABasicAnimation makeYRotationFrom:0 to:M_PI m34:1.0/500];
    [self resetZPosition];
    [self.topLeftLayer fold:foldRightAnim anchorPoint:CGPointMake(1.0, 1.0)];
    [self.bottomLeftLayer fold:foldRightAnim anchorPoint:CGPointMake(1.0, 0.0)];
    
    foldedLeftToRight = YES;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
    [self.topLeftLayer unfold];
    [self.bottomLeftLayer unfold];
    
    foldedLeftToRight = NO;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    
    CABasicAnimation *foldLeftAnim = [CABasicAnimation makeYRotationFrom:0 to:-M_PI m34:-1.0/500];
    [self resetZPosition];
    [self.topRightLayer fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 1.0)];
    [self.bottomRightLayer fold:foldLeftAnim anchorPoint:CGPointMake(0.0, 0.0)];
    
    foldedRightToLeft = YES;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    
    [self resetZPosition];
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
