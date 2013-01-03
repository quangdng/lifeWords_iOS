//
//  lifeWordsMainViewController.m
//  lifeWords
//
//  Created by Thiên Phong on 21/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import "lifeWordsMainViewController.h"
#import "lifeWordsPhotoFilteringViewController.h"
#import "KSCustomPopoverBackgroundView.h"
#import "lifeWordsPreviewViewController.h"
#import "lifeWordsColorSelectViewController.h"
#import "lifeWords3DViewController.h"

@interface lifeWordsMainViewController () {
    NSDictionary *userInfo;
    UIImage *chosenPhoto;
    ODRefreshControl *refreshControl;
}
@end

@implementation lifeWordsMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

#pragma mark - UIViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Fetch data from NSUserDefaults
    self.coreDatabase = [NSUserDefaults standardUserDefaults];
    userEmail = [self.coreDatabase objectForKey:@"Current_User_Email"];
    color = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
    
    
    cards = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Cards", userEmail]];
    receivedCards = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];

    
    // Add UI refresh control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.scrollView];
    [refreshControl setTintColor:[UIColor colorWithRed:0.597058 green:0.815217 blue:0.107755 alpha:1]];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [refreshControl setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Fill up scroll views
    if ([cards count] > 0) {
        [self.yourCards setAlwaysBounceVertical:NO];
        [self.yourCards setPagingEnabled:YES];
        [self.yourCards setContentSize:CGSizeMake(574, 128)];
        [self fillScrollView:cards withScrollView:self.yourCards];
    }
    // Fill up scroll views
    if ([receivedCards count] >0) {
    [self.receivedCard setAlwaysBounceVertical:NO];
    [self.receivedCard setPagingEnabled:YES];
    [self.receivedCard setContentSize:CGSizeMake(574, 128)];
    [self fillSharedScrollView:receivedCards withScrollView:self.receivedCard];
    }
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // Hide Navigation Bar
    [self.navigationController.navigationBar setHidden:YES];
    
    // Set background image
    if ([color isEqualToString:@"blue_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Blue Sky.jpg"]];
    }
    else if ([color isEqualToString:@"green_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Green Leaf.jpg"]];
    }
    else if ([color isEqualToString:@"indigo_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Indigo Horizon.jpg"]];
    }
    else if ([color isEqualToString:@"orange_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Orange Sunset.jpg"]];
        
    }
    else if ([color isEqualToString:@"red_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Red Sunrise.jpg"]];
    }
    else if ([color isEqualToString:@"violet_"]) {
        [self.wallpaper setImage:[UIImage imageNamed:@"Violet Silk.jpg"]];
    }
    else {
        [self.wallpaper setImage:[UIImage imageNamed:@"Yellow Autumn.jpg"]];
    }
    
    
    // Set toolbar background
    UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", color]];
    [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    
    // Refresh Contents
    [self refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeSelect:) name:@"ColorSelected" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.coreDatabase synchronize];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setCoreDatabase:nil];
    [self setNameLabel:nil];
    [self setMakeCardButton:nil];
    [self setMyToolBar:nil];
    [self setWallpaper:nil];
    [self setContainer:nil];
    [self setFetchCards:nil];
    [self setYourCards:nil];
    [self setReceivedCard:nil];
    [self setConfigBtn:nil];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Image Picker for the profile photo

- (void)pickImage:(BOOL)camera
{
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (camera) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:picker animated:YES];
    }
    else {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
            [self presentModalViewController:picker animated:YES];
        }
        else {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.popover.delegate = self;
            self.popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
            [self.popover presentPopoverFromRect:self.makeCardButton.frame inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        }
    }
}

- (IBAction) showActionSheet:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *popupQuery = [[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Album", nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupQuery showInView:self.view];
    } else {
        [self pickImage:FALSE];
    }
}

- (IBAction)test:(id)sender {
    // Push View Controller
    lifeWordsPhotoFilteringViewController *nextView = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"photoFilteringView"];
    [nextView setPhoto:[UIImage imageNamed:@"dog.jpg"]];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:nextView animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                     }];
}


- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self pickImage:TRUE];
    } else if (buttonIndex == 1) {
        [self pickImage:FALSE];
    }
}

