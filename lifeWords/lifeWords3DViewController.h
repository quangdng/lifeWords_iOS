//
//  lifeWords3DViewController.h
//  lifeWords
//
//  Created by Thiên Phong on 1/3/13.
//  Copyright (c) 2013 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPepperViewController.h"

@interface lifeWords3DViewController : UIViewController <PPScrollListViewControllerDataSource, PPScrollListViewControllerDelegate> {
    
    int numberOfBooks;
    
    NSMutableArray *familyArray;
    NSMutableArray *friendsArray;
    NSMutableArray *loveArray;
    NSMutableArray *bookArray;
}

@property (nonatomic, strong) PPPepperViewController * pepperViewController;
@property (nonatomic, assign) BOOL iOS5AndAbove;
@property (nonatomic, strong) NSMutableArray *bookDataArray;
@property (strong, nonatomic) IBOutlet UIView *operationBar;
@property (strong, nonatomic) IBOutlet UILabel *bookName;
@property (strong, nonatomic) IBOutlet UIImageView *wallpaper;
@property (strong, nonatomic) NSArray *cards;
- (IBAction)dismissView:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@end
