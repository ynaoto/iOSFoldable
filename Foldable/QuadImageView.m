//
//  QuadImageView.m
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

@implementation QuadImageView

- (void)setupQuadLayers
{
    CGRect bounds = self.bounds;
    CGFloat w = bounds.size.width / 2;
    CGFloat h = bounds.size.height / 2;
    
    CATransformLayer *transformLayer = [CATransformLayer layer];
    CATransform3D transform = transformLayer.sublayerTransform;
    transform.m34 = -1.0/500;
    transformLayer.sublayerTransform = transform;
    transformLayer.frame = self.layer.bounds;
    [self.layer addSublayer:transformLayer];
    
    _topLeftLayer = [CALayer layer];
    _topLeftLayer.contentsGravity = kCAGravityTopLeft;
    _topLeftLayer.contentsRect = CGRectMake(0.0, 0.0, 0.5, 0.5);
    _topLeftLayer.anchorPoint = CGPointMake(1.0, 1.0);
    _topLeftLayer.frame = CGRectMake(0, 0, w, h);
    _topLeftLayer.masksToBounds = YES;
    [transformLayer addSublayer:_topLeftLayer];

    _topRightLayer = [CALayer layer];
    _topRightLayer.contentsGravity = kCAGravityTopRight;
    _topRightLayer.contentsRect = CGRectMake(0.5, 0, 0.5, 0.5);
    _topRightLayer.anchorPoint = CGPointMake(0.0, 1.0);
    _topRightLayer.frame = CGRectMake(w, 0, w, h);
    _topRightLayer.masksToBounds = YES;
    [transformLayer addSublayer:_topRightLayer];

    _bottomLeftLayer = [CALayer layer];
    _bottomLeftLayer.contentsGravity = kCAGravityBottomLeft;
    _bottomLeftLayer.contentsRect = CGRectMake(0.0, 0.5, 0.5, 0.5);
    _bottomLeftLayer.anchorPoint = CGPointMake(1.0, 0.0);
    _bottomLeftLayer.frame = CGRectMake(0, h, w, h);
    _bottomLeftLayer.masksToBounds = YES;
    [transformLayer addSublayer:_bottomLeftLayer];

    _bottomRightLayer = [CALayer layer];
    _bottomRightLayer.contentsGravity = kCAGravityBottomRight;
    _bottomRightLayer.contentsRect = CGRectMake(0.5, 0.5, 0.5, 0.5);
    _bottomRightLayer.anchorPoint = CGPointMake(0.0, 0.0);
    _bottomRightLayer.frame = CGRectMake(w, h, w, h);
    _bottomRightLayer.masksToBounds = YES;
    [transformLayer addSublayer:_bottomRightLayer];
}

- (void)setupQuadImages
{
    // 変形済みイメージを取得する
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *srcImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    id imageRefContents = (id)srcImage.CGImage;
    self.topLeftLayer.contents = imageRefContents;
    self.topRightLayer.contents = imageRefContents;
    self.bottomLeftLayer.contents = imageRefContents;
    self.bottomRightLayer.contents = imageRefContents;

    self.image = nil;
    
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image
{
    NSLog(@"%s: %@", __FUNCTION__, image);
    [super setImage:image];
    if (image) {
        [self setupQuadImages];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupQuadLayers];
        [self setImage:self.image]; // initWithCoder では setImage: の呼び出しが行われないので、強制的に呼び出す。
    }
    return self;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
}

- (id)initWithImage:(UIImage *)image
{
    NSLog(@"%s", __FUNCTION__);
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    NSLog(@"%s", __FUNCTION__);
}
*/

/*
- (id)initWithImage:(UIImage *)image
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        [self makeQuadImageViews];
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
