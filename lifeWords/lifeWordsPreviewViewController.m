//
//  lifeWordsPreviewViewController.m
//  lifeWords
//
//  Created by Thiên Phong on 12/23/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import "lifeWordsPreviewViewController.h"

@interface lifeWordsPreviewViewController ()

@end

@implementation lifeWordsPreviewViewController

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
    
    // Prevent the view to dim
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Set card title
    if ([self.cardTitle isEqualToString:@""]) {
        self.titleLbl.text = @"No Title";
    }
    else {
        self.titleLbl.text = self.cardTitle;
    }
    
    // Set card date
    self.cardDateLbl.text = self.cardDate;
    
    // Set card owner
    self.senderLbl.text = self.cardOwner;
    
    
    // Set the photo
    [self.corePhoto setImage:self.photo];
    
    // Set progress bar
    [self.progressBar setProgressTintColor:[UIColor greenColor]];
    
    // Start the audio session
    [self startAudioSession];
    
    // Set the variables
    if ([self.musicInfo count] > 0) {
        musicComponent = [self.musicInfo objectAtIndex:0];
        musicStartTime = [[self.musicInfo objectAtIndex:1] floatValue];
        musicLength = [[self.musicInfo objectAtIndex:2] floatValue];
    }
    
    if ([self.effectInfo count] > 0) {
        soundEffectComponent = [self.effectInfo objectAtIndex:0];
        effectStartTime = [[self.effectInfo objectAtIndex:1] floatValue];
        effectLength = [[self.effectInfo objectAtIndex:2] floatValue];
    }
    
    if ([self.voiceInfo count] > 0) {
        voiceComponent = [self.voiceInfo objectAtIndex:0];
        voiceStartTime = [[self.voiceInfo objectAtIndex:1] floatValue];
        voiceLength = [[self.voiceInfo objectAtIndex:2] floatValue];
    }
    
    // Set boolean SHOW
    show = TRUE;
    
    // Calculate play time
    music = musicStartTime + musicLength;
    effect = effectStartTime + effectLength;
    voice = voiceStartTime + voiceLength;
    
    if (MAX(music, effect) <= voice) {
        max = voice;
    }
    else {
        if (MAX(music, effect) == music) {
            max = music;
        }
        else {
            max = effect;
        }
    }
    
    // Set time label
    currentTime = -1;
    self.currentTimeLbl.text = [self formattedStringForDuration:0];
    NSString *minus = @"-";
    self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:max]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setCorePhoto:nil];
    [self setPlayMusicBtn:nil];
    [self setStopMusicBtn:nil];
    [self setProgressBar:nil];
    [self setMusicInfo:nil];
    [self setEffectInfo:nil];
    [self setVoiceInfo:nil];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    [self setTransparentView:nil];
    [self setHolderView:nil];
    [self setCurrentTimeLbl:nil];
    [self setLeftTimeLbl:nil];
    [self setCardTitle:nil];
    [self setTitleLbl:nil];
    [self setSenderLbl:nil];
    [self setCardDate:nil];
    [self setCardDateLbl:nil];
    [self setCardOwner:nil];
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

