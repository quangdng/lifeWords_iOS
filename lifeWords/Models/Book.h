//
// Book.h
//
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, assign) int bookID;
@property (nonatomic, strong) NSString * coverURL;
@property (nonatomic, strong) NSString * bookName;
@property (nonatomic, retain) NSMutableArray * pages;
@property (nonatomic, assign, readonly) int totalPages;

@end

