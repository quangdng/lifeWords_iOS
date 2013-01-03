//
//  UIAlertView+JUSSNetworkKitAdditions.h
//  JUSSNetworkKitDemo
//
//  Created by Thiên Phong on 08/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIAlertView (JUSSNetworkKitAdditions)
+(UIAlertView*) showWithError:(NSError*) networkError;
@end
#endif