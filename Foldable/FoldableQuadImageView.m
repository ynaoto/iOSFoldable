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
        layer.transform = CATransform3DRotate(layer.transform, 0.999*r, ax, ay, az);
    }
    [CATransaction commit];
}

typedef NS_ENUM(int, FoldStatus) {
    None = 0,
    Right, RightUp, RightDown,
    Left, LeftUp, LeftDown,
    Up, UpRight, UpLeft,
    Down, DownRight, DownLeft,
};

@interface FoldableQuadImageView () <UIGestureRecognizerDelegate>

@end

@implementation FoldableQuadImageView
{
    FoldStatus status;
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

- (void)rotateRightLayers:(CGFloat)r
{
    rotateLayers(@[self.topRightLayer, self.bottomRightLayer], r, 0.0, 1.0, 0.0);
}

- (void)rotateLeftLayers:(CGFloat)r
{
    rotateLayers(@[self.topLeftLayer, self.bottomLeftLayer], r, 0.0, 1.0, 0.0);
}

- (void)rotateTopLayers:(CGFloat)r
{
    rotateLayers(@[self.topRightLayer, self.topLeftLayer], r, 1.0, 0.0, 0.0);
}

- (void)rotateBottomLayers:(CGFloat)r
{
    rotateLayers(@[self.bottomRightLayer, self.bottomLeftLayer], r, 1.0, 0.0, 0.0);
}

- (void)tap:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: status = %d", __FUNCTION__, status);

    CGPoint p = [gestureRecognizer locationInView:self];
    
    // 少し乱数を使って、全てのパタンを出すようにする
    int n = arc4random();
    
    if (status == None) {
        // 左右に畳むか、上下に畳むか
        if (n % 2 == 0) { // 左右
            if ([self isLeft:p]) {
                [self rotateLeftLayers:M_PI]; // 右に畳む
                status = Right;
            } else {
                [self rotateRightLayers:-M_PI]; // 左に畳む
                status = Left;
            }
        } else { // 上下
            if ([self isBottom:p]) {
                [self rotateBottomLayers:M_PI]; // 上に畳む
                status = Up;
            } else {
                [self rotateTopLayers:-M_PI]; // 下に畳む
                status = Down;
            }
        }
    } else if (status == Right && [self isRight:p]) {
        // 左に開くか、上下に畳むか
        if (n % 2 == 0) { // 左に開く
            [self rotateLeftLayers:-M_PI]; // 左に開く
            status = None;
        } else { // 上下に畳む
            if ([self isBottom:p]) {
                [self rotateBottomLayers:-M_PI]; // 上に畳む
                status = RightUp;
            } else if ([self isTop:p]) {
                [self rotateTopLayers:M_PI]; // 下に畳む
                status = RightDown;
            }
        }
    } else if (status == RightUp && [self isRight:p] && [self isTop:p]) {
        [self rotateBottomLayers:M_PI]; // 下に開く
        status = Right;
    } else if (status == RightDown && [self isRight:p] && [self isBottom:p]) {
        [self rotateTopLayers:-M_PI]; // 上に開く
        status = Right;
    } else if (status == Left && [self isLeft:p]) {
        // 右に開くか、上下に畳むか
        if (n % 2 == 0) { // 右に開く
            [self rotateRightLayers:M_PI]; // 右に開く
            status = None;
        } else { // 上下に畳む
            if ([self isBottom:p]) {
                [self rotateBottomLayers:-M_PI]; // 上に畳む
                status = LeftUp;
            } else if ([self isTop:p]) {
                [self rotateTopLayers:M_PI]; // 下に畳む
                status = LeftDown;
            }
        }
    } else if (status == LeftUp && [self isLeft:p] && [self isTop:p]) {
        [self rotateBottomLayers:M_PI]; // 下に開く
        status = Left;
    } else if (status == LeftDown && [self isLeft:p] && [self isBottom:p]) {
        [self rotateTopLayers:-M_PI]; // 上に開く
        status = Left;
    } else if (status == Up && [self isTop:p]) {
        // 下に開くか、左右に畳むか
        if (n % 2 == 0) { // 下に開く
            [self rotateBottomLayers:-M_PI]; // 下に開く
            status = None;
        } else { // 左右に畳む
            if ([self isLeft:p]) {
                [self rotateLeftLayers:-M_PI]; // 右へ畳む
                status = UpRight;
            } else if ([self isRight:p]) {
                [self rotateRightLayers:M_PI]; // 左へ畳む
                status = UpLeft;
            }
        }
    } else if (status == UpRight && [self isRight:p] && [self isTop:p]) {
        [self rotateLeftLayers:M_PI]; // 左に開く
        status = Up;
    } else if (status == UpLeft && [self isLeft:p] && [self isTop:p]) {
        [self rotateRightLayers:-M_PI]; // 右に開く
        status = Up;
    } else if (status == Down && [self isBottom:p]) {
        // 上に開くか、左右に畳むか
        if (n % 2 == 0) { // 上に開く
            [self rotateTopLayers:M_PI]; // 上に開く
            status = None;
        } else { // 左右に畳む
            if ([self isLeft:p]) {
                [self rotateLeftLayers:-M_PI]; // 右に畳む
                status = DownRight;
            } else if ([self isRight:p]) {
                [self rotateRightLayers:M_PI]; // 左に畳む
                status = DownLeft;
            }
        }
    } else if (status == DownRight && [self isRight:p] && [self isBottom:p]) {
        [self rotateLeftLayers:M_PI]; // 左に開く
        status = Down;
    } else if (status == DownLeft && [self isLeft:p] && [self isBottom:p]) {
        [self rotateRightLayers:-M_PI]; // 右に開く
        status = Down;
    } else {
        NSLog(@"do nothing.");
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s: dir = %d, status = %d", __FUNCTION__, (int)gestureRecognizer.direction, status);
    
    CGPoint p = [gestureRecognizer locationInView:self];
    UISwipeGestureRecognizerDirection direction = gestureRecognizer.direction;

    if (status == None) {
        // 左右に畳むか、上下に畳むか
        if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateLeftLayers:M_PI]; // 右に畳む
            status = Right;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateRightLayers:-M_PI]; // 左に畳む
            status = Left;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateBottomLayers:M_PI]; // 上に畳む
            status = Up;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateTopLayers:-M_PI]; // 下に畳む
            status = Down;
        }
    } else if (status == Right && [self isRight:p]) {
        // 左に開くか、上下に畳むか
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateLeftLayers:-M_PI]; // 左に開く
            status = None;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateBottomLayers:-M_PI]; // 上に畳む
            status = RightUp;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateTopLayers:M_PI]; // 下に畳む
            status = RightDown;
        }
    } else if (status == RightUp && [self isRight:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateBottomLayers:M_PI]; // 下に開く
            status = Right;
        }
    } else if (status == RightDown && [self isRight:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateTopLayers:-M_PI]; // 上に開く
            status = Right;
        }
    } else if (status == Left && [self isLeft:p]) {
        // 右に開くか、上下に畳むか
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateRightLayers:M_PI]; // 右に開く
            status = None;
        } else if ([self isBottom:p] && direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateBottomLayers:-M_PI]; // 上に畳む
            status = LeftUp;
        } else if ([self isTop:p] && direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateTopLayers:M_PI]; // 下に畳む
            status = LeftDown;
        }
    } else if (status == LeftUp && [self isLeft:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateBottomLayers:M_PI]; // 下に開く
            status = Left;
        }
    } else if (status == LeftDown && [self isLeft:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateTopLayers:-M_PI]; // 上に開く
            status = Left;
        }
    } else if (status == Up && [self isTop:p]) {
        // 下に開くか、左右に畳むか
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            [self rotateBottomLayers:-M_PI]; // 下に開く
            status = None;
        } else if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateLeftLayers:-M_PI]; // 右へ畳む
            status = UpRight;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateRightLayers:M_PI]; // 左へ畳む
            status = UpLeft;
        }
    } else if (status == UpRight && [self isRight:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateLeftLayers:M_PI]; // 左に開く
            status = Up;
        }
    } else if (status == UpLeft && [self isLeft:p] && [self isTop:p]) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateRightLayers:-M_PI]; // 右に開く
            status = Up;
        }
    } else if (status == Down && [self isBottom:p]) {
        // 上に開くか、左右に畳むか
        if (direction == UISwipeGestureRecognizerDirectionUp) {
            [self rotateTopLayers:M_PI]; // 上に開く
            status = None;
        } else if ([self isLeft:p] && direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateLeftLayers:-M_PI]; // 右に畳む
            status = DownRight;
        } else if ([self isRight:p] && direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateRightLayers:M_PI]; // 左に畳む
            status = DownLeft;
        }
    } else if (status == DownRight && [self isRight:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            [self rotateLeftLayers:M_PI]; // 左に開く
            status = Down;
        }
    } else if (status == DownLeft && [self isLeft:p] && [self isBottom:p]) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            [self rotateRightLayers:-M_PI]; // 右に開く
            status = Down;
        }
    } else {
        NSLog(@"do nothing.");
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
