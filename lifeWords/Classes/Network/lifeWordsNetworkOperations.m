//
//  lifeWordsNetworkOperations.m
//  lifeWords
//
//  Created by JustaLiar on 10/10/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import "lifeWordsNetworkOperations.h"

@implementation lifeWordsNetworkOperations
- (JUSSNetworkOperation *) basicAuthentication:(NSString *)userEmail andUserPassword:(NSString *)userPassword
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userEmail forKey:@"useremail"];
    [params setObject:userPassword forKey:@"password"];
    
    JUSSNetworkOperation *op = [self operationWithPath:@"auth.php" params:params httpMethod:@"POST"];
    
    [self enqueueOperation:op];
    
    return op;
}

- (JUSSNetworkOperation *) fetchUserInfo:(NSString *)userEmail
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userEmail forKey:@"useremail"];
    JUSSNetworkOperation *op = [self operationWithPath:@"fetchUserInfo.php" params:params httpMethod:@"POST"];
    [self enqueueOperation:op];
    return op;
}

- (JUSSNetworkOperation *) fetchNotifications:(NSString *)userID
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userID forKey:@"userid"];
    JUSSNetworkOperation *op = [self operationWithPath:@"fetchNotifications.php" params:params httpMethod:@"POST"];
    [self enqueueOperation:op];
    return op;
}

- (JUSSNetworkOperation *) shareCard: (NSArray *)aCard byUser:(NSString *)email withUsers:(NSString *)users withPhoto:(NSData *) photo withVoice:(NSData *) voice withLength:(NSString *)length
{
    
    NSString *cardTitle = [aCard objectAtIndex:0];

    NSString *cardDate = [aCard objectAtIndex:2];
   
    NSArray *musicInfo = [aCard objectAtIndex:3];
    NSArray *effectInfo = [aCard objectAtIndex:4];
    NSArray *voiceInfo = [aCard objectAtIndex:5];
    
    NSString *musicString = nil;
    NSString *musicS = nil;
    NSString *musicL = nil;
    if ([musicInfo count] > 0) {
        musicString = [musicInfo objectAtIndex:0];
        musicS = [[musicInfo objectAtIndex:1] stringValue];
        musicL = [[musicInfo objectAtIndex:2] stringValue];
    }
    
    NSString *effectString = nil;
    NSString * effectS = nil;
    NSString * effectL = nil;
    if ([effectInfo count] > 0) {
        effectString = [effectInfo objectAtIndex:0];
        effectS = [[effectInfo objectAtIndex:1] stringValue];
        effectL = [[effectInfo objectAtIndex:2] stringValue];
    }
    
    NSString *voiceString = nil;
    NSString *voiceS = nil;
    NSString *voiceL = nil;
    if ([voiceInfo count] > 0) {
        voiceString = [voiceInfo objectAtIndex:0];
        voiceS = [[voiceInfo objectAtIndex:1] stringValue];
        voiceL = [[voiceInfo objectAtIndex:2] stringValue];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (cardTitle) {
        [params setObject:cardTitle forKey:@"Card_Text"];
    }
    
    if (musicString) {
        [params setObject:musicString  forKey:@"Card_Music"];
    }
    
    if (musicS) {
        [params setObject:musicS forKey:@"Card_Music_StartTime"];
    }
    
    if (musicL) {
        [params setObject:musicL forKey:@"Card_Music_Length"];
    }
    
    if (effectString) {
        [params setObject:effectString forKey:@"Card_Effect"];
    }
    
    if (effectS) {
        [params setObject:effectS forKey:@"Card_Effect_StartTime"];
    }
    
    if (effectL) {
        [params setObject:effectL forKey:@"Card_Effect_Length"];
    }
    
    if (voiceString) {
        [params setObject:voiceString forKey:@"Card_Voice"];
    }
    
    if (voiceS) {
        [params setObject:voiceS forKey:@"Card_Voice_StartTime"];
    }
    
    if (voiceL) {
        [params setObject:voiceL forKey:@"Card_Voice_Length"];
    }
    
    
    
    [params setObject:cardDate forKey:@"Card_Date"];
    
    [params setObject:length forKey:@"Card_Length"];
    NSLog(@"My length %@", length);
    
    [params setObject:users forKey:@"users"];
    
    [params setObject:email forKey:@"useremail"];
    
    
    
    JUSSNetworkOperation *op = [self operationWithPath:@"shareCard.php" params:params httpMethod:@"POST"];
    
    if (photo != nil) {
        [op addData:photo forKey:@"photo" mimeType:@"image/jpeg" fileName:@"card_photo.jpg"];
    }
    
    if (voice) {
        [op addData:voice forKey:@"voice" mimeType:@"" fileName:@"voice.wav"];
    }
    
    [self enqueueOperation:op];
    return op;
}

- (JUSSNetworkOperation *) signUp: (NSString *)email andPassword: (NSString *)password andNickname: (NSString*)nickname withProfilePhoto:(NSData *) photo
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:email forKey:@"email"];
    [params setObject:password forKey:@"password"];
    [params setObject:nickname forKey:@"nickname"];
    
    JUSSNetworkOperation *op = [self operationWithPath:@"signup.php" params:params httpMethod:@"POST"];
    
    if (photo != nil) {
        [op addData:photo forKey:@"upload_file" mimeType:@"image/jpeg" fileName:@"user_profile_photo.jpg"];
    }
    
    
    
    [self enqueueOperation:op];
    
    return op;
}

- (JUSSNetworkOperation *) downloadFile:(NSString *)remoteURL toFile:(NSString *)filePath
{
    JUSSNetworkOperation *op = [self operationWithURLString:remoteURL
                                                   params:nil
                                               httpMethod:@"GET"];
    
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:YES]];
    [self enqueueOperation:op];
    return op;
}

@end
