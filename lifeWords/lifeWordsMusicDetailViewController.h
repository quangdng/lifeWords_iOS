//
//  lifeWordsMusicDetailViewController.h
//  lifeWords
//
//  Created by Thiên Phong on 8/11/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol lifeWordsMusicDetailViewControllerDelegate;
@interface lifeWordsMusicDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *musicArray;
}
@property (nonatomic, strong) NSString *category;
@end
