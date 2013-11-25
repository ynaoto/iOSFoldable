//
//  FoldableQuadImageView.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/05.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "FoldableQuadImageView.h"
#import "CATransaction+Sequence.h"

@interface FoldableQuadImageView () <UIGestureRecognizerDelegate>

@end

@implementation FoldableQuadImageView
{
    CGPoint panVelocity;
    BOOL animating;
}

- (BOOL)isTop:(CGPoint)p
{
    return (p.y <= self.frame.size.height / 2);
}

- (BOOL)isBottom:(CGPoint)p
{
    return (self.frame.size.height / 2 <= p.y);
}

- (BOOL)isLeft:(CGPoint)p
{
    return (p.x <= self.frame.size.width / 2);
}

- (BOOL)isRight:(CGPoint)p
{
    return (self.frame.size.width / 2 <= p.x);
}

- (void)setLayersVisibility:(FoldStatus)status
{
    NSArray *visibles, *invisibles;
    CALayer *TR = self.topRightLayer;
    CALayer *TL = self.topLeftLayer;
    CALayer *BR = self.bottomRightLayer;
    CALayer *BL = self.bottomLeftLayer;
    
    switch (status) {
        case FoldStatusNone:      visibles = @[ TL, TR, BL, BR ]; invisibles = @[]; break;
        case FoldStatusRight:     visibles = @[ TL, BL ]; invisibles = @[ TR, BR ]; break;
        case FoldStatusRightUp:   visibles = @[ BR ]; invisibles = @[ TR, TL, BL ]; break;
        case FoldStatusRightDown: visibles = @[ TR ]; invisibles = @[ BR, BL, TL ]; break;
        case FoldStatusLeft:      visibles = @[ TR, BR ]; invisibles = @[ TL, BL ]; break;
        case FoldStatusLeftUp:    visibles = @[ BL ]; invisibles = @[ TL, TR, BR ]; break;
        case FoldStatusLeftDown:  visibles = @[ TL ]; invisibles = @[ BL, BR, TR ]; break;
        case FoldStatusUp:        visibles = @[ BL, BR ]; invisibles = @[ TL, TR ]; break;
        case FoldStatusUpRight:   visibles = @[ TL ]; invisibles = @[ TR, BR, BL ]; break;
        case FoldStatusUpLeft:    visibles = @[ TR ]; invisibles = @[ TL, BL, BR ]; break;
        case FoldStatusDown:      visibles = @[ TL, TR ]; invisibles = @[ BL, BR ]; break;
        case FoldStatusDownRight: visibles = @[ BL ]; invisibles = @[ BR, TR, TL ]; break;
        case FoldStatusDownLeft:  visibles = @[ BR ]; invisibles = @[ BL, TL, TR ]; break;
            
        default:
            NSLog(@"can't happen");
            abort();
    }

    self.layer.sublayers = [invisibles arrayByAddingObjectsFromArray:visibles];;
}

- (void)rotateLayer1:(CALayer*)layer1 r1:(CGFloat)r1
              layer2:(CALayer*)layer2 r2:(CGFloat)r2
                  ax:(CGFloat)ax ay:(CGFloat)ay az:(CGFloat)az
              status:(FoldStatus)status
{
    if (animating) {
        return;
    }
    animating = YES;

    const CFTimeInterval dur = self.animationDuration;
    const float firstHalfRatio = 0.5;
    const float lastHalfRatio = 1.0 - firstHalfRatio;
    CAMediaTimingFunction *firstHalfTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    CAMediaTimingFunction *lastHalfTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [CATransaction animationSequence:@[
            ^{
                [CATransaction setAnimationDuration:firstHalfRatio*dur];
                [CATransaction setAnimationTimingFunction:firstHalfTimingFunction];
                layer1.transform = CATransform3DRotate(layer1.transform, firstHalfRatio*r1, ax, ay, az);
                layer2.transform = CATransform3DRotate(layer2.transform, firstHalfRatio*r2, ax, ay, az);
            },
            ^{
                [self setLayersVisibility:status]; // 後半開始時にレイヤの順序を入れ替える
                [CATransaction setAnimationDuration:lastHalfRatio*dur];
                [CATransaction setAnimationTimingFunction:lastHalfTimingFunction];
                layer1.transform = CATransform3DRotate(layer1.transform, lastHalfRatio*r1, ax, ay, az);
                layer2.transform = CATransform3DRotate(layer2.transform, lastHalfRatio*r2, ax, ay, az);
            },
        ]
        completed:^{
            _status = status;
            animating = NO;
        }];
}

