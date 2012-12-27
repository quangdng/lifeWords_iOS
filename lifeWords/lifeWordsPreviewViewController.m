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
    
    // Set the photo
    [self.corePhoto setImage:self.photo];
    
    // Set progress bar
    [self.progressBar setProgressTintColor:[UIColor greenColor]];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCorePhoto:nil];
    [self setPlayMusicBtn:nil];
    [self setStopMusicBtn:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
}

#pragma mark - Play & Stop
- (IBAction)play:(id)sender {
    
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
    
    // Set progress timer
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
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [progressTimer fire];
}

- (IBAction)stop:(id)sender {
    
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

    // Stop all players
    [self.musicPlayer stopWithFadeDuration:1];
    [self.effectPlayer stopWithFadeDuration:1];
    [self.voicePlayer stopWithFadeDuration:1];
    
    // Set play & stop btn
    self.playMusicBtn.hidden = NO;
    self.stopMusicBtn.hidden = YES;

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
    if (MAX(music, effect) <= voice) {
        if ((self.voicePlayer.currentTime / max) < 1) {
            self.progressBar.progress = self.voicePlayer.currentTime / max;
        }
        else {
            [progressTimer invalidate];
            progressTimer = nil;
            self.progressBar.progress = 1;
            self.stopMusicBtn.hidden = YES;
            self.playMusicBtn.hidden = NO;
        }
    }
    else {
        if (MAX(music, effect) == music) {
            if ((self.musicPlayer.currentTime / max) < 1) {
                self.progressBar.progress = self.musicPlayer.currentTime / max;
            }
            else {
                [progressTimer invalidate];
                progressTimer = nil;
                self.progressBar.progress = 1;
                self.stopMusicBtn.hidden = YES;
                self.playMusicBtn.hidden = NO;
            }
        }
        else {
            if ((self.effectPlayer.currentTime / max) < 1) {
                self.progressBar.progress = self.effectPlayer.currentTime / max;
            }
            else {
                [progressTimer invalidate];
                progressTimer = nil;
                self.progressBar.progress = 1;
                self.stopMusicBtn.hidden = YES;
                self.playMusicBtn.hidden = NO;
            }
        }
    }    
}
@end
