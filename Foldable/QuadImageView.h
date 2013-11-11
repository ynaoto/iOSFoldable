//
//  QuadImageView.h
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuadImageView : UIImageView
@property (readonly, nonatomic) CALayer *topLeftLayer;
@property (readonly, nonatomic) CALayer *topRightLayer;
@property (readonly, nonatomic) CALayer *bottomLeftLayer;
@property (readonly, nonatomic) CALayer *bottomRightLayer;

@end
