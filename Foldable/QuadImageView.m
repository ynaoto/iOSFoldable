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
    
    CATransformLayer *transformLayer;
    CALayer *layer;
    
    transformLayer = [CATransformLayer layer];
    transformLayer.frame = CGRectMake(0, 0, 2*w, 2*h);
    
    layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, w, h);
//    layer.anchorPoint = CGPointMake(1.0, 1.0);
//    layer.position = CGPointMake(w, h);
//    layer.contentsGravity = kCAGravityBottomLeft;
    layer.contentsGravity = kCAGravityTopLeft;
    layer.anchorPoint = CGPointMake(1.0, 1.0);
    layer.position = CGPointMake(w, h);
    layer.masksToBounds = YES;
    _topLeftLayer = layer;
    [transformLayer addSublayer:layer];
    
    layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, w, h);
    layer.anchorPoint = CGPointMake(0.0, 1.0);
    layer.position = CGPointMake(w, h);
    layer.contentsGravity = kCAGravityBottomRight;
    layer.masksToBounds = YES;
    _topRightLayer = layer;
    [transformLayer addSublayer:layer];
    
    layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, w, h);
    layer.anchorPoint = CGPointMake(1.0, 0.0);
    layer.position = CGPointMake(w, h);
    layer.contentsGravity = kCAGravityTopLeft;
    layer.masksToBounds = YES;
    _bottomLeftLayer = layer;
    [transformLayer addSublayer:layer];
    
    layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, w, h);
    layer.anchorPoint = CGPointMake(0.0, 0.0);
    layer.position = CGPointMake(w, h);
    layer.contentsGravity = kCAGravityTopRight;
    layer.masksToBounds = YES;
    _bottomRightLayer = layer;
    [transformLayer addSublayer:layer];

    [self.layer addSublayer:transformLayer];
    
    CATransform3D transform = transformLayer.sublayerTransform;
    transform.m34 = -1.0/500;
    transformLayer.sublayerTransform = transform;
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
