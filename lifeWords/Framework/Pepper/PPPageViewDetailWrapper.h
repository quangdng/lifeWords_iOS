//
//  PPPageViewDetail.h
//
//  Created by Thiên Phong on 2/6/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPPageViewDetailWrapper;

@protocol PPPageViewDetailDelegate
@optional
- (void)scrollViewDidZoom:(UIScrollView *)theScrollView;
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale;
- (void)PPPageViewDetailWrapper:(PPPageViewDetailWrapper*)thePage viewDidTap:(int)tag;
- (void)PPPageViewDetailWrapper:(PPPageViewDetailWrapper*)thePage viewDidDoubleTap:(int)tag;
@end

@interface PPPageViewDetailWrapper : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) id customDelegate;
@property (nonatomic, strong) UIView *contentView;

- (void)setBackgroundImage:(UIImage*)image;
- (void)unloadContent;
- (void)reset:(BOOL)animated;
- (void)resetWithoutOffset:(BOOL)animated;
- (void)layoutWithFrame:(CGRect)frame duration:(float)duration;
- (void)setEnableScrollingZooming:(BOOL)enable;

@end
