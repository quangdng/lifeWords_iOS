//
//  lifeWords3DViewController.m
//  lifeWords
//
//  Created by Thiên Phong on 1/3/13.
//  Copyright (c) 2013 simpleDudes. All rights reserved.
//

#import "lifeWords3DViewController.h"


@interface lifeWords3DViewController ()

@end

@implementation lifeWords3DViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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


- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    // Prevent the view to dim
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Start the audio session
    [self startAudioSession];
    
    
    //Basic setup
    self.pepperViewController = [[PPPepperViewController alloc] init];
    self.pepperViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.pepperViewController.view];
    
    //iOS5
    self.iOS5AndAbove = ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending);
    if (self.iOS5AndAbove) {
        [self addChildViewController:self.pepperViewController];
        [self.pepperViewController didMoveToParentViewController:self];
    }
    
    // Customizations
    self.pepperViewController.dataSource = self;
    //self.pepperViewController.enableBookShadow = YES;
    //self.pepperViewController.enableBorderlessGraphic = YES;
    //self.pepperViewController.enablePageCurlEffect = YES;
    //self.pepperViewController.enablePageFlipEffect = YES;
    self.pepperViewController.delegate = self;
    //Initialize data
    
    familyArray = [[NSMutableArray alloc] init];
    friendsArray = [[NSMutableArray alloc] init];
    loveArray = [[NSMutableArray alloc] init];
    
    for (NSArray *card in self.cards) {
        if ([[card lastObject] isEqualToString:@"Family"]) {
            [familyArray addObject:card];
        }
        else if ([[card lastObject] isEqualToString:@"Friends"]) {
            [friendsArray addObject:card];
        }
        else {
            [loveArray addObject:card];
        }
    }
    
    numberOfBooks = 0;
    bookArray = [[NSMutableArray alloc] init];
    
    if ([familyArray count] >0) {
        numberOfBooks += 1;
        [bookArray addObject:familyArray];
    }
    
    if ([friendsArray count] >0) {
        numberOfBooks += 1;
        [bookArray addObject:friendsArray];
    }
    
    
    if ([loveArray count] > 0) {
        numberOfBooks += 1;
        [bookArray addObject:loveArray];
    }
    
    NSLog (@"Number of book %d", [bookArray count]);
    [self initializeBookData];
    [self.view bringSubviewToFront:self.operationBar];
    [self.view bringSubviewToFront:self.transparentView];
    [self.view bringSubviewToFront:self.holderView];
    [self.view bringSubviewToFront:self.dismissBtn];
    
    [self.pepperViewController reload];
    
    // Set progress bar
    [self.progressBar setProgressTintColor:[UIColor greenColor]];
    
    // Set hide transparent view and holder view
    [self.transparentView setHidden:YES];
    [self.holderView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data

- (void)initializeBookData
{
    //You can supply your own data model
    //For demo purpose, a very basic Book & Page model is supplied
    //and they are being initialized with random data here
    
    self.bookDataArray = [[NSMutableArray alloc] init];
    for (NSArray* book in bookArray) {
        int i = 0;
        if (book == familyArray) {
            [self addBookIndex:i withBookName:@"Family" withPages:familyArray];
        }
        else if (book == friendsArray) {
            [self addBookIndex:i withBookName:@"Friends" withPages:friendsArray];
        }
        else {
            [self addBookIndex:i withBookName:@"Love" withPages:loveArray];
        }
        i++;
    }
}

- (void)addBookIndex:(int)bookIndex withBookName:(NSString *)bookName withPages:(NSArray *)pagesArray
{
    
    Book *myBook = [[Book alloc] init];
    myBook.bookID = bookIndex;
    myBook.pages = [[NSMutableArray alloc] init];
    myBook.bookName = bookName;
    
    int loopTimes = 2;
    
    
    for (int j=0; j<loopTimes; j++) {
        if (bookName == @"Family" && j == 0) {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"family.png";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
        else if (bookName == @"Friends" && j == 0) {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"friends.png";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
    
        else if (j == 0 && bookName == @"Love") {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"love.png";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
        else {
            for (NSArray *card in pagesArray) {
                NSLog(@"%d", [pagesArray count]);
                Page *myPage = [[Page alloc] init];
                myPage.halfsizeURL = [card objectAtIndex:1];
                myPage.cardData = card;
                NSLog(@"%@", [card objectAtIndex:0]);
                myPage.fullsizeURL = myPage.halfsizeURL;
                [myBook.pages addObject:myPage];
            }
            
        }
        
    }
    
    [self.bookDataArray addObject:myBook];
}

#pragma mark - PPScrollListViewControllerDataSource

- (int)ppPepperViewController:(PPPepperViewController*)scrollList numberOfBooks:(int)dummy;
{
    return self.bookDataArray.count;
}

- (int)ppPepperViewController:(PPPepperViewController*)scrollList numberOfPagesForBookIndex:(int)bookIndex
{
    if (bookIndex < 0 || bookIndex >= self.bookDataArray.count)
        return 0;
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    return theBook.pages.count;
}

- (int)ppPepperViewController:(PPPepperViewController*)scrollList numberOfDetailPagesForBookIndex:(int)bookIndex
{
    if (bookIndex < 0 || bookIndex >= self.bookDataArray.count)
        return 0;
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    return theBook.pages.count;
}

- (UIView*)ppPepperViewController:(PPPepperViewController*)scrollList viewForBookIndex:(int)bookIndex withFrame:(CGRect)frame reusableView:(UIView*)contentView
{
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    
    MyBookOrPageView *view = nil;
    if (contentView == nil || ![contentView isKindOfClass:[MyBookOrPageView class]])
        view = [[MyBookOrPageView alloc] initWithFrame:frame];
    else
        view = (MyBookOrPageView*)contentView;
    
    [view configureWithBookModel:theBook];
    return view;
}

- (UIView*)ppPepperViewController:(PPPepperViewController*)scrollList thumbnailViewForPageIndex:(int)pageIndex inBookIndex:(int)bookIndex withFrame:(CGRect)frame reusableView:(UIView*)contentView
{
    //Return nil for the last page if number of actual page data is odd
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    int numPages = [theBook.pages count];
    if (pageIndex >= numPages)
        return nil;
    
    Page *thePage = [theBook.pages objectAtIndex:pageIndex];
    
    MyBookOrPageView *view = nil;
    if (contentView == nil || ![contentView isKindOfClass:[MyBookOrPageView class]])
        view = [[MyBookOrPageView alloc] initWithFrame:frame];
    else
        view = (MyBookOrPageView*)contentView;
    
    [view configureWithPageModel:thePage];
    return view;
}

- (UIView*)ppPepperViewController:(PPPepperViewController*)scrollList detailViewForPageIndex:(int)pageIndex inBookIndex:(int)bookIndex withFrame:(CGRect)frame reusableView:(UIView*)contentView
{
    //Return nil for the last page if number of actual page data is odd
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    int numPages = [theBook.pages count];
    if (pageIndex >= numPages)
        return nil;
    
    Page *thePage = [theBook.pages objectAtIndex:pageIndex];
    
    MyPageViewDetail *view = nil;
    if (contentView == nil || ![contentView isKindOfClass:[MyPageViewDetail class]])
        view = [[MyPageViewDetail alloc] initWithFrame:frame];
    else
        view = (MyPageViewDetail*)contentView;
    
    [view configureWithPageModel:thePage];
    return view;
}

#pragma mark -
#pragma mark - PPScrollListViewControllerDelegate

/*
 * This is called when the book list is being scrolled
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didScrollWithBookIndex:(float)bookIndex
{
    //Commented out for performance reason
    //NSLog(@"%@", [NSString stringWithFormat:@"didScrollWithBookIndex:%.2f", bookIndex]);
    
    //Built-in demo content
    if (self.pepperViewController.dataSource != self)
        return;
}

/*
 * This is called after the fullscreen list has finish snapping to a page
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didSnapToBookIndex:(int)bookIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didSnapToBookIndex:%d", bookIndex]);
    
    
    
}

/*
 * This is called when a book is tapped on
 * The book will open automatically by the library if AUTO_OPEN_BOOK is enabled (default)
 * Otherwise you need to call [pepperViewController openCurrentBookAtPageIndex:0]; yourself
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didTapOnBookIndex:(int)bookIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didTapOnBookIndex:%d", bookIndex]);
    
    //You can implement your own logic here to prompt user to login before viewinh this content if needed
    //You can implement your own logic here to get remembered last opened page for this book
    
    
    int pageIndex = 0;
    
    //This is mandatory in version 1.3.0 and above
    [scrollList openCurrentBookAtPageIndex:pageIndex];
}

/*
 * This is called just before & after the book opens & closes
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList willOpenBookIndex:(int)bookIndex andDuration:(float)duration
{
    NSLog(@"%@", [NSString stringWithFormat:@"willOpenBookIndex:%d duration:%.2f", bookIndex, duration]);
    
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didOpenBookIndex:(int)bookIndex atPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didOpenBookIndex:%d atPageIndex:%d", bookIndex, pageIndex]);
    self.closeBtn.hidden = YES;
    self.operationBar.hidden = YES;
    
    // Set current card
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    currentBook = theBook;
    
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didCloseBookIndex:(int)bookIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didCloseBookIndex:%d", bookIndex]);
    self.operationBar.hidden = NO;
    self.closeBtn.hidden = NO;
    
}

/*
 * When the book is being closed, the library will calculate the necessary alpha value to reveal the initial menu bar
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList closingBookWithAlpha:(float)alpha
{
    //Commented out for performance reason
    //NSLog(@"%@", [NSString stringWithFormat:@"closingBookWithAlpha:%.2f", alpha]);
    
}

/*
 * This is called when the empty space is tapped while in 3D/Pepper mode
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didTapOnEmptySpaceInPepperView:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didTapOnEmptySpaceInPepperView:%d", pageIndex]);
    
    //Close current book
    [self.pepperViewController closeCurrentBook:YES];
}

/*
 * This is called when a page is tapped on
 * The book will open automatically by the library if AUTO_OPEN_PAGE is enabled (default)
 * Otherwise you need to call [pepperViewController openPageIndex:xxx]; yourself
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didTapOnPageIndex:(int)pageIndex
{
    //This is mandatory in version 1.3.0 and above
    [scrollList openPageIndex:pageIndex];
    
    
    
    NSLog(@"%@", [NSString stringWithFormat:@"didTapOnPageIndex:%d", pageIndex]);
}

/*
 * This is called when a fullscreen page is tapped
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didTapOnFullscreenPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didTapOnFullscreenPageIndex:%d", pageIndex]);
}

/*
 * This is called when the 3D view is being flipped
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didFlippedWithIndex:(float)index
{
    //Commented out for performance reason
    //NSLog(@"%@", [NSString stringWithFormat:@"didFlippedWithIndex:%.2f", index]);
    
    //Built-in demo content
    if (self.pepperViewController.dataSource != self)
        return;
    }

/*
 * This is called after the flipping finish snapping to a page
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didFinishFlippingWithIndex:(float)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didFinishFlippingWithIndex:%.2f", pageIndex]);
    
    //Built-in demo content
    if (self.pepperViewController.dataSource != self)
        return;
    
    //Infinite numage of pages
    //It's better to be implemented here, but fast scrolling is causing problem
    //[self loadMorePageForBookIndex:[self.pepperViewController getCurrentBookIndex] currentPageIndex:pageIndex];
}

/*
 * This is called when the fullscreen list is being scrolled
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didScrollWithPageIndex:(float)pageIndex
{
    //Commented out for performance reason
    //NSLog(@"%@", [NSString stringWithFormat:@"didScrollWithPageIndex:%.2f", pageIndex]);
}

/*
 * This is called after the fullscreen list has finish snapping to a page
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didSnapToPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didSnapToPageIndex:%d", pageIndex]);
    
    currentCard = ((Page*)[currentBook.pages objectAtIndex:pageIndex]).cardData;
    
    // Set date, title
    if ([[currentCard objectAtIndex:0] isEqualToString:@""]) {
        self.titleLbl.text = @"No Title";
    }
    else {
        self.titleLbl.text = [currentCard objectAtIndex:0];
    }
    
    self.cardDateLbl.text = [currentCard objectAtIndex:2];
    
    NSArray *musicInfo = nil;
    NSArray *effectInfo = nil;
    NSArray *voiceInfo = nil;
    
    NSArray *musicArray = [currentCard objectAtIndex:3];
    if ([musicArray count] > 0) {
        musicComponent = [[NSBundle mainBundle] URLForResource:[musicArray objectAtIndex:0] withExtension:@"mp3"];
        musicInfo = [[NSArray alloc] initWithObjects:musicComponent, [musicArray objectAtIndex:1], [musicArray objectAtIndex:2], nil];
    }
    
    NSArray *effectArray = [currentCard objectAtIndex:4];
    if ([effectArray count] > 0) {
        soundEffectComponent = [[NSBundle mainBundle] URLForResource:[effectArray objectAtIndex:0] withExtension:@"mp3"];
        effectInfo = [[NSArray alloc] initWithObjects:soundEffectComponent, [effectArray objectAtIndex:1], [effectArray objectAtIndex:2], nil];
    }
    
    
    NSArray *voiceArray = [currentCard objectAtIndex:5];
    if ([voiceArray count] > 0) {
        voiceComponent = [[NSURL alloc] initFileURLWithPath:[voiceArray objectAtIndex:0]];
        voiceInfo = [[NSArray alloc] initWithObjects:voiceComponent, [voiceArray objectAtIndex:1], [voiceArray objectAtIndex:2], nil];
    }
    
    
    
    // Set the variables
    if ([musicInfo count] > 0) {
        musicComponent = [musicInfo objectAtIndex:0];
        musicStartTime = [[musicInfo objectAtIndex:1] floatValue];
        musicLength = [[musicInfo objectAtIndex:2] floatValue];
    }
    
    if ([effectInfo count] > 0) {
        soundEffectComponent = [effectInfo objectAtIndex:0];
        effectStartTime = [[effectInfo objectAtIndex:1] floatValue];
        effectLength = [[effectInfo objectAtIndex:2] floatValue];
    }
    
    if ([voiceInfo count] > 0) {
        voiceComponent = [voiceInfo objectAtIndex:0];
        voiceStartTime = [[voiceInfo objectAtIndex:1] floatValue];
        voiceLength = [[voiceInfo objectAtIndex:2] floatValue];
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
    
    self.currentTimeLbl.text = [self formattedStringForDuration:0];
    NSString *minus = @"-";
    self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:max]];
    
    // Unhide View
    [self.transparentView setHidden:NO];
    [self.holderView setHidden:NO];
    [self.dismissBtn setHidden:NO];
 
}

/*
 * This is called during & after a fullscreen page is zoom
 */
- (void)ppPepperViewController:(PPPepperViewController*)scrollList didZoomWithPageIndex:(int)pageIndex zoomScale:(float)zoomScale
{
    //Commented out for performance reason
    //NSLog(@"%@", [NSString stringWithFormat:@"didZoomWithPageIndex:%d zoomScale:%.2f", pageIndex, zoomScale]);
    
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didEndZoomingWithPageIndex:(int)pageIndex zoomScale:(float)zoomScale
{
    NSLog(@"%@", [NSString stringWithFormat:@"didEndZoomingWithPageIndex:%d zoomScale:%.2f", pageIndex, zoomScale]);
    [self.transparentView setHidden:NO];
    [self.holderView setHidden:NO];
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList willOpenPageIndex:(int)pageIndex
{
    
    
    NSLog(@"%@", [NSString stringWithFormat:@"willOpenPageIndex:%d", pageIndex]);
    

    
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didOpenPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didOpenPageIndex:%d", pageIndex]);
    
    currentCard = ((Page*)[currentBook.pages objectAtIndex:pageIndex]).cardData;
    
    // Set date, title
    if ([[currentCard objectAtIndex:0] isEqualToString:@""]) {
        self.titleLbl.text = @"No Title";
    }
    else {
        self.titleLbl.text = [currentCard objectAtIndex:0];
    }
    
    self.cardDateLbl.text = [currentCard objectAtIndex:2];
    
    NSArray *musicInfo = nil;
    NSArray *effectInfo = nil;
    NSArray *voiceInfo = nil;
    
    NSArray *musicArray = [currentCard objectAtIndex:3];
    if ([musicArray count] > 0) {
        musicComponent = [[NSBundle mainBundle] URLForResource:[musicArray objectAtIndex:0] withExtension:@"mp3"];
        musicInfo = [[NSArray alloc] initWithObjects:musicComponent, [musicArray objectAtIndex:1], [musicArray objectAtIndex:2], nil];
    }
    
    NSArray *effectArray = [currentCard objectAtIndex:4];
    if ([effectArray count] > 0) {
        soundEffectComponent = [[NSBundle mainBundle] URLForResource:[effectArray objectAtIndex:0] withExtension:@"mp3"];
        effectInfo = [[NSArray alloc] initWithObjects:soundEffectComponent, [effectArray objectAtIndex:1], [effectArray objectAtIndex:2], nil];
    }
    
    
    NSArray *voiceArray = [currentCard objectAtIndex:5];
    if ([voiceArray count] > 0) {
        voiceComponent = [[NSURL alloc] initFileURLWithPath:[voiceArray objectAtIndex:0]];
        voiceInfo = [[NSArray alloc] initWithObjects:voiceComponent, [voiceArray objectAtIndex:1], [voiceArray objectAtIndex:2], nil];
    }
    
    
    
    // Set the variables
    if ([musicInfo count] > 0) {
        musicComponent = [musicInfo objectAtIndex:0];
        musicStartTime = [[musicInfo objectAtIndex:1] floatValue];
        musicLength = [[musicInfo objectAtIndex:2] floatValue];
    }
    
    if ([effectInfo count] > 0) {
        soundEffectComponent = [effectInfo objectAtIndex:0];
        effectStartTime = [[effectInfo objectAtIndex:1] floatValue];
        effectLength = [[effectInfo objectAtIndex:2] floatValue];
    }
    
    if ([voiceInfo count] > 0) {
        voiceComponent = [voiceInfo objectAtIndex:0];
        voiceStartTime = [[voiceInfo objectAtIndex:1] floatValue];
        voiceLength = [[voiceInfo objectAtIndex:2] floatValue];
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
    
    self.currentTimeLbl.text = [self formattedStringForDuration:0];
    NSString *minus = @"-";
    self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:max]];
    
    // Unhide View
    [self.transparentView setHidden:NO];
    [self.holderView setHidden:NO];
    [self.dismissBtn setHidden:NO];
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didClosePageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didClosePageIndex:%d", pageIndex]);
    
    [self.transparentView setHidden:YES];
    [self.holderView setHidden:YES];
    [self.dismissBtn setHidden:YES];
    [self stop:nil];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    [self.closeBtn setHidden:NO];
}
- (void)viewDidUnload {
    
    [self setHolderView:nil];
    [self setTransparentView:nil];
    [self setCloseBtn:nil];
    [self setDismissBtn:nil];
    [super viewDidUnload];
    [self setMusicPlayer:nil];
    [self setEffectPlayer:nil];
    [self setVoicePlayer:nil];
    [self setBookDataArray:nil];
    [self setCards:nil];
    [self setOperationBar:nil];
    [self setBookName:nil];
    [self setWallpaper:nil];
    [self setCloseBtn:nil];
    [self setPlayMusicBtn:nil];
    [self setStopMusicBtn:nil];
    [self setProgressBar:nil];
    [self setCurrentTimeLbl:nil];
    [self setLeftTimeLbl:nil];
    [self setTitleLbl:nil];
    [self setCardDateLbl:nil];
}
- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Audio Players

- (IBAction)play:(id)sender {
    
    
    // Set time label
    currentTime = -1;
    self.currentTimeLbl.text = [self formattedStringForDuration:0];
    NSString *minus = @"-";
    self.leftTimeLbl.text = [minus stringByAppendingString:[self formattedStringForDuration:max]];
    
    currentTime = -1;
    
    // Set progress timer
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [progressTimer fire];
    
    
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

- (IBAction)hideMenu:(id)sender {
    if (show == TRUE) {
        [self.dismissBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        [self fadeOut:self.transparentView withDuration:0.3f andWait:0];
        [self fadeOut:self.holderView withDuration:0.3f andWait:0];
        show = FALSE;
    }
    else {
        [self.dismissBtn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
        [self fadeIn:self.transparentView withDuration:0.3f andAlpha:0.5 andWait:0];
        [self fadeIn:self.holderView withDuration:0.3f andAlpha:1 andWait:0];
        show = TRUE;
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
