
#import "Book.h"

@implementation Book

- (int)getTotalPages {
  return [self.pages count];
}

- (NSString *) getBookName {
    return self.bookName;
}

@end
