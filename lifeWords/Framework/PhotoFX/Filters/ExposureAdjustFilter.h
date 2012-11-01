//
//  ExposureAdjustFilter.h
//  lifeWords
//
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

@interface ExposureAdjustFilter : Filter

+ (ExposureAdjustFilter *) filterWithInputEV:(CGFloat)inputEV;

@end
