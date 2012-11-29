//
//  lifeWordsTimeLineViewController.m
//  lifeWords
//
//  Created by JustaLiar on 7/11/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#define XMAX	20.0f
#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewInteractiveBorderSize 10.0

#import "lifeWordsTimeLineViewController.h"
#import "lifeWordsMusicSelectViewController.h"
#import "lifeWordsSoundEffectsViewController.h"
#import "WaveformImageView.h"
#import "MBProgressHUD.h"
#import "KSCustomPopoverBackgroundView.h"
#import "AVAudioPlayer+PGFade.h"
#import "UIImage+Helpers.h"
@interface lifeWordsTimeLineViewController () {
    MBProgressHUD *HUD;
}

@end

@implementation lifeWordsTimeLineViewController

#pragma mark - UIViewController Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start the audio session
    [self startAudioSession];
    
    
    // Set photo
    [self.cardPhoto setImage:self.photo];
    
    // Set the wallpaper
    [self.wallpaper setImage:[UIImage imageNamed:@"leaf_tree.jpg"]];
    
    // Prevent the view to dim
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Fetch data from NSUserDefaults
    self.coreDatabase = [NSUserDefaults standardUserDefaults];
    userEmail = [self.coreDatabase objectForKey:@"Current_User_Email"];
    color = [self.coreDatabase objectForKey:[NSString stringWithFormat:@"%@_Color", userEmail]];
    
    //Create a new barbutton with an action
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(backBarPressed)];
    UIImage *backBtnImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-back.png", color]];
    [barbutton setBackgroundImage:backBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    // and put the button in the nav bar
    [self.navigationItem setLeftBarButtonItem:barbutton];
    
    
    // Set current date for date textbox
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd MMMM YYYY"];
    NSString *dateString = [dateFormat stringFromDate:date];
    [self.cardDate setText:dateString];
    
    // Beautify Record View
    [self.recordView.layer setCornerRadius:10.0f];
    [self.recordView setAlpha:0.8f];
    [self.recordView.layer setShadowRadius:5.0f];
    [self.recordMeter1 setProgressTintColor:[UIColor greenColor]];
    [self.recordMeter2 setProgressTintColor:[UIColor redColor]];

    // Decorate TimeLine View
    self.musicView.layer.cornerRadius = 10;
    self.effectView.layer.cornerRadius = 10;
    self.voiceView.layer.cornerRadius = 10;
    
    // Add Gesture Recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Set timeline indicator
    self.timeLineIndicator.hidden = NO;
    CGRect indicatorRect = CGRectMake(self.musicView.frame.origin.x + 4, self.timeLineIndicator.frame.origin.y, self.timeLineIndicator.frame.size.width, self.timeLineIndicator.frame.size.height);
    self.timeLineIndicator.frame = indicatorRect;
    self.timeLineIndicator.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.timeLineIndicator.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.timeLineIndicator.layer.shadowRadius = 1.0f;
    self.timeLineIndicator.layer.shadowOpacity = 1.0f;
    
    // Set timeline container
    self.timeLineBackground.layer.cornerRadius = 10;
    self.timeLineBackground.clipsToBounds =  YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationFromMusicSelect:) name:@"Music Selected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationFromEffectSelect:) name:@"Effect Selected" object:nil];
    
    // Show navigation bar
    [self.navigationController navigationBar].hidden = NO;
    
    // Set navigation bar background
    UIImage *navBarImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@ipad-menubar-right.png", color]];
    [self.navigationController.navigationBar setBackgroundImage:navBarImg forBarMetrics:UIBarMetricsDefault];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;

}
     
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setTimeLineIndicator:nil];
    [self setTimeLineBackground:nil];
    [super viewDidUnload];
    [self setCoreDatabase:nil];
    [self setMusicBtn:nil];
    [self setPopover:nil];
    [self setEffectsBtn:nil];
    [self setCardTitle:nil];
    [self setCardDate:nil];
    [self setCardLength:nil];
    [self setRecordBtn:nil];
    [self setRecordView:nil];
    [self setRecordMeter1:nil];
    [self setRecordMeter2:nil];
    [self setRecordCancelBtn:nil];
    [self setRecordPlayBtn:nil];
    [self setRecordAcceptBtn:nil];
    [self setRecordRecBtn:nil];
    [self setCurrentCardPath:nil];
    [self setWallpaper:nil];
    [self setMusicView:nil];
    [self setEffectView:nil];
    [self setPhoto:nil];
    [self setCardPhoto:nil];
    [self setVoiceView:nil];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    
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

- (void) backBarPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) startAudioSession
{
	// Prepare the audio session
	NSError *error;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error setting session category: %@", error.localizedFailureReason);
		return NO;
	}
	
	if (![session setActive:YES error:&error])
	{
		NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
		return NO;
	}
	
	return session.inputIsAvailable;
}

#pragma mark - Time Line Components
- (IBAction)test:(id)sender {
    
    [self updateTimeLineIndicator];

    self.timeLineIndicator.hidden = NO;
    
    musicTimer = [NSTimer scheduledTimerWithTimeInterval:musicStartTime target:self selector:@selector(playMusic) userInfo:nil repeats:NO];
    effectTimer = [NSTimer scheduledTimerWithTimeInterval:effectStartTime target:self selector:@selector(playEffect) userInfo:nil repeats:NO];
    voiceTimer = [NSTimer scheduledTimerWithTimeInterval:voiceStartTime target:self selector:@selector(playVoice) userInfo:nil repeats:NO];
    
    musicStopTimer = [NSTimer scheduledTimerWithTimeInterval:musicStartTime + musicLength target:self selector:@selector(stopMusic) userInfo:nil repeats:NO];
    effectStopTimer = [NSTimer scheduledTimerWithTimeInterval:effectStartTime + effectLength target:self selector:@selector(stopEffect) userInfo:nil repeats:NO];
    voiceStopTimer = [NSTimer scheduledTimerWithTimeInterval:voiceStartTime + voiceLength target:self selector:@selector(stopVoice) userInfo:nil repeats:NO];
}

- (void) displayVolume {
    NSLog(@"Music Volume %f, Effect Volume %f", [self.musicPlayer volume], [self.effectPlayer volume]);
}

- (void) playMusic{
    [self.musicPlayer playWithFadeDuration:3];
    [musicTimer invalidate];
    musicTimer = nil;
}

- (void) playEffect {
    [self.effectPlayer playWithFadeDuration:3];
    [effectTimer invalidate];
    effectTimer = nil;
}

- (void) playVoice{
    [self.voicePlayer playWithFadeDuration:3];
    [voiceTimer invalidate];
    voiceTimer = nil;
}

- (void) stopMusic {
    [self.musicPlayer stopWithFadeDuration:1];
    [musicStopTimer invalidate];
    musicStopTimer = nil;
}

- (void) stopEffect {
    [self.effectPlayer stopWithFadeDuration:1];
    [effectStopTimer invalidate];
    effectStopTimer = nil;
}

- (void) stopVoice {
    [self.voicePlayer stopWithFadeDuration:1];
    [voiceStopTimer invalidate];
    voiceStopTimer = nil;
}

- (IBAction)musicBtnClicked:(id)sender {
    lifeWordsMusicSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"musicSelectView"];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    [self.popover presentPopoverFromRect:self.musicBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover.delegate = self;
}

- (IBAction)effectsBtnClicked:(id)sender {
    lifeWordsSoundEffectsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"soundEffectsView"];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    [self.popover presentPopoverFromRect:self.effectsBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover.delegate = self;
}

#pragma mark - Time Line Actions

- (void) updateTimeLineIndicator
{
    float music = musicStartTime + musicLength;
    float effect = effectStartTime + effectLength;
    float voice = voiceStartTime + voiceLength;
    
    if (MAX(music, effect) <= voice) {
        CGRect convertedRect = [self.voiceView convertRect:voiceAudioWave.frame toView:self.view];
        float startSpace = voiceStartTime * self.voiceView.frame.size.width / 180;
        [UIView animateWithDuration:voice delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.timeLineIndicator.transform = CGAffineTransformTranslate(self.timeLineIndicator.transform, startSpace + convertedRect.size.width - 15, 0);
        } completion:^(BOOL finished) {
            
        }];
        NSLog(@"Voice");
    }
    else {
        if (MAX(music, effect) == music) {
            CGRect convertedRect = [self.musicView convertRect:musicAudioWave.frame toView:self.view];
            float startSpace = musicStartTime * self.musicView.frame.size.width / 180;
            [UIView animateWithDuration:music delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.timeLineIndicator.transform = CGAffineTransformTranslate(self.timeLineIndicator.transform, startSpace + convertedRect.size.width - 15, 0);
            } completion:^(BOOL finished) {
                
            }];
            NSLog(@"Music Size %f", musicAudioWave.frame.size.width);
            NSLog(@"Timeline Indicator %f", self.timeLineIndicator.frame.origin.x);
        }
        else {
            CGRect convertedRect = [self.effectView convertRect:effectAudioWave.frame toView:self.view];
            float startSpace = effectStartTime * self.effectView.frame.size.width / 180;
            [UIView animateWithDuration:effect delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.timeLineIndicator.transform = CGAffineTransformTranslate(self.timeLineIndicator.transform, startSpace + convertedRect.size.width - 15, 0);
            } completion:^(BOOL finished) {
                
            }];

            NSLog(@"Effect");
        }
    }
}

