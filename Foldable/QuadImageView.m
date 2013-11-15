//
//  QuadImageView.m
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

@implementation QuadImageView

static CALayer *makeQuater(CGFloat w, CGFloat h, CGFloat ax, CGFloat ay, NSString *gravity)
{
    CALayer *layer = [CALayer layer];
//    layer.geometryFlipped = YES; // gravity 定数名との整合性を取るため
    layer.contentsGravity = gravity;
    layer.masksToBounds = YES;
    layer.anchorPoint = CGPointMake(ax, ay);
    layer.frame = CGRectMake((1.0 - ax) * w, (1.0 - ay) * h, w, h);
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
//    transformLayer.geometryFlipped = YES; ///////
    [self.layer addSublayer:transformLayer];

//    _topLeftLayer     = makeQuater(w, h, 1.0, 1.0, kCAGravityTopLeft);
//    _topRightLayer    = makeQuater(w, h, 0.0, 1.0, kCAGravityTopRight);
//    _bottomLeftLayer  = makeQuater(w, h, 1.0, 0.0, kCAGravityBottomLeft);
//    _bottomRightLayer = makeQuater(w, h, 0.0, 0.0, kCAGravityBottomRight);
    _topLeftLayer     = makeQuater(w, h, 1.0, 1.0, kCAGravityBottomLeft);
    _topRightLayer    = makeQuater(w, h, 0.0, 1.0, kCAGravityBottomRight);
    _bottomLeftLayer  = makeQuater(w, h, 1.0, 0.0, kCAGravityTopLeft);
    _bottomRightLayer = makeQuater(w, h, 0.0, 0.0, kCAGravityTopRight);

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
    
    //[self setNeedsDisplay];
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
