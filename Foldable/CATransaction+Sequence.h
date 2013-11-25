//
//  CATransaction+Sequence.h
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/25.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CATransaction (Sequence)

+ (void)animationSequence:(NSArray*)sequence completed:(void(^)(void))completed;

@end
