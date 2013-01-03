//
//  NSString+JUSSNetworkKitAdditions.h
//  JUSSNetworkKitDemo
//
//  Created by Thiên Phong on 08/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

@interface NSString (JUSSNetworkKitAdditions)

- (NSString *) md5;
+ (NSString*) uniqueString;
- (NSString*) urlEncodedString;
- (NSString*) urlDecodedString;
@end