- (void) handleNotificationFromMusicSelect: (NSNotification *)pNotification {
    [self.popover dismissPopoverAnimated:YES];
    self.musicBtn.selected = NO;
    
    // Add HUD activity indicator
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Processing Music...";
    HUD.dimBackground = YES;
    HUD.minSize = CGSizeMake(140.f, 140.f);
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        // Get info from notification object
        NSString *musicString = [[pNotification object] objectAtIndex:0];
       
        
        // Set music variables & initiate music player
        musicLength = [self convertTimeToSec:[[pNotification object] objectAtIndex:1]];
        musicComponent = [[NSBundle mainBundle] URLForResource:musicString withExtension:@"mp3"];
        musicStartTime = 0;
        
        NSError *error;
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicComponent error:&error];
        [self.musicPlayer setVolume:1];
        [self.musicPlayer prepareToPlay];
        
        
        // Audio wave container
        if (musicAudioWave) {
            [[[self.musicView subviews] objectAtIndex:0] removeFromSuperview];
        }
        musicAudioWave = [[SPUserResizableView alloc] initWithFrame:CGRectMake(0, 0, self.musicView.frame
                                                                                                    .size.width * musicLength / 180.f, self.musicView.frame
                                                                                                    .size.height)];
        musicAudioWave.tag = 0;
        
        // Generate Audio Wave
        WaveformImageView *wave = [[WaveformImageView alloc] initWithUrl:musicComponent];
        CGRect frame = CGRectInset(musicAudioWave.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        UIImage *image = [wave.image resize:frame.size];
        UIImageView *waveView = [[UIImageView alloc] initWithImage:image];
        waveView.layer.cornerRadius = 10;
        waveView.clipsToBounds = YES;
        waveView.layer.borderColor = [UIColor blackColor].CGColor;
        waveView.layer.borderWidth = 1;
       
        // Add overlay view
        UIView *overlayView = [[UIView alloc] initWithFrame:waveView.frame];
        UIColor *overlayColor = [[UIColor alloc]initWithRed: 0.337938 green: 0.595800 blue: 0.176782 alpha:1];
        [overlayView setBackgroundColor:overlayColor];
        overlayView.layer.cornerRadius = 10.0f;
        overlayView.clipsToBounds = YES;
        overlayView.alpha = 0.5;
        [waveView addSubview:overlayView];
        
        // Add wave view and beautify it
        musicAudioWave.contentView = waveView;
        musicAudioWave.layer.shadowColor = [[UIColor blackColor] CGColor];
        musicAudioWave.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        musicAudioWave.layer.shadowRadius = 1.0f;
        musicAudioWave.layer.shadowOpacity = 1.0f;
        
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
        
        // Set delegation and stuffs
        musicAudioWave.delegate = self;
        currentlyEditingView = musicAudioWave;
        lastEditedView = musicAudioWave;
        
        // Add music view
        [self.musicView addSubview:musicAudioWave];
    }];
}


