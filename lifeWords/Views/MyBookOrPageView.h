//
//  MyBookOrPageView.h
//
//  Created by Thiên Phong on 26/4/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPageBaseView.h"
#import "Page.h"
#import "Book.h"

@interface MyBookOrPageView : MyPageBaseView

- (void)configureWithPageModel:(Page*)pageModel;
- (void)configureWithBookModel:(Book*)bookModel;
- (void)refresh;

@end
