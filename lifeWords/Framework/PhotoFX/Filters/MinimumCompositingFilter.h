//
//  MinimumCompositingFilter.h
//  lifeWords
//
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

@interface MinimumCompositingFilter : Filter

+ (MinimumCompositingFilter *)filterWithInputBackgroundImage:(CIImage *)inputBackgroundImage;

@end