- (void) handleNotificationFromEffectSelect: (NSNotification *)pNotification {
    [self.popover dismissPopoverAnimated:YES];
    self.effectsBtn.selected = NO;
    
    // Add HUD activity indicator
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Processing Effect...";
    HUD.dimBackground = YES;
    HUD.minSize = CGSizeMake(140.f, 140.f);
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        // Get info from notification object
        NSString *soundEffectString = [[pNotification object] objectAtIndex:0];
        
        // Set music variables & initiate music player
        effectLength = [self convertTimeToSec:[[pNotification object] objectAtIndex:1]];
        soundEffectComponent = [[NSBundle mainBundle] URLForResource:soundEffectString withExtension:@"mp3"];
        effectStartTime = 0;
        
        NSError *error;
        self.effectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundEffectComponent error:&error];
        [self.effectPlayer setVolume:0.5];
        [self.effectPlayer prepareToPlay];
        
        // Audio wave container
        if (effectAudioWave) {
            [[[self.effectView subviews] objectAtIndex:0] removeFromSuperview];
        }
        effectAudioWave = [[SPUserResizableView alloc] initWithFrame:CGRectMake(0, 0, self.effectView.frame
                                                                               .size.width * effectLength / 180.f, self.effectView.frame
                                                                               .size.height)];
        effectAudioWave.tag = 1;
        
        // Generate Audio Wave
        WaveformImageView *wave = [[WaveformImageView alloc] initWithUrl:soundEffectComponent];
        CGRect frame = CGRectInset(effectAudioWave.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        UIImage *image = [wave.image resize:frame.size];
        UIImageView *waveView = [[UIImageView alloc] initWithImage:image];
        waveView.layer.cornerRadius = 10;
        waveView.clipsToBounds = YES;
        
        // Add overlay view
        UIView *overlayView = [[UIView alloc] initWithFrame:waveView.frame];
        UIColor *overlayColor = [[UIColor alloc]initWithRed: 1.000000 green: 0.550810 blue: 0.099465 alpha: 1 ];
        [overlayView setBackgroundColor:overlayColor];
        overlayView.alpha = 0.5;
        [waveView addSubview:overlayView];
        
        // Add label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(waveView.frame.origin.x, waveView.frame.origin.y, waveView.frame.size.width / 5, waveView.frame.size.height)];
        label.backgroundColor = [UIColor whiteColor];
        
        // Add wave view and beautify it
        effectAudioWave.contentView = waveView;
        effectAudioWave.layer.shadowColor = [[UIColor blackColor] CGColor];
        effectAudioWave.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        effectAudioWave.layer.shadowRadius = 1.0f;
        effectAudioWave.layer.shadowOpacity = 1.0f;
        
    } completionBlock:^{
        
        [HUD removeFromSuperview];
        HUD = nil;
        
        // Set delegation and stuffs
        effectAudioWave.delegate = self;
        currentlyEditingView = effectAudioWave;
        lastEditedView = effectAudioWave;
        
        // Add effect view
        [self.effectView addSubview:effectAudioWave];
    }];
        
}

#pragma mark - UIPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark - Record View

- (IBAction)recordBtnClicked:(id)sender {
    self.recordBtn.selected = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.recordView setFrame:CGRectMake(151, self.recordView.frame.origin.y, self.recordView.frame.size.width, self.recordView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
}

- (NSURL *) recordURL
{
    NSString *outputPath = [self.currentCardPath stringByAppendingPathComponent:@"voice.wav"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:outputPath])
    {
        [manager removeItemAtPath:outputPath error:nil];
    }
    voiceComponent = outputURL;
    return outputURL;
}

- (IBAction)recordCancelBtnClicked:(id)sender {
    recorderPlayer = nil;
    [UIView animateWithDuration:0.5 animations:^{
        [self.recordView setFrame:CGRectMake(768, self.recordView.frame.origin.y, self.recordView.frame.size.width, self.recordView.frame.size.height)];
    } completion:^(BOOL finished) {
        recorderPlayer = nil;
    }];
}

