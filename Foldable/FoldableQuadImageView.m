//
//  FoldableQuadImageView.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/05.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "FoldableQuadImageView.h"

static void rotateLayers(NSArray *layers, CGFloat r, CGFloat ax, CGFloat ay, CGFloat az)
{
    [CATransaction setAnimationDuration:0.8];
    for (CALayer *layer in layers) {
        layer.transform = CATransform3DMakeRotation(0.999*r, ax, ay, az);
    }
    [CATransaction commit];
}

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
    rotateLayers(@[self.topLeftLayer, self.topRightLayer], -M_PI, 1.0, 0.0, 0.0);
    foldedTopToBottom = YES;
}

- (void)unfoldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.topLeftLayer, self.topRightLayer], 0, 1.0, 0.0, 0.0);
    foldedTopToBottom = NO;
}

- (void)foldBottomToTop
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.bottomLeftLayer, self.bottomRightLayer], M_PI, 1.0, 0.0, 0.0);
    foldedBottomToTop = YES;
}

- (void)unfoldTopToBottom
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.bottomLeftLayer, self.bottomRightLayer], 0, 1.0, 0.0, 0.0);
    foldedBottomToTop = NO;
}

- (void)foldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.topLeftLayer, self.bottomLeftLayer], M_PI, 0.0, 1.0, 0.0);
    foldedLeftToRight = YES;
}

- (void)unfoldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.topLeftLayer, self.bottomLeftLayer], 0, 0.0, 1.0, 0.0);
    foldedLeftToRight = NO;
}

- (void)foldRightToLeft
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.topRightLayer, self.bottomRightLayer], -M_PI, 0.0, 1.0, 0.0);
    foldedRightToLeft = YES;
}

- (void)unfoldLeftToRight
{
    NSLog(@"%s", __FUNCTION__);
    rotateLayers(@[self.topRightLayer, self.bottomRightLayer], 0, 0.0, 1.0, 0.0);
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
    NSLog(@"%s: dir = %d", __FUNCTION__, (int)gestureRecognizer.direction);
    
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
