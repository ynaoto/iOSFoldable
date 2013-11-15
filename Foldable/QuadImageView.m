//
//  QuadImageView.m
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

@implementation QuadImageView

- (void)setupGravity
{
    _topLeftLayer.geometryFlipped     = self.useGeometryFlipping;
    _topRightLayer.geometryFlipped    = self.useGeometryFlipping;
    _bottomLeftLayer.geometryFlipped  = self.useGeometryFlipping;
    _bottomRightLayer.geometryFlipped = self.useGeometryFlipping;

    if (self.useGeometryFlipping) {
        _topLeftLayer.contentsGravity     = kCAGravityTopLeft;
        _topRightLayer.contentsGravity    = kCAGravityTopRight;
        _bottomLeftLayer.contentsGravity  = kCAGravityBottomLeft;
        _bottomRightLayer.contentsGravity = kCAGravityBottomRight;
    } else {
        _topLeftLayer.contentsGravity     = kCAGravityBottomLeft;
        _topRightLayer.contentsGravity    = kCAGravityBottomRight;
        _bottomLeftLayer.contentsGravity  = kCAGravityTopLeft;
        _bottomRightLayer.contentsGravity = kCAGravityTopRight;
    }
}

- (void)setUseGeometryFlipping:(BOOL)useGeometryFlipping
{
    _useGeometryFlipping = useGeometryFlipping;
    [self setupGravity];
}

- (CALayer*)makeQuaterWithSize:(CGSize)size anchorPoint:(CGPoint)anchorPoint
{
    CALayer *layer = [CALayer layer];
    layer.masksToBounds = YES;
    layer.anchorPoint = anchorPoint;
    layer.frame = CGRectMake((1.0 - anchorPoint.x) * size.width,
                             (1.0 - anchorPoint.y) * size.height,
                             size.width, size.height);
    return layer;
}

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

    CGSize size = CGSizeMake(w, h);
    _topLeftLayer     = [self makeQuaterWithSize:size anchorPoint:CGPointMake(1.0, 1.0)];
    _topRightLayer    = [self makeQuaterWithSize:size anchorPoint:CGPointMake(0.0, 1.0)];
    _bottomLeftLayer  = [self makeQuaterWithSize:size anchorPoint:CGPointMake(1.0, 0.0)];
    _bottomRightLayer = [self makeQuaterWithSize:size anchorPoint:CGPointMake(0.0, 0.0)];
    [self setupGravity];
    
    [transformLayer addSublayer:_topLeftLayer];
    [transformLayer addSublayer:_topRightLayer];
    [transformLayer addSublayer:_bottomLeftLayer];
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