//
//  CATransaction+Sequence.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/25.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "CATransaction+Sequence.h"

@implementation CATransaction (Sequence)

+ (void)animationSequence:(NSArray*)sequence completed:(void(^)(void))completed
{
    if (sequence.count < 1) {
        if (completed != nil) {
            completed();
        }
        return;
    }
    
    void (^theAction)(void) =  (void(^)(void))sequence[0];
    NSRange range;
    range.location = 1;
    range.length = sequence.count - 1;
    NSArray *theRests = [sequence subarrayWithRange:range];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self animationSequence:theRests completed:completed];
    }];
    theAction();
    [CATransaction commit];
}

@end
