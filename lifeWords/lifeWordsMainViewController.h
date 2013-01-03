//
//  lifeWordsMainViewController.h
//  lifeWords
//
//  Created by Thiên Phong on 21/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "lifeWordsAppDelegate.h"
#import "JSBadgeView.h"
#import "OLGhostAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "ODRefreshControl.h"
#import "SWSnapshotStackView.h"

@interface lifeWordsMainViewController : UIViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate> {
    NSString *userEmail;
    NSString *color;
    NSArray *cards;
    
    // Matters of Download
    NSArray *receivedCards;
    NSString *currentCardPath;
    NSArray *temporaryCards;
    NSArray *newCards;
    NSArray *previewCard;
    
    BOOL received;
}

#pragma mark - Photo
@property (nonatomic, retain) UIPopoverController *popover;
@property (strong, nonatomic) IBOutlet UIButton *makeCardButton;
- (IBAction) showActionSheet:(id)sender;
- (IBAction)test:(id)sender;

#pragma mark - Core Elements
@property (strong, nonatomic) NSUserDefaults *coreDatabase;
@property (strong, nonatomic) IBOutlet SWSnapshotStackView *profilePhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) JUSSNetworkOperation *downloadOperation;
@property (strong, nonatomic) JUSSNetworkOperation *fetchUserInfo;
@property (strong, nonatomic) JUSSNetworkOperation *fetchCards;
@property (strong, nonatomic) IBOutlet UIScrollView *yourCards;
@property (strong, nonatomic) IBOutlet UIScrollView *receivedCard;

#pragma mark - Toolbars
@property (strong, nonatomic) IBOutlet UIToolbar *myToolBar;

#pragma mark - Decoration
@property (strong, nonatomic) IBOutlet UIImageView *wallpaper;
@property (strong, nonatomic) IBOutlet UIImageView *container;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *configBtn;

#pragma mark - Actions
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)configBtnClicked:(id)sender;
- (IBAction)collectionBtnClicked:(id)sender;
@end
