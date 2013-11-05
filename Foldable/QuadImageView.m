//
//  QuadImageView.m
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

@implementation QuadImageView

- (void)setupQuadImageViews
{
    CGRect bounds = self.bounds;
    CGFloat w = bounds.size.width / 2;
    CGFloat h = bounds.size.height / 2;

    _topLeftImageView     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    _topRightImageView    = [[UIImageView alloc] initWithFrame:CGRectMake(w, 0, w, h)];
    _bottomLeftImageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, h, w, h)];
    _bottomRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(w, h, w, h)];

    [self addSubview:self.topLeftImageView];
    [self addSubview:self.topRightImageView];
    [self addSubview:self.bottomLeftImageView];
    [self addSubview:self.bottomRightImageView];
}

- (void)setupQuadImages
{
    // 変形済みイメージを取得する
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *srcImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *view;
    
    view = self.topLeftImageView;
    view.contentMode = UIViewContentModeTopLeft;
    view.clipsToBounds = YES;
    view.image = srcImage;
    
    view = self.topRightImageView;
    view.contentMode = UIViewContentModeTopRight;
    view.clipsToBounds = YES;
    view.image = srcImage;
    
    view = self.bottomLeftImageView;
    view.contentMode = UIViewContentModeBottomLeft;
    view.clipsToBounds = YES;
    view.image = srcImage;
    
    view = self.bottomRightImageView;
    view.contentMode = UIViewContentModeBottomRight;
    view.clipsToBounds = YES;
    view.image = srcImage;

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
        [self setupQuadImageViews];
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
