//
//  lifeWords3DViewController.h
//  lifeWords
//
//  Created by Thiên Phong on 1/3/13.
//  Copyright (c) 2013 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPepperViewController.h"
#import "YLProgressBar.h"
#import "AVAudioPlayer+PGFade.h"
#import "MyBookOrPageView.h"
#import "MyPageViewDetail.h"
@interface lifeWords3DViewController : UIViewController <PPScrollListViewControllerDataSource, PPScrollListViewControllerDelegate> {
    
    int numberOfBooks;
    
    NSMutableArray *familyArray;
    NSMutableArray *friendsArray;
    NSMutableArray *loveArray;
    NSMutableArray *bookArray;
    
    // Audio players
    BOOL show;
    Book *currentBook;
    NSArray *currentCard;
    
    // Card TimeLine Components
    NSURL *musicComponent;
    NSURL *soundEffectComponent;
    NSURL *voiceComponent;
    
    // Timeline Constant
    float musicStartTime;
    float musicLength;
    NSTimer *musicTimer;
    NSTimer *musicStopTimer;
    float effectStartTime;
    float effectLength;
    NSTimer *effectTimer;
    NSTimer *effectStopTimer;
    float voiceStartTime;
    float voiceLength;
    NSTimer *voiceTimer;
    NSTimer *voiceStopTimer;
    
    // Progress Timer
    float music;
    float effect;
    float voice;
    float max;
    float currentTime;
    NSTimer *progressTimer;
}

@property (nonatomic, strong) PPPepperViewController * pepperViewController;
@property (nonatomic, assign) BOOL iOS5AndAbove;
@property (nonatomic, strong) NSMutableArray *bookDataArray;

@property (strong, nonatomic) NSArray *cards;


// Outlets
@property (strong, nonatomic) IBOutlet UIView *operationBar;
@property (strong, nonatomic) IBOutlet UILabel *bookName;
@property (strong, nonatomic) IBOutlet UIImageView *wallpaper;
@property (strong, nonatomic) IBOutlet UIView *holderView;
@property (strong, nonatomic) IBOutlet UIView *transparentView;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) IBOutlet UIButton *dismissBtn;


// Audio players
// Players
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) AVAudioPlayer *effectPlayer;
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

@property (strong, nonatomic) IBOutlet UIButton *playMusicBtn;
@property (strong, nonatomic) IBOutlet UIButton *stopMusicBtn;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressBar;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (strong, nonatomic) IBOutlet UILabel *leftTimeLbl;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *cardDateLbl;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;



// Actions
- (IBAction)dismissView:(id)sender;
@end
