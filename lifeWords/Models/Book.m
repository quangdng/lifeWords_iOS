
#import "Book.h"

@implementation Book

@synthesize bookID;
@synthesize coverURL;
@synthesize totalPages;
@synthesize pages;
@synthesize bookName;

- (int)getTotalPages {
  return [self.pages count];
}

- (NSString *) getBookName {
    return self.bookName;
}

@end
