//
//  QuadImageView.h
//  QuadImages
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuadImageView : UIImageView
@property (strong, nonatomic, readonly) CALayer *topLeftLayer;
@property (strong, nonatomic, readonly) CALayer *topRightLayer;
@property (strong, nonatomic, readonly) CALayer *bottomLeftLayer;
@property (strong, nonatomic, readonly) CALayer *bottomRightLayer;

@property (nonatomic) BOOL useGeometryFlipping;
@property (nonatomic) CGFloat alpha;

@end
