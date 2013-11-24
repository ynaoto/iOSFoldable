//
//  FoldableQuadImageView.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/05.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "FoldableQuadImageView.h"

@interface FoldableQuadImageView () <UIGestureRecognizerDelegate>

@end

@implementation FoldableQuadImageView
{
    CGPoint panVelocity;
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
    
    if (self.alpha < 1.0) {
        visibles = @[ TL, TR, BL, BR ]; invisibles = @[];
    } else {
        switch (status) {
            case FoldStatusNone:      visibles = @[ TL, TR, BL, BR ]; invisibles = @[]; break;
            case FoldStatusRight:     visibles = @[ TL, BL ]; invisibles = @[ TR, BR ]; break;
            case FoldStatusRightUp:   visibles = @[ BR ]; invisibles = @[ TL, TR, BL ]; break;
            case FoldStatusRightDown: visibles = @[ TR ]; invisibles = @[ TL, BL, BR ]; break;
            case FoldStatusLeft:      visibles = @[ TR, BR ]; invisibles = @[ TL, BL ]; break;
            case FoldStatusLeftUp:    visibles = @[ BL ]; invisibles = @[ TL, TR, BR ]; break;
            case FoldStatusLeftDown:  visibles = @[ TL ]; invisibles = @[ TR, BL, BR ]; break;
            case FoldStatusUp:        visibles = @[ BL, BR ]; invisibles = @[ TL, TR ]; break;
            case FoldStatusUpRight:   visibles = @[ TL ]; invisibles = @[ TR, BL, BR ]; break;
            case FoldStatusUpLeft:    visibles = @[ TR ]; invisibles = @[ TL, BL, BR ]; break;
            case FoldStatusDown:      visibles = @[ TL, TR ]; invisibles = @[ BL, BR ]; break;
            case FoldStatusDownRight: visibles = @[ BL ]; invisibles = @[ TL, TR, BR ]; break;
            case FoldStatusDownLeft:  visibles = @[ BR ]; invisibles = @[ TL, TR, BL ]; break;
                
            default:
                NSLog(@"can't happen");
                abort();
        }
    }

    for (CALayer *layer in visibles) {
        layer.hidden = NO;
    }
    for (CALayer *layer in invisibles) {
        layer.hidden = YES;
    }
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    //[self setLayersVisibility:self.status];
}

- (void)rotateLayers:(NSArray *)layers r:(CGFloat)r ax:(CGFloat)ax ay:(CGFloat)ay az:(CGFloat)az
{
    [CATransaction setAnimationDuration:self.animationDuration];
    for (CALayer *layer in layers) {
        layer.transform = CATransform3DRotate(layer.transform, 0.999*r, ax, ay, az);
    }
    [CATransaction commit];
}

- (void)rotateLayers:(NSArray*)layers r:(CGFloat)r ax:(CGFloat)ax ay:(CGFloat)ay az:(CGFloat)az
           halfPointBlock:(void(^)(void))halfPointBlock
{
    CFTimeInterval dur = self.animationDuration;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5*dur];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setCompletionBlock:^{
        if (halfPointBlock) {
            halfPointBlock();
        }
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.5*dur];
//        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        for (CALayer *layer in layers) {
            layer.transform = CATransform3DRotate(layer.transform, 0.5*r, ax, ay, az);
        }
        [CATransaction commit];
    }];
    for (CALayer *layer in layers) {
        layer.transform = CATransform3DRotate(layer.transform, 0.5*r, ax, ay, az);
    }
    [CATransaction commit];
}

- (void)rotateRightLayers:(CGFloat)r status:(FoldStatus)status
{
    [self rotateLayers:@[self.topRightLayer, self.bottomRightLayer] r:r ax:0.0 ay:1.0 az:0.0
        halfPointBlock:^{
            [self setLayersVisibility:status];
        }];
}

- (void)rotateLeftLayers:(CGFloat)r status:(FoldStatus)status
{
    [self rotateLayers:@[self.topLeftLayer, self.bottomLeftLayer] r:r ax:0.0 ay:1.0 az:0.0
        halfPointBlock:^{
            [self setLayersVisibility:status];
        }];
}

