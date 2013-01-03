//
//  MyPageBaseView.h
//
//  Created by JustaLiar on 26/4/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPageBaseView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

- (void)fetchImageWithUrl:(NSString *)stringUrl;

@end