#pragma mark - Play & Stop
- (IBAction)play:(id)sender {
    
    currentTime = -1;
    
    // Set progress timer
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [progressTimer fire];
    
    stop = FALSE;
    
    // Set progress bar
    self.progressBar.progress = 0;
    
    // Start Players
    NSError *error;
    
    
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicComponent error:&error];
    [self.musicPlayer setVolume:1];
    [self.musicPlayer prepareToPlay];
    
    self.effectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundEffectComponent error:&error];
    [self.effectPlayer setVolume:0.5];
    [self.effectPlayer prepareToPlay];
    
    self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceComponent error:&error];
    [self.voicePlayer setVolume:1];
    [self.voicePlayer prepareToPlay];
    
    
    // Set timers
    musicTimer = [NSTimer scheduledTimerWithTimeInterval:musicStartTime target:self selector:@selector(playMusic) userInfo:nil repeats:NO];
    musicStopTimer = [NSTimer scheduledTimerWithTimeInterval:musicStartTime + musicLength target:self selector:@selector(stopMusic) userInfo:nil repeats:NO];
    
    effectTimer = [NSTimer scheduledTimerWithTimeInterval:effectStartTime target:self selector:@selector(playEffect) userInfo:nil repeats:NO];
    effectStopTimer = [NSTimer scheduledTimerWithTimeInterval:effectStartTime + effectLength target:self selector:@selector(stopEffect) userInfo:nil repeats:NO];
    
    voiceTimer = [NSTimer scheduledTimerWithTimeInterval:voiceStartTime target:self selector:@selector(playVoice) userInfo:nil repeats:NO];
    voiceStopTimer = [NSTimer scheduledTimerWithTimeInterval:voiceStartTime + voiceLength target:self selector:@selector(stopVoice) userInfo:nil repeats:NO];
    
    // Unhide stop button
    self.playMusicBtn.hidden = YES;
    self.stopMusicBtn.hidden = NO;
    
    
}

- (IBAction)stop:(id)sender {
    
    stop = TRUE;
    
    // Remove all timers
    [musicTimer invalidate];
    musicTimer = nil;
    [effectTimer invalidate];
    effectTimer = nil;
    [voiceTimer invalidate];
    voiceTimer = nil;
    [musicStopTimer invalidate];
    musicStopTimer = nil;
    [effectStopTimer invalidate];
    effectStopTimer = nil;
    [voiceStopTimer invalidate];
    voiceStopTimer = nil;
    [progressTimer invalidate];
    progressTimer = nil;
    
    // Stop all players
    [self.musicPlayer stopWithFadeDuration:1];
    [self.effectPlayer stopWithFadeDuration:1];
    [self.voicePlayer stopWithFadeDuration:1];
    
    // Set play & stop btn
    self.playMusicBtn.hidden = NO;
    self.stopMusicBtn.hidden = YES;
    
}

- (IBAction)hideMenu:(id)sender {
    if (show == TRUE) {
        [self fadeOut:self.transparentView withDuration:0.3f andWait:0];
        [self fadeOut:self.holderView withDuration:0.3f andWait:0];
        show = FALSE;
    }
    else {
        [self fadeIn:self.transparentView withDuration:0.3f andAlpha:0.5 andWait:0];
        [self fadeIn:self.holderView withDuration:0.3f andAlpha:1 andWait:0];
        show = TRUE;
    }
}

- (IBAction)dismiss:(id)sender {
    [self stop:nil];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    [self dismissModalViewControllerAnimated:YES];
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
    [self.voicePlayer stopWithFadeDuration:3];
    [voiceStopTimer invalidate];
    voiceStopTimer = nil;
}

- (void) updateProgressBar {
    if ((int)currentTime < (int)max) {
        currentTime += 1;
        self.currentTimeLbl.text = [self formattedStringForDuration:currentTime];
        NSString *minus = @"-";
        self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:max-currentTime]];
        self.progressBar.progress = currentTime/max;
    }
    else {
        self.currentTimeLbl.text = [self formattedStringForDuration:max];
        NSString *minus = @"-";
        self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:0]];
        [self stop:nil];
        self.progressBar.progress = 1;
    }
    
}

#pragma mark - Helpers
-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration   andWait:(NSTimeInterval)wait
{
    [UIView animateWithDuration:duration delay:wait options:UIViewAnimationOptionCurveLinear animations:^{
        viewToDissolve.alpha = 0;
    } completion:nil];
}

-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration  andAlpha:(float)alpha      andWait:(NSTimeInterval)wait
{
    [UIView animateWithDuration:duration delay:wait options:UIViewAnimationOptionCurveLinear animations:^{
        viewToFadeIn.alpha = alpha;
    } completion:nil];
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration
{
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

@end