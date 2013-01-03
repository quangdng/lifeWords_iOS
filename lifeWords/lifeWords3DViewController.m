//
//  lifeWords3DViewController.m
//  lifeWords
//
//  Created by Thiên Phong on 1/3/13.
//  Copyright (c) 2013 simpleDudes. All rights reserved.
//

#import "lifeWords3DViewController.h"
#import "MyBookOrPageView.h"
#import "MyPageViewDetail.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
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
    
    Book *theBook = [self.bookDataArray objectAtIndex:0];
    self.bookName.text = theBook.bookName;
    [self.pepperViewController reload];
    
    
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
    
    int numberOfPages = [pagesArray count];
    
    if (!((numberOfPages % 2) == 0)) {
        numberOfPages += 1;
    }
    
    NSLog(@"Number of Pages %d", numberOfPages);
    
    for (int j=0; j<numberOfPages; j++) {
        if (bookName == @"Family" && j == 0) {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"family.jpg";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
        else if (bookName == @"Friends" && j == 0) {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"friends.jpg";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
    
        else if (j == 0 && bookName == @"Love") {
            Page *myPage = [[Page alloc] init];
            myPage.halfsizeURL = @"love.jpg";
            myPage.fullsizeURL = myPage.halfsizeURL;
            [myBook.pages addObject:myPage];
        }
        else {
            for (NSArray *card in pagesArray) {
                Page *myPage = [[Page alloc] init];
                myPage.halfsizeURL = [card objectAtIndex:1];
                NSLog(@"%@", [card objectAtIndex:1]);
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
    
    Book *theBook = [self.bookDataArray objectAtIndex:bookIndex];
    self.bookName.text = theBook.bookName;
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
    self.bookName.hidden = YES;
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
    self.bookName.hidden = YES;
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didCloseBookIndex:(int)bookIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didCloseBookIndex:%d", bookIndex]);
    self.bookName.hidden = NO;
    
    
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
    
    //Built-in demo content
    if (self.pepperViewController.dataSource != self)
        return;
 
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
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList willOpenPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"willOpenPageIndex:%d", pageIndex]);
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didOpenPageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didOpenPageIndex:%d", pageIndex]);
}

- (void)ppPepperViewController:(PPPepperViewController*)scrollList didClosePageIndex:(int)pageIndex
{
    NSLog(@"%@", [NSString stringWithFormat:@"didClosePageIndex:%d", pageIndex]);
}
- (void)viewDidUnload {
    [self setOperationBar:nil];
    [self setBookName:nil];
    [self setWallpaper:nil];
    [self setCloseBtn:nil];
    [super viewDidUnload];
}
- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
