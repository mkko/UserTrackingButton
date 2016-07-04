//
//  UIView+UIView_NoAnimation.m
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-07-03.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

#import "UIView+UIView_NoAnimation.h"

@implementation UIView (NoAnimation)

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion
{
    if (animations)
    {
        animations();
    }
    if (completion)
    {
        completion(YES);
    }
}

@end
