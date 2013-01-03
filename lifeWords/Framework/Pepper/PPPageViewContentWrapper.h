//
//  PPPageView.h
//  pepper
//
//  Created by Thiên Phong on 26/4/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPPageViewContentWrapper;

@protocol PPPageViewWrapperDelegate <NSObject>
@optional
- (void)PPPageViewWrapper:(PPPageViewContentWrapper*)thePage viewDidTap:(int)tag;
@end

@interface PPPageViewContentWrapper : UIView

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL isLeft;
@property (nonatomic, assign) BOOL isBook;

@property (nonatomic, assign) float shadowRadius;
@property (nonatomic, assign) float shadowOpacity;
@property (nonatomic, assign) CGSize shadowOffset;

- (void)setBackgroundImage:(UIImage*)image;
- (void)unloadContent;
- (void)removeShadow;
- (void)updateShadow;

@end
