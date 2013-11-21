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

- (void)rotateLayers:(NSArray *)layers r:(CGFloat)r ax:(CGFloat)ax ay:(CGFloat)ay az:(CGFloat)az
{
    [CATransaction setAnimationDuration:self.animationDuration];
    for (CALayer *layer in layers) {
        layer.transform = CATransform3DRotate(layer.transform, 0.999*r, ax, ay, az);
    }
    [CATransaction commit];
}

- (void)rotateRightLayers:(CGFloat)r
{
    [self rotateLayers:@[self.topRightLayer, self.bottomRightLayer] r:r ax:0.0 ay:1.0 az:0.0];
}

- (void)rotateLeftLayers:(CGFloat)r
{
    [self rotateLayers:@[self.topLeftLayer, self.bottomLeftLayer] r:r ax:0.0 ay:1.0 az:0.0];
}

- (void)rotateTopLayers:(CGFloat)r
{
    [self rotateLayers:@[self.topRightLayer, self.topLeftLayer] r:r ax:1.0 ay:0.0 az:0.0];
}

- (void)rotateBottomLayers:(CGFloat)r
{
    [self rotateLayers:@[self.bottomRightLayer, self.bottomLeftLayer] r:r ax:1.0 ay:0.0 az:0.0];
}

- (void)setStatus:(FoldStatus)status
{
    BOOL invalid = NO;
    
    if (self.status == status) {
        return;
    }
    
    if (self.status == FoldStatusNone) {
        switch (status) {
            case FoldStatusRight: [self rotateLeftLayers:M_PI];   break; // 右に畳む
            case FoldStatusLeft:  [self rotateRightLayers:-M_PI]; break; // 左に畳む
            case FoldStatusUp:    [self rotateBottomLayers:M_PI]; break; // 上に畳む
            case FoldStatusDown:  [self rotateTopLayers:-M_PI];   break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRight) {
        switch (status) {
            case FoldStatusNone:      [self rotateLeftLayers:-M_PI];   break; // 左に開く
            case FoldStatusRightUp:   [self rotateBottomLayers:-M_PI]; break; // 上に畳む
            case FoldStatusRightDown: [self rotateTopLayers:M_PI];     break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightUp) {
        switch (status) {
            case FoldStatusRight: [self rotateBottomLayers:M_PI]; break; // 下に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusRightDown) {
        switch (status) {
            case FoldStatusRight: [self rotateTopLayers:-M_PI]; break; // 上に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeft) {
        switch (status) {
            case FoldStatusNone:     [self rotateRightLayers:M_PI];   break; // 右に開く
            case FoldStatusLeftUp:   [self rotateBottomLayers:-M_PI]; break; // 上に畳む
            case FoldStatusLeftDown: [self rotateTopLayers:M_PI];     break; // 下に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftUp) {
        switch (status) {
            case FoldStatusLeft: [self rotateBottomLayers:M_PI]; break; // 下に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusLeftDown) {
        switch (status) {
            case FoldStatusLeft: [self rotateTopLayers:-M_PI]; break; // 上に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUp) {
        switch (status) {
            case FoldStatusNone:    [self rotateBottomLayers:-M_PI]; break; // 下に開く
            case FoldStatusUpRight: [self rotateLeftLayers:-M_PI];   break; // 右へ畳む
            case FoldStatusUpLeft:  [self rotateRightLayers:M_PI];   break; // 左へ畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpRight) {
        switch (status) {
            case FoldStatusUp: [self rotateLeftLayers:M_PI]; break; // 左に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusUpLeft) {
        switch (status) {
            case FoldStatusUp: [self rotateRightLayers:-M_PI]; break; // 右に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDown) {
        switch (status) {
            case FoldStatusNone:      [self rotateTopLayers:M_PI];   break; // 上に開く
            case FoldStatusDownRight: [self rotateLeftLayers:-M_PI]; break; // 右に畳む
            case FoldStatusDownLeft:  [self rotateRightLayers:M_PI]; break; // 左に畳む
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownRight) {
        switch (status) {
            case FoldStatusDown: [self rotateLeftLayers:M_PI]; break; // 左に開く
            default: invalid = YES;
        }
    } else if (self.status == FoldStatusDownLeft) {
        switch (status) {
            case FoldStatusDown: [self rotateRightLayers:-M_PI]; break; // 右に開く
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
