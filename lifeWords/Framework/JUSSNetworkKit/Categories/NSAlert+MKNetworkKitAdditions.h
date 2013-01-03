//
//  NSAlert+JUSSNetworkKitAdditions.h
//  JUSSNetworkKitDemo
//
//  Created by Thiên Phong on 08/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>

@interface NSAlert (JUSSNetworkKitAdditions)
+(NSAlert*) showWithError:(NSError*) networkError;
@end
#endif