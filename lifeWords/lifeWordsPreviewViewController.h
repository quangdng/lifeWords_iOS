//
//  lifeWordsPreviewViewController.h
//  lifeWords
//
//  Created by Thiên Phong on 12/23/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAudioPlayer+PGFade.h"

@interface lifeWordsPreviewViewController : UIViewController {
    
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
    
    // Show/Hide Menu
    BOOL show;
    BOOL stop;
}

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) IBOutlet UIImageView *corePhoto;

// Card's Info
@property (strong, nonatomic) NSString *cardTitle;
@property (strong, nonatomic) NSArray *musicInfo;
@property (strong, nonatomic) NSArray *effectInfo;
@property (strong, nonatomic) NSArray *voiceInfo;
@property (strong, nonatomic) NSString *cardDate;
@property (strong, nonatomic) NSString *cardOwner;

// Players
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) AVAudioPlayer *effectPlayer;
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

// Outlets
@property (strong, nonatomic) IBOutlet UIButton *playMusicBtn;
@property (strong, nonatomic) IBOutlet UIButton *stopMusicBtn;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressBar;
@property (strong, nonatomic) IBOutlet UIView *transparentView;
@property (strong, nonatomic) IBOutlet UIView *holderView;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (strong, nonatomic) IBOutlet UILabel *leftTimeLbl;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *senderLbl;
@property (strong, nonatomic) IBOutlet UILabel *cardDateLbl;


// Actions
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)hideMenu:(id)sender;
- (IBAction)dismiss:(id)sender;
@end
