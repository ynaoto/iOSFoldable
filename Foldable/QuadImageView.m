//
//  QuadImageView.m
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

@implementation QuadImageView

- (UIImageView*)setupQuaterImageView:(CGRect)frame srcImageRef:(CGImageRef)srcImageRef
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.contentMode = UIViewContentModeTopLeft; // イメージの拡縮を行わない
    //view.clipsToBounds = YES; // フレームをはみ出したところは切り取る(今回はフレームに合わせてイメージを切り取るので不要)
    CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, frame); // 元イメージから切り取る
    view.image = [UIImage imageWithCGImage:trimmedImageRef];
    return view;
}

- (void)setupQuadImageViews
{
    CGRect bounds = self.bounds;
    CGFloat w = bounds.size.width / 2;
    CGFloat h = bounds.size.height / 2;

    // 変形済みイメージを取得する
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *srcImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef srcImageRef = [srcImage CGImage];

    _topLeftImageView     = [self setupQuaterImageView:CGRectMake(0, 0, w, h) srcImageRef:srcImageRef];
    _topRightImageView    = [self setupQuaterImageView:CGRectMake(w, 0, w, h) srcImageRef:srcImageRef];
    _bottomLeftImageView  = [self setupQuaterImageView:CGRectMake(0, h, w, h) srcImageRef:srcImageRef];
    _bottomRightImageView = [self setupQuaterImageView:CGRectMake(w, h, w, h) srcImageRef:srcImageRef];

    [self addSubview:self.topLeftImageView];
    [self addSubview:self.topRightImageView];
    [self addSubview:self.bottomLeftImageView];
    [self addSubview:self.bottomRightImageView];

    self.image = nil;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self makeQuadImageViews];
    }
    return self;
}
 */

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setupQuadImageViews];
    }
    return self;
}

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