- (IBAction)recordPlayBtnClicked:(id)sender {
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *outputPath = [self.currentCardPath stringByAppendingPathComponent:@"voice.wav"];
    if (![recorderPlayer isPlaying])
    {
        if ([manager fileExistsAtPath:outputPath])
        {
            recorderPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePlayerMeters) userInfo:nil repeats:YES];
            [recorderPlayerTimer fire];
            
            [recorderPlayer play];
            [self.recordPlayBtn setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
    else
    {
        [recorderPlayer stop];
        [recorderPlayerTimer invalidate];
        recorderPlayerTimer = nil;
        [self.recordPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
        self.recordMeter1.progress = 0;
        self.recordMeter2.progress = 0;
    }

}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ([self.recordPlayBtn.titleLabel.text isEqualToString:@"Stop"]) {
        [self.recordPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
        [recorderPlayerTimer invalidate];
        recorderPlayerTimer = nil;
        self.recordMeter1.progress = 0;
        self.recordMeter2.progress = 0;
    }
}

- (IBAction)recordAcceptBtnClicked:(id)sender {
    
    // Release the player and pop out record menu
    recorderPlayer = nil;
    [UIView animateWithDuration:0.5 animations:^{
        [self.recordView setFrame:CGRectMake(768, self.recordView.frame.origin.y, self.recordView.frame.size.width, self.recordView.frame.size.height)];
    } completion:^(BOOL finished) {
        recorderPlayer = nil;
    }];
    
    // Add HUD activity indicator
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Processing Voice...";
    HUD.dimBackground = YES;
    HUD.minSize = CGSizeMake(140.f, 140.f);
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        // Initiate voice player
        NSError *error;
        self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceComponent error:&error];
        [self.voicePlayer setVolume:1];
        [self.voicePlayer prepareToPlay];
         voiceStartTime = 0;
        
       // Audio wave container
        if (voiceAudioWave) {
            [[[self.voiceView subviews] objectAtIndex:0] removeFromSuperview];
        }
        float voiceWidth = 0;
        if (self.voiceView.frame.size.width * voiceLength / 180.f < 48.f) {
            voiceWidth = 48;
        }
        else {
            voiceWidth = self.voiceView.frame.size.width * voiceLength / 180.f;
        }
        voiceAudioWave = [[SPUserResizableView alloc] initWithFrame:CGRectMake(0, 0, voiceWidth, self.voiceView.frame
                                                                               .size.height)];
        voiceAudioWave.tag = 2;
        
        // Generate Audio Wave
        WaveformImageView *wave = [[WaveformImageView alloc] initWithUrl:voiceComponent];
        CGRect frame = CGRectInset(voiceAudioWave.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        UIImage *image = [wave.image resize:frame.size];
        UIImageView *waveView = [[UIImageView alloc] initWithImage:image];
        waveView.layer.cornerRadius = 10;
        waveView.clipsToBounds = YES;
        
        // Add overlay view
        UIView *overlayView = [[UIView alloc] initWithFrame:waveView.frame];
        UIColor *overlayColor = [[UIColor alloc]initWithRed: 0.496389 green: 0.223599 blue: 0.815217 alpha:1];
        [overlayView setBackgroundColor:overlayColor];
        overlayView.alpha = 0.5;
        [waveView addSubview:overlayView];
        
        // Add wave view and beautify it
        voiceAudioWave.contentView = waveView;
        voiceAudioWave.layer.shadowColor = [[UIColor blackColor] CGColor];
        voiceAudioWave.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        voiceAudioWave.layer.shadowRadius = 1.0f;
        voiceAudioWave.layer.shadowOpacity = 1.0f;
        
        
    } completionBlock:^{
        
        [HUD removeFromSuperview];
        HUD = nil;
        
        // Set delegation and stuffs
        voiceAudioWave.delegate = self;
        currentlyEditingView = voiceAudioWave;
        lastEditedView = voiceAudioWave;
        
        // Add voice view
        [self.voiceView addSubview:voiceAudioWave];
        
        self.recordBtn.selected = NO;
       
    }];

    
}