- (void)rotateXLayer1:(CALayer*)layer1 r1:(CGFloat)r1
               layer2:(CALayer*)layer2 r2:(CGFloat)r2
               status:(FoldStatus)status
{
    [self rotateLayer1:layer1 r1:r1
                layer2:layer2 r2:r2
                    ax:1.0 ay:0.0 az:0.0
                status:status];
}

- (void)rotateYLayer1:(CALayer*)layer1 r1:(CGFloat)r1
               layer2:(CALayer*)layer2 r2:(CGFloat)r2
               status:(FoldStatus)status
{
    [self rotateLayer1:layer1 r1:r1
                layer2:layer2 r2:r2
                    ax:0.0 ay:1.0 az:0.0
                status:status];
}

- (void)setStatus:(FoldStatus)status
{
    NSLog(@"%s: self.status = %d, status = %d, animating = %d", __FUNCTION__, self.status, status, animating);

    if (self.status == status) {
        return;
    }

    BOOL invalid = NO;

    CALayer *TR = self.topRightLayer;
    CALayer *TL = self.topLeftLayer;
    CALayer *BR = self.bottomRightLayer;
    CALayer *BL = self.bottomLeftLayer;

    if (self.status == FoldStatusNone) {
        switch (status) {
            case FoldStatusRight: [self rotateYLayer1:TL r1:+M_PI layer2:BL r2:+M_PI status:status]; break; // 右に畳む
            case FoldStatusLeft:  [self rotateYLayer1:TR r1:-M_PI layer2:BR r2:-M_PI status:status]; break; // 左に畳む
            case FoldStatusUp:    [self rotateXLayer1:BL r1:+M_PI layer2:BR r2:+M_PI status:status]; break; // 上に畳む
            case FoldStatusDown:  [self rotateXLayer1:TL r1:-M_PI layer2:TR r2:-M_PI status:status]; break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRight) {
        switch (status) {
            case FoldStatusNone:      [self rotateYLayer1:TL r1:-M_PI layer2:BL r2:-M_PI status:status]; break; // 左に開く
            case FoldStatusRightUp:   [self rotateXLayer1:BL r1:-M_PI layer2:BR r2:+M_PI status:status]; break; // 上に畳む
            case FoldStatusRightDown: [self rotateXLayer1:TL r1:+M_PI layer2:TR r2:-M_PI status:status]; break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightUp) {
        switch (status) {
            case FoldStatusRight: [self rotateXLayer1:BL r1:+M_PI layer2:BR r2:-M_PI status:status]; break; // 下に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightDown) {
        switch (status) {
            case FoldStatusRight: [self rotateXLayer1:TL r1:-M_PI layer2:TR r2:+M_PI status:status]; break; // 上に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeft) {
        switch (status) {
            case FoldStatusNone:     [self rotateYLayer1:TR r1:+M_PI layer2:BR r2:+M_PI status:status]; break; // 右に開く
            case FoldStatusLeftUp:   [self rotateXLayer1:BL r1:+M_PI layer2:BR r2:-M_PI status:status]; break; // 上に畳む
            case FoldStatusLeftDown: [self rotateXLayer1:TL r1:-M_PI layer2:TR r2:+M_PI status:status]; break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftUp) {
        switch (status) {
            case FoldStatusLeft: [self rotateXLayer1:BL r1:-M_PI layer2:BR r2:+M_PI status:status]; break; // 下に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftDown) {
        switch (status) {
            case FoldStatusLeft: [self rotateXLayer1:TL r1:+M_PI layer2:TR r2:-M_PI status:status]; break; // 上に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUp) {
        switch (status) {
            case FoldStatusNone:    [self rotateXLayer1:BL r1:-M_PI layer2:BR r2:-M_PI status:status]; break; // 下に開く
            case FoldStatusUpRight: [self rotateYLayer1:TL r1:+M_PI layer2:BL r2:-M_PI status:status]; break; // 右へ畳む
            case FoldStatusUpLeft:  [self rotateYLayer1:TR r1:-M_PI layer2:BR r2:+M_PI status:status]; break; // 左へ畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpRight) {
        switch (status) {
            case FoldStatusUp: [self rotateYLayer1:TL r1:-M_PI layer2:BL r2:+M_PI status:status]; break; // 左に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpLeft) {
        switch (status) {
            case FoldStatusUp: [self rotateYLayer1:TR r1:+M_PI layer2:BR r2:-M_PI status:status]; break; // 右に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDown) {
        switch (status) {
            case FoldStatusNone:      [self rotateXLayer1:TR r1:+M_PI layer2:TL r2:+M_PI status:status]; break; // 上に開く
            case FoldStatusDownRight: [self rotateYLayer1:TL r1:-M_PI layer2:BL r2:+M_PI status:status]; break; // 右に畳む
            case FoldStatusDownLeft:  [self rotateYLayer1:TR r1:+M_PI layer2:BR r2:-M_PI status:status]; break; // 左に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownRight) {
        switch (status) {
            case FoldStatusDown: [self rotateYLayer1:TL r1:+M_PI layer2:BL r2:-M_PI status:status]; break; // 左に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownLeft) {
        switch (status) {
            case FoldStatusDown: [self rotateYLayer1:TR r1:-M_PI layer2:BR r2:+M_PI status:status]; break; // 右に開く
            default: invalid = YES;
        }
    } else {
        NSLog(@"can't happen");
        abort();
    }
    
    if (invalid) {
        NSLog(@"warning: invalid status %d", status);
    }
}

- (void)tap:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: status = %d", __FUNCTION__, self.status);

    CGPoint p = [gestureRecognizer locationInView:self];
    
    // 少し乱数を使って、全てのパタンを出すようにする
    int n = arc4random();
    
    if (self.status == FoldStatusNone) {
        // 左右に畳むか、上下に畳むか
        if (n % 2 == 0) { // 左右
            if ([self isLeft:p]) {
                self.status = FoldStatusRight;
            } else {
                self.status = FoldStatusLeft;
            }
        } else { // 上下
            if ([self isBottom:p]) {
                self.status = FoldStatusUp;
            } else {
                self.status = FoldStatusDown;
            }
        }
    } else if (self.status == FoldStatusRight && [self isRight:p]) {
        // 左に開くか、上下に畳むか
        if (n % 2 == 0) { // 左に開く
            self.status = FoldStatusNone;
        } else { // 上下に畳む
            if ([self isBottom:p]) {
                self.status = FoldStatusRightUp;
            } else if ([self isTop:p]) {
                self.status = FoldStatusRightDown;
            }
        }
    } else if (self.status == FoldStatusRightUp && [self isRight:p] && [self isTop:p]) {
        self.status = FoldStatusRight;
    } else if (self.status == FoldStatusRightDown && [self isRight:p] && [self isBottom:p]) {
        self.status = FoldStatusRight;
    } else if (self.status == FoldStatusLeft && [self isLeft:p]) {
        // 右に開くか、上下に畳むか
        if (n % 2 == 0) { // 右に開く
            self.status = FoldStatusNone;
        } else { // 上下に畳む
            if ([self isBottom:p]) {
                self.status = FoldStatusLeftUp;
            } else if ([self isTop:p]) {
                self.status = FoldStatusLeftDown;
            }
        }
    } else if (self.status == FoldStatusLeftUp && [self isLeft:p] && [self isTop:p]) {
        self.status = FoldStatusLeft;
    } else if (self.status == FoldStatusLeftDown && [self isLeft:p] && [self isBottom:p]) {
        self.status = FoldStatusLeft;
    } else if (self.status == FoldStatusUp && [self isTop:p]) {
        // 下に開くか、左右に畳むか
        if (n % 2 == 0) { // 下に開く
            self.status = FoldStatusNone;
        } else { // 左右に畳む
            if ([self isLeft:p]) {
                self.status = FoldStatusUpRight;
            } else if ([self isRight:p]) {
                self.status = FoldStatusUpLeft;
            }
        }
    } else if (self.status == FoldStatusUpRight && [self isRight:p] && [self isTop:p]) {
        self.status = FoldStatusUp;
    } else if (self.status == FoldStatusUpLeft && [self isLeft:p] && [self isTop:p]) {
        self.status = FoldStatusUp;
    } else if (self.status == FoldStatusDown && [self isBottom:p]) {
        // 上に開くか、左右に畳むか
        if (n % 2 == 0) { // 上に開く
            self.status = FoldStatusNone;
        } else { // 左右に畳む
            if ([self isLeft:p]) {
                self.status = FoldStatusDownRight;
            } else if ([self isRight:p]) {
                self.status = FoldStatusDownLeft;
            }
        }
    } else if (self.status == FoldStatusDownRight && [self isRight:p] && [self isBottom:p]) {
        self.status = FoldStatusDown;
    } else if (self.status == FoldStatusDownLeft && [self isLeft:p] && [self isBottom:p]) {
        self.status = FoldStatusDown;
    } else {
        NSLog(@"do nothing.");
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %d, status = %d", __FUNCTION__, (int)gestureRecognizer.direction, self.status);
    
    CGPoint p = [gestureRecognizer locationInView:self];
    UISwipeGestureRecognizerDirection direction = gestureRecognizer.direction;

    float dv = hypotf(panVelocity.x, panVelocity.y);
    NSLog(@"panVelocity = (%f, %f), dv = %f", panVelocity.x, panVelocity.y, dv);
    self.animationDuration = 500 / dv;
    
    if (self.status == FoldStatusNone) {
        // 左右に畳むか、上下に畳むか
        if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusRight;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusLeft;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusUp;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusDown;
        }
    } else if (self.status == FoldStatusRight && [self isRight:p]) {
        // 左に開くか、上下に畳むか
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusNone;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusRightUp;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusRightDown;
        }
    } else if (self.status == FoldStatusRightUp && [self isRight:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusRight;
        }
    } else if (self.status == FoldStatusRightDown && [self isRight:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusRight;
        }
    } else if (self.status == FoldStatusLeft && [self isLeft:p]) {
        // 右に開くか、上下に畳むか
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusNone;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusLeftUp;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusLeftDown;
        }
    } else if (self.status == FoldStatusLeftUp && [self isLeft:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusLeft;
        }
    } else if (self.status == FoldStatusLeftDown && [self isLeft:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusLeft;
        }
    } else if (self.status == FoldStatusUp && [self isTop:p]) {
        // 下に開くか、左右に畳むか
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            self.status = FoldStatusNone;
        } else if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusUpRight;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusUpLeft;
        }
    } else if (self.status == FoldStatusUpRight && [self isRight:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusUp;
        }
    } else if (self.status == FoldStatusUpLeft && [self isLeft:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusUp;
        }
    } else if (self.status == FoldStatusDown && [self isBottom:p]) {
        // 上に開くか、左右に畳むか
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            self.status = FoldStatusNone;
        } else if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusDownRight;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusDownLeft;
        }
    } else if (self.status == FoldStatusDownRight && [self isRight:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            self.status = FoldStatusDown;
        }
    } else if (self.status == FoldStatusDownLeft && [self isLeft:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            self.status = FoldStatusDown;
        }
    } else {
        NSLog(@"do nothing.");
    }
}

- (void)pan:(UIPanGestureRecognizer*)gestureRecognizer
{
//    NSLog(@"%s: status = %d", __FUNCTION__, self.status);
    
    panVelocity = [gestureRecognizer velocityInView:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeGestureRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer;

    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
    for (UIGestureRecognizer *g in self.gestureRecognizers) {
        g.delegate = self;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setupGestureRecognizers];
        self.status = FoldStatusNone;
        self.animationDuration = 0.8;
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
