//
//  FoldableQuadImageView.h
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/05.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "QuadImageView.h"

typedef NS_ENUM(int, FoldStatus) {
    FoldStatusNone = 0,
    FoldStatusRight, FoldStatusRightUp, FoldStatusRightDown,
    FoldStatusLeft, FoldStatusLeftUp, FoldStatusLeftDown,
    FoldStatusUp, FoldStatusUpRight, FoldStatusUpLeft,
    FoldStatusDown, FoldStatusDownRight, FoldStatusDownLeft,
};

@interface FoldableQuadImageView : QuadImageView
@property (nonatomic) FoldStatus status;
@property (nonatomic) CFTimeInterval animationDuration;

@end
