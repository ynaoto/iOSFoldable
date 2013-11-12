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
    
    //CATransformLayer
    CALayer *layer;
    
    layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, w, h);
    layer.contentsGravity = kCAGravityBottomLeft;
    layer.masksToBounds = YES;
    _topLeftLayer = layer;
    
    layer = [CALayer layer];
    layer.frame = CGRectMake(w, 0, w, h);
    layer.contentsGravity = kCAGravityBottomRight;
    layer.masksToBounds = YES;
    _topRightLayer = layer;
    
    layer = [CALayer layer];
    layer.frame = CGRectMake(0, h, w, h);
    layer.contentsGravity = kCAGravityTopLeft;
    layer.masksToBounds = YES;
    _bottomLeftLayer = layer;
    
    layer = [CALayer layer];
    layer.frame = CGRectMake(w, h, w, h);
    layer.contentsGravity = kCAGravityTopRight;
    layer.masksToBounds = YES;
    _bottomRightLayer = layer;

    [self.layer addSublayer:self.topLeftLayer];
    [self.layer addSublayer:self.topRightLayer];
    [self.layer addSublayer:self.bottomLeftLayer];
    [self.layer addSublayer:self.bottomRightLayer];
}

- (void)setupQuadImages
{
    // 変形済みイメージを取得する
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *srcImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.topLeftLayer.contents = (id)srcImage.CGImage;
    self.topRightLayer.contents = (id)srcImage.CGImage;
    self.bottomLeftLayer.contents = (id)srcImage.CGImage;
    self.bottomRightLayer.contents = (id)srcImage.CGImage;

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
