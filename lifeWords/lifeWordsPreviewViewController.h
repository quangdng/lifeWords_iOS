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
    NSTimer *progressTimer;
}

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) IBOutlet UIImageView *corePhoto;

// Card's Info
@property (strong, nonatomic) NSArray *musicInfo;
@property (strong, nonatomic) NSArray *effectInfo;
@property (strong, nonatomic) NSArray *voiceInfo;

// Players
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) AVAudioPlayer *effectPlayer;
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

// Outlets
@property (strong, nonatomic) IBOutlet UIButton *playMusicBtn;
@property (strong, nonatomic) IBOutlet UIButton *stopMusicBtn;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressBar;

// Actions
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

@end
