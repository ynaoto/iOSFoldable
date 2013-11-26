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
    NSAssert(0 < sequence.count, nil);
    
    void (^theAction)(void) =  (void(^)(void))sequence[0];
    NSRange range;
    range.location = 1;
    range.length = sequence.count - 1;
    NSArray *theRests = [sequence subarrayWithRange:range];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (0 < theRests.count) {
            [self animationSequence:theRests completed:completed];
        } else {
            if (completed != nil) {
                completed();
            }
        }
    }];
    theAction();
    [CATransaction commit];
}

@end
