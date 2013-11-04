//
//  QuadImageView.h
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuadImageView : UIImageView
@property (readonly, nonatomic) UIImageView *topLeftImageView;
@property (readonly, nonatomic) UIImageView *topRightImageView;
@property (readonly, nonatomic) UIImageView *bottomLeftImageView;
@property (readonly, nonatomic) UIImageView *bottomRightImageView;

@end