#pragma mark - UIPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    chosenPhoto = image;
    
    // Push View Controller
    lifeWordsPhotoFilteringViewController *nextView = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"photoFilteringView"];
    nextView.photo = chosenPhoto;
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:nextView animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                     }];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [picker dismissModalViewControllerAnimated:NO];
    } else {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
            [picker dismissModalViewControllerAnimated:NO];
        }
        else {
            [self.popover dismissPopoverAnimated:NO];
        }
    }
}


- (void) refresh
{
    // Set the photo
    NSString *profilePhotoURL = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_profilePhotoURL", userEmail]];
    NSString *profilePhotoPath = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_profilePhotoPath", userEmail]];
    NSString *profileBackupPhotoPath = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_profileBackupPhotoPath", userEmail]];
    
    [self.profilePhoto setImage:[UIImage imageWithContentsOfFile:profileBackupPhotoPath]];
    
    // Set User Nickname or Email
    if ([self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Nickname", userEmail]]) {
        [self.nameLabel setText:[self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Nickname", userEmail]]];
    }
    else {
        [self.nameLabel setText:userEmail];
    }
    
    // Fetch the lastest user info
    self.fetchUserInfo = [ApplicationDelegate.networkOperations fetchUserInfo:userEmail];
    [self.fetchUserInfo onCompletion:^(JUSSNetworkOperation *completedOperation) {
        userInfo = [completedOperation responseJSON];
        if ([userInfo objectForKey:@"User_Nickname"]) {
            [self.nameLabel setText:[userInfo objectForKey:@"User_Nickname"]];
            [self.coreDatabase setObject:[userInfo objectForKey:@"User_Nickname"] forKey:[NSString stringWithFormat:@"%@_Nickname", userEmail]];
        }
        else {
            [self.nameLabel setText:userEmail];
        }
        
    } onError:^(NSError *error) {
        OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"Connection Error" message: @"Please check your internet connection" timeout:1 dismissible:YES];
        [ghastly show];
    }];
    
    
    // Download the newest profile photo
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:profilePhotoPath error:&error];
    
    self.downloadOperation = [ApplicationDelegate.networkOperations downloadFile:profilePhotoURL toFile:profilePhotoPath];
    [self.downloadOperation onCompletion:^(JUSSNetworkOperation *completedOperation) {
        
        if ([fileManager fileExistsAtPath:profilePhotoPath]) {
            // Set profile photo
            [self.profilePhoto setImage:[UIImage imageWithContentsOfFile:profilePhotoPath]];
            NSError *error;
            [fileManager removeItemAtPath:profileBackupPhotoPath error:&error];
            [fileManager copyItemAtPath:profilePhotoPath toPath:profileBackupPhotoPath error:&error];
        }
        else {
            [self.profilePhoto setImage:[UIImage imageWithContentsOfFile:profileBackupPhotoPath]];
        }
    } onError:^(NSError *error) {
        OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"Connection Error" message: @"Please check your internet connection" timeout:1 dismissible:YES];
        [ghastly show];
    }];
    
    
    
    // Fetch received cards
    self.fetchCards = [ApplicationDelegate.networkOperations fetchCards:userEmail];
    [self.fetchCards onCompletion:^(JUSSNetworkOperation *completedOperation) {
        
        newCards = [completedOperation responseJSON];
        
        if ([newCards count] > 0) {
            
            NSString *hostName = [@"http://" stringByAppendingString:ApplicationDelegate.hostName];
            NSString *lifeWordStorage = [hostName stringByAppendingString:@"/lifewords/app/webroot"];
            
            NSString *cardPath = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Card_Path", userEmail]];
            
            int numberOfCards = [[self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]] count];
            
            int numberOfNewCards = [newCards count];
            
            for (NSDictionary *aCard in newCards) {
                
                
                
                numberOfCards += 1;
                
                currentCardPath = [cardPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", numberOfCards]];
                
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                
                NSString *cardTitle = [aCard objectForKey:@"Card_Text"];
                NSString *cardPhoto = [aCard objectForKey:@"Card_Photo"];
                NSString *cardURL = [lifeWordStorage stringByAppendingString:cardPhoto];
                NSString *cardPhotoPath = [currentCardPath stringByAppendingPathComponent:@"card_photo.jpg"];
                
                NSString *musicString = [aCard objectForKey:@"Card_Music"];
                NSNumber *musicS = [f numberFromString:[aCard objectForKey:@"Card_Music_StartTime"]];
                NSNumber *musicL = [f numberFromString:[aCard objectForKey:@"Card_Music_Length"]];
                
                NSString *soundEffectString = [aCard objectForKey:@"Card_Effect"];
                NSNumber *effectS = [f numberFromString:[aCard objectForKey:@"Card_Effect_StartTime"]];
                NSNumber *effectL = [f numberFromString:[aCard objectForKey:@"Card_Effect_Length"]];
                
                NSString *voiceURL = [aCard objectForKey:@"Card_Voice"];
                voiceURL = [lifeWordStorage stringByAppendingString:voiceURL];
                NSString *voiceString = [currentCardPath stringByAppendingPathComponent:@"voice.wav"];
                NSNumber *voiceS = [f numberFromString:[aCard objectForKey:@"Card_Voice_StartTime"]];
                NSNumber *voiceL = [f numberFromString:[aCard objectForKey:@"Card_Voice_Length"]];
                
                NSString *cardDate = [aCard objectForKey:@"Card_Date"];
                
                NSString *cardOwner = [aCard objectForKey:@"Card_Owner"];
                
                NSArray *musicInfo = [[NSArray alloc] initWithObjects:musicString, musicS, musicL, nil];
                NSArray *effectInfo = [[NSArray alloc] initWithObjects:soundEffectString, effectS, effectL, nil];
                NSArray *voiceInfo = [[NSArray alloc] initWithObjects:voiceString, voiceS, voiceL, nil];
                
                
                
                NSError *error;
                if (![[NSFileManager defaultManager] fileExistsAtPath:currentCardPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:currentCardPath withIntermediateDirectories:NO attributes:nil error:&error];
                
                self.downloadOperation = [ApplicationDelegate.networkOperations downloadFile:cardURL toFile:cardPhotoPath];
                [self.downloadOperation onCompletion:^(JUSSNetworkOperation *completedOperation) {
                    
                    NSArray *currentCard = [[NSArray alloc] initWithObjects:cardTitle, cardPhotoPath, cardDate, musicInfo, effectInfo, voiceInfo, cardOwner,  nil];
                    
                    
                    if ([[self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]] count] == 0) {
                        
                        temporaryCards = [[NSArray alloc] initWithObjects:currentCard, nil];
                        [self.coreDatabase setObject:temporaryCards forKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];
                        
                        
                    }
                    else {
                        
                        temporaryCards = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];
                        temporaryCards = [temporaryCards arrayByAddingObject:currentCard];
                        [self.coreDatabase setObject:temporaryCards forKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];
                        
                    }
                    
                    
                    
                    // Fill up scroll views
                    [[self.receivedCard subviews]
                     makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [self.receivedCard setAlwaysBounceVertical:NO];
                    [self.receivedCard setPagingEnabled:YES];
                    [self.receivedCard setContentSize:CGSizeMake(574, 128)];
                    [self fillSharedScrollView:temporaryCards withScrollView:self.receivedCard];
                    
                    if (numberOfNewCards > 1) {
                        for (UIView *view in [self.receivedCard subviews]) {
                            JSBadgeView *friendsBadge = [[JSBadgeView alloc] initWithParentView:view
                                                                                      alignment:JSBadgeViewAlignmentTopRight];
                            friendsBadge.badgeText = @"New";
                            friendsBadge.badgePositionAdjustment = CGPointMake(-20.0f, 5.0f);
                        }
                    }
                    else {
                        JSBadgeView *friendsBadge = [[JSBadgeView alloc] initWithParentView:[[self.receivedCard subviews] objectAtIndex:0]
                                                                                  alignment:JSBadgeViewAlignmentTopRight];
                        friendsBadge.badgeText = @"New";
                        friendsBadge.badgePositionAdjustment = CGPointMake(-20.0f, 5.0f);
                    }
                    
                } onError:^(NSError *error) {
                    
                    OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"Connection Error" message: @"Please check your internet connection" timeout:1 dismissible:YES];
                    [ghastly show];
                }];
                
                if (![[aCard objectForKey:@"Card_Voice"] isEqualToString:@""]) {
                    self.downloadOperation = [ApplicationDelegate.networkOperations downloadFile:voiceURL toFile:voiceString];
                    [self.downloadOperation onCompletion:^(JUSSNetworkOperation *completedOperation) {
                        
                    } onError:^(NSError *error) {
                        
                        OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"Connection Error" message: @"Please check your internet connection" timeout:1 dismissible:YES];
                        [ghastly show];
                    }];
                }
                
            }
            
           

        }
        else {
            // Fill up scroll views
            [[self.receivedCard subviews]
             makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.receivedCard setAlwaysBounceVertical:NO];
            [self.receivedCard setPagingEnabled:YES];
            [self.receivedCard setContentSize:CGSizeMake(574, 128)];
            [self fillSharedScrollView:receivedCards withScrollView:self.receivedCard];
        }
        
        [self.coreDatabase synchronize];
        [refreshControl endRefreshing];
        receivedCards = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];
        
    } onError:^(NSError *error) {
        
    }];
    
    receivedCards = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Received_Cards", userEmail]];
}


