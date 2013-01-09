//
//  MyImageCache.h
//
//  Created by Thiên Phong on 14/6/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//
//
//

#import <UIKit/UIKit.h>

@interface MyImageCache : NSObject

+ (MyImageCache*)sharedCached;

- (UIImage*)imageForKey:(NSString*)key;
- (void)addImage:(UIImage*)image ForKey:(NSString*)key;
- (void)removeImageForKey:(NSString*)key;
- (void)removeAll;

@end