- (IBAction)recordRecBtnClicked:(id)sender {
    
    
    if ([recorder isRecording])
    {
        voiceLength = [recorder currentTime];
        NSLog(@"%f", voiceLength);
        [recorder stop];
        [recorderTimer invalidate];
        recorderTimer = nil;
        recorder = nil;
        [self.recordRecBtn setTitle:@"Record" forState:UIControlStateNormal];
        [self.recordPlayBtn setEnabled:YES];
        [self.recordAcceptBtn setEnabled:YES];
        
        recorderPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordURL error:nil];
        recorderPlayer.meteringEnabled = YES;
        recorderPlayer.delegate = self;
        
        self.recordMeter1.progress = 0;
        self.recordMeter2.progress = 0;
        
    }
    else
    {
        // Set record settings
        recordURL = [self recordURL];
        
        // Recording settings
        NSMutableDictionary *settings = [NSMutableDictionary dictionary];
        [settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [settings setValue: [NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; // mono
        [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        recorder = [[AVAudioRecorder alloc] initWithURL:recordURL settings:settings error:nil];
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        
        recorderTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
        [recorderTimer fire];
        [recorder recordForDuration:180];
        [self.recordRecBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [self.recordPlayBtn setEnabled:NO];
        [self.recordAcceptBtn setEnabled:NO];
        
    }
}


- (void) updateMeters
{
	// Show the current power levels
	[recorder updateMeters];
	float avg = [recorder averagePowerForChannel:0];
	float peak = [recorder peakPowerForChannel:0];
    float progress1 = (XMAX + avg) / XMAX;
    float progress2 = (XMAX + peak) / XMAX;
    
    if (progress1 <= 0.6 ) {
        [self.recordMeter1 setProgressTintColor:[UIColor greenColor]];
    }
    else if (progress1 <= 0.8) {
        [self.recordMeter1 setProgressTintColor:[UIColor orangeColor]];
    }
    else {
        [self.recordMeter1 setProgressTintColor:[UIColor redColor]];
    }
    
    if (progress2 <= 0.6 ) {
        [self.recordMeter2 setProgressTintColor:[UIColor greenColor]];
    }
    else if (progress2 <= 0.8) {
        [self.recordMeter2 setProgressTintColor:[UIColor orangeColor]];
    }
    else {
        [self.recordMeter2 setProgressTintColor:[UIColor redColor]];
    }
	self.recordMeter1.progress = (XMAX + avg) / XMAX;
	self.recordMeter2.progress = (XMAX + peak) / XMAX;

}

- (void) updatePlayerMeters
{
	// Show the current power levels
	[recorderPlayer updateMeters];
	float avg = [recorderPlayer averagePowerForChannel:0];
	float peak = [recorderPlayer peakPowerForChannel:0];
    float progress1 = (XMAX + avg) / XMAX;
    float progress2 = (XMAX + peak) / XMAX;
    
    if (progress1 <= 0.6 ) {
        [self.recordMeter1 setProgressTintColor:[UIColor greenColor]];
    }
    else if (progress1 <= 0.8) {
        [self.recordMeter1 setProgressTintColor:[UIColor orangeColor]];
    }
    else {
        [self.recordMeter1 setProgressTintColor:[UIColor redColor]];
    }
    
    if (progress2 <= 0.6 ) {
        [self.recordMeter2 setProgressTintColor:[UIColor greenColor]];
    }
    else if (progress2 <= 0.8) {
        [self.recordMeter2 setProgressTintColor:[UIColor orangeColor]];
    }
    else {
        [self.recordMeter2 setProgressTintColor:[UIColor redColor]];
    }
	self.recordMeter1.progress = (XMAX + avg) / XMAX;
	self.recordMeter2.progress = (XMAX + peak) / XMAX;
    
}

#pragma mark - SPUserResizeableView Delegate

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
    [currentlyEditingView hideEditingHandles];
    currentlyEditingView = userResizableView;
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    switch (userResizableView.tag) {
        case 0:
            NSLog(@"%f", userResizableView.frame.origin.x);
            musicStartTime = userResizableView.frame.origin.x * 180.f / self.musicView.frame.size.width;
            musicLength = userResizableView.frame.size.width * 180.f / self.musicView.frame.size.width;
            
            break;
        case 1:
            NSLog(@"%f", userResizableView.frame.origin.x);
            effectStartTime = userResizableView.frame.origin.x * 180.f / self.musicView.frame.size.width;
            effectLength = userResizableView.frame.size.width * 180.f / self.musicView.frame.size.width;
                        break;
        case 2:
            NSLog(@"%f", userResizableView.frame.origin.x);
            voiceStartTime = userResizableView.frame.origin.x * 180.f / self.musicView.frame.size.width;
            if (!self.voiceView.frame.size.width <= 48.f) {
                voiceLength = userResizableView.frame.size.width * 180.f / self.musicView.frame.size.width;
            }
            
            break;
        default:
            break;
    }
    lastEditedView = userResizableView;
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
        return NO;
    }
    return YES;
}

- (void)hideEditingHandles {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [lastEditedView hideEditingHandles];
}

#pragma mark - Helpers
- (float) convertTimeToSec: (NSString *)time
{
    NSArray *sec = [time componentsSeparatedByString:@":"];
    float sum = [[sec objectAtIndex:0] intValue] * 60 + [[sec objectAtIndex:1] intValue];
    return sum;
}

- (float) minimumValue: (float)value1 value2:(float)value2 value3:(float)value3 {
    float min;
    
    if (!value1 && !value2 && !value3) {
        min = -1;
    }
    if (!value1) {
        min = -1;
    }
    else if (!value2 && !value3) {
        min = value1;
    }
    else if (!value2) {
        min = MIN(value1, value3);
    }
    else {
        min = MIN(value1, value2);
    }
    return min;
}


@end