- (IBAction)logoutBtnClicked:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out Confirm" message:@"Are you sure you want to log out now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
    [alert show];
    
    
}

- (IBAction)configBtnClicked:(id)sender {
    lifeWordsColorSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"colorSelectView"];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    [self.popover presentPopoverFromRect:self.configBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover.delegate = self;
}

- (IBAction)collectionBtnClicked:(id)sender {
    if ([cards count] < 1) {
        OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"No Cards" message: @"You have no card in your collection" timeout:1 dismissible:YES];
        [ghastly show];
    }
    else {
        [self performSegueWithIdentifier:@"to3D" sender:nil];
        
    }
}

- (void) handleThemeSelect:(NSNotification *)pNotification
{
    // Get info from notification object
    NSString *colorSelected = [pNotification object];
    
    if ([colorSelected isEqualToString:@"Blue Sky"]) {
        [self.coreDatabase setObject:@"blue_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Blue Sky.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"blue_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
        
    }
    else if ([colorSelected isEqualToString:@"Green Leaf"]) {
        [self.coreDatabase setObject:@"green_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Green Leaf.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"green_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    }
    else if ([colorSelected isEqualToString:@"Indigo Horizon"]) {
        [self.coreDatabase setObject:@"indigo_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Indigo Horizon.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"indigo_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    }
    else if ([colorSelected isEqualToString:@"Orange Sunset"]) {
        [self.coreDatabase setObject:@"orange_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Orange Sunset.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"orange_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
        
    }
    else if ([colorSelected isEqualToString:@"Red Sunrise"]) {
        [self.coreDatabase setObject:@"red_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Red Sunrise.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"red_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    }
    else if ([colorSelected isEqualToString:@"Violet Silk"]) {
        [self.coreDatabase setObject:@"violet_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Violet Silk.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"violet_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    }
    else {
        [self.coreDatabase setObject:@"yellow_" forKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
        [self.wallpaper setImage:[UIImage imageNamed:@"Yellow Autumn.jpg"]];
        UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", @"yellow_"]];
        [self.myToolBar setBackgroundImage:navBarImg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    }
    
    [self.coreDatabase synchronize];
    
    color = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self.coreDatabase removeObjectForKey:@"Current_User_Email"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - Scroll Views

- (void)fillScrollView:(NSArray *)cardsArray withScrollView:(UIScrollView *)scrollView {
    
    int lastX = 10;
    int index = 0;
    
    for (NSArray *card in [cardsArray reverseObjectEnumerator])
    {
        
        UIImage *cardPhoto = [UIImage imageWithContentsOfFile:[card objectAtIndex:1]];
        
        CGRect thumRect;
        
        SWSnapshotStackView *thImage;
        UIButton *previewBtn;
        UILabel *tv;
        
        thumRect = CGRectMake(lastX, 10, 110, 190);
        thImage = [[SWSnapshotStackView alloc] initWithFrame:CGRectMake(0, 0, 110, 160)];
        previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, 160)];
        previewBtn.tag = index;
        [previewBtn addTarget:self action:@selector(viewCard:) forControlEvents:UIControlEventTouchUpInside];
        
        tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 145, 110, 25)];
        
        UIControl *thumbImageButton = [[UIControl alloc] initWithFrame:thumRect];
        thumbImageButton.backgroundColor = [UIColor clearColor];
        
        thumbImageButton.tag = index;
        
        thImage.image = cardPhoto;
        
        if ([[card objectAtIndex:0] isEqualToString:@""]) {
            [tv setText:@"No Title"];
        }
        else {
            [tv setText:[card objectAtIndex:0]];
        }
        [tv setFont:[UIFont fontWithName:@"Noteworthy" size:15.0]];
        [tv setTextAlignment:NSTextAlignmentCenter];
        [tv setBackgroundColor:[UIColor clearColor]];
        [tv setTextColor:[UIColor blackColor]];
        
        
        
        [thumbImageButton addSubview:thImage];
        [thumbImageButton addSubview:tv];
        [thumbImageButton addSubview:previewBtn];
        [thumbImageButton addTarget:self action:@selector(viewCard:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:thumbImageButton];
        
        
        lastX = lastX + 120;
        [scrollView setContentSize:CGSizeMake(lastX, 120)];
        
        index += 1;
        
    }
    
}

- (void)fillSharedScrollView:(NSArray *)cardsArray withScrollView:(UIScrollView *)scrollView {
    
    int lastX = 10;
    int index = 0;
    
    for (NSArray *card in [cardsArray reverseObjectEnumerator])
    {
        
        UIImage *cardPhoto = [UIImage imageWithContentsOfFile:[card objectAtIndex:1]];
        
        CGRect thumRect;
        
        SWSnapshotStackView *thImage;
        UIButton *previewBtn;
        UILabel *tv;
        
        thumRect = CGRectMake(lastX, 10, 110, 190);
        thImage = [[SWSnapshotStackView alloc] initWithFrame:CGRectMake(0, 0, 110, 160)];
        previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, 160)];
        previewBtn.tag = index;
        [previewBtn addTarget:self action:@selector(viewSharedCard:) forControlEvents:UIControlEventTouchUpInside];
        
        tv = [[UILabel alloc] initWithFrame:CGRectMake(0, 145, 110, 25)];
        
        UIControl *thumbImageButton = [[UIControl alloc] initWithFrame:thumRect];
        thumbImageButton.backgroundColor = [UIColor clearColor];
        
        thumbImageButton.tag = index;
        
        thImage.image = cardPhoto;
        
        if ([[card objectAtIndex:0] isEqualToString:@""]) {
            [tv setText:@"No Title"];
        }
        else {
            [tv setText:[card objectAtIndex:0]];
        }
        [tv setFont:[UIFont fontWithName:@"Noteworthy" size:15.0]];
        [tv setTextAlignment:NSTextAlignmentCenter];
        [tv setBackgroundColor:[UIColor clearColor]];
        [tv setTextColor:[UIColor blackColor]];
        
        
        
        [thumbImageButton addSubview:thImage];
        [thumbImageButton addSubview:tv];
        [thumbImageButton addSubview:previewBtn];
        [thumbImageButton addTarget:self action:@selector(viewCard:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:thumbImageButton];
        
        
        lastX = lastX + 120;
        [scrollView setContentSize:CGSizeMake(lastX, 120)];
        
        index += 1;
        
    }
    
}

- (void) viewCard:(UIControl *)selectedControl
{
    received = NO;
    int index = [cards count] - selectedControl.tag - 1;
    previewCard = [cards objectAtIndex:index];
    [self performSegueWithIdentifier:@"toPreview" sender:nil];
}

- (void) viewSharedCard:(UIControl *)selectedControl {
    received = YES;
    int index = [receivedCards count] - selectedControl.tag - 1;
    previewCard = [receivedCards objectAtIndex:index];
    [self performSegueWithIdentifier:@"toPreview" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toPreview"]) {
        
        if (received == NO) {
            lifeWordsPreviewViewController *vc = [segue destinationViewController];
            
            UIImage *photo = [UIImage imageWithContentsOfFile:[previewCard objectAtIndex:1]];
            [vc setPhoto:photo];
            
            NSArray *musicInfo = nil;
            NSArray *effectInfo = nil;
            NSArray *voiceInfo = nil;
            
            NSArray *musicArray = [previewCard objectAtIndex:3];
            if ([musicArray count] > 0) {
                NSURL *musicComponent = [[NSBundle mainBundle] URLForResource:[musicArray objectAtIndex:0] withExtension:@"mp3"];
                musicInfo = [[NSArray alloc] initWithObjects:musicComponent, [musicArray objectAtIndex:1], [musicArray objectAtIndex:2], nil];
            }
            
            NSArray *effectArray = [previewCard objectAtIndex:4];
            if ([effectArray count] > 0) {
                NSURL *soundEffectComponent = [[NSBundle mainBundle] URLForResource:[effectArray objectAtIndex:0] withExtension:@"mp3"];
                effectInfo = [[NSArray alloc] initWithObjects:soundEffectComponent, [effectArray objectAtIndex:1], [effectArray objectAtIndex:2], nil];
            }
            
            
            NSArray *voiceArray = [previewCard objectAtIndex:5];
            if ([voiceArray count] > 0) {
                NSURL *voiceComponent = [[NSURL alloc] initFileURLWithPath:[voiceArray objectAtIndex:0]];
                voiceInfo = [[NSArray alloc] initWithObjects:voiceComponent, [voiceArray objectAtIndex:1], [voiceArray objectAtIndex:2], nil];
            }
            
            [vc setCardTitle:[previewCard objectAtIndex:0]];
            [vc setCardDate:[previewCard objectAtIndex:2]];
            [vc setMusicInfo:musicInfo];
            [vc setEffectInfo:effectInfo];
            [vc setVoiceInfo:voiceInfo];
        }
        else {
            lifeWordsPreviewViewController *vc = [segue destinationViewController];
            
            UIImage *photo = [UIImage imageWithContentsOfFile:[previewCard objectAtIndex:1]];
            [vc setPhoto:photo];
            
            NSArray *musicInfo = nil;
            NSArray *effectInfo = nil;
            NSArray *voiceInfo = nil;
            
            NSArray *musicArray = [previewCard objectAtIndex:3];
            if ([musicArray count] > 0) {
                NSURL *musicComponent = [[NSBundle mainBundle] URLForResource:[musicArray objectAtIndex:0] withExtension:@"mp3"];
                musicInfo = [[NSArray alloc] initWithObjects:musicComponent, [musicArray objectAtIndex:1], [musicArray objectAtIndex:2], nil];
            }
            
            NSArray *effectArray = [previewCard objectAtIndex:4];
            if ([effectArray count] > 0) {
                NSURL *soundEffectComponent = [[NSBundle mainBundle] URLForResource:[effectArray objectAtIndex:0] withExtension:@"mp3"];
                effectInfo = [[NSArray alloc] initWithObjects:soundEffectComponent, [effectArray objectAtIndex:1], [effectArray objectAtIndex:2], nil];
            }
            
            
            NSArray *voiceArray = [previewCard objectAtIndex:5];
            if ([voiceArray count] > 0) {
                NSURL *voiceComponent = [[NSURL alloc] initFileURLWithPath:[voiceArray objectAtIndex:0]];
                voiceInfo = [[NSArray alloc] initWithObjects:voiceComponent, [voiceArray objectAtIndex:1], [voiceArray objectAtIndex:2], nil];
            }
            
            [vc setCardTitle:[previewCard objectAtIndex:0]];
            [vc setCardDate:[previewCard objectAtIndex:2]];
            [vc setCardOwner:[previewCard lastObject]];
            [vc setMusicInfo:musicInfo];
            [vc setEffectInfo:effectInfo];
            [vc setVoiceInfo:voiceInfo];
        }
        
    }
    else  {
        lifeWords3DViewController *vc = [segue destinationViewController];
        [vc setCards:cards];
    }
}
@end