- (void)rotateTopLayers:(CGFloat)r status:(FoldStatus)status
{
    [self rotateLayers:@[self.topRightLayer, self.topLeftLayer] r:r ax:1.0 ay:0.0 az:0.0
        halfPointBlock:^{
            [self setLayersVisibility:status];
        }];
}

- (void)rotateBottomLayers:(CGFloat)r status:(FoldStatus)status
{
    [self rotateLayers:@[self.bottomRightLayer, self.bottomLeftLayer] r:r ax:1.0 ay:0.0 az:0.0
        halfPointBlock:^{
            [self setLayersVisibility:status];
        }];
}

- (void)setStatus:(FoldStatus)status
{
    BOOL invalid = NO;
    
    if (self.status == status) {
        return;
    }
    
    if (self.status == FoldStatusNone) {
        switch (status) {
            case FoldStatusRight: // 右に畳む
                [self rotateLeftLayers:M_PI status:status];
                break;
            case FoldStatusLeft: // 左に畳む
                [self rotateRightLayers:-M_PI status:status];
                break;
            case FoldStatusUp: // 上に畳む
                [self rotateBottomLayers:M_PI status:status];
                break;
            case FoldStatusDown: // 下に畳む
                [self rotateTopLayers:-M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRight) {
        switch (status) {
            case FoldStatusNone: // 左に開く
                [self rotateLeftLayers:-M_PI status:status];
                break;
            case FoldStatusRightUp: // 上に畳む
                [self rotateBottomLayers:-M_PI status:status];
                break;
            case FoldStatusRightDown: // 下に畳む
                [self rotateTopLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightUp) {
        switch (status) {
            case FoldStatusRight: // 下に開く
                [self rotateBottomLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightDown) {
        switch (status) {
            case FoldStatusRight: // 上に開く
                [self rotateTopLayers:-M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeft) {
        switch (status) {
            case FoldStatusNone: // 右に開く
                [self rotateRightLayers:M_PI status:status];
                break;
            case FoldStatusLeftUp: // 上に畳む
                [self rotateBottomLayers:-M_PI status:status];
                break;
            case FoldStatusLeftDown: // 下に畳む
                [self rotateTopLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftUp) {
        switch (status) {
            case FoldStatusLeft: // 下に開く
                [self rotateBottomLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftDown) {
        switch (status) {
            case FoldStatusLeft: // 上に開く
                [self rotateTopLayers:-M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUp) {
        switch (status) {
            case FoldStatusNone: // 下に開く
                [self rotateBottomLayers:-M_PI status:status];
                break;
            case FoldStatusUpRight: // 右へ畳む
                [self rotateLeftLayers:-M_PI status:status];
                break;
            case FoldStatusUpLeft: // 左へ畳む
                [self rotateRightLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpRight) {
        switch (status) {
            case FoldStatusUp: // 左に開く
                [self rotateLeftLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpLeft) {
        switch (status) {
            case FoldStatusUp: // 右に開く
                [self rotateRightLayers:-M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDown) {
        switch (status) {
            case FoldStatusNone: // 上に開く
                [self rotateTopLayers:M_PI status:status];
                break;
            case FoldStatusDownRight: // 右に畳む
                [self rotateLeftLayers:-M_PI status:status];
                break;
            case FoldStatusDownLeft: // 左に畳む
                [self rotateRightLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownRight) {
        switch (status) {
            case FoldStatusDown: // 左に開く
                [self rotateLeftLayers:M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownLeft) {
        switch (status) {
            case FoldStatusDown: // 右に開く
                [self rotateRightLayers:-M_PI status:status];
                break;
            default: invalid = YES;
        }
    } else {
        NSLog(@"can't happen");
        abort();
    }
    
    if (invalid) {
        NSLog(@"warning: invalid status %d", status);
    } else {
        _status = status;
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
