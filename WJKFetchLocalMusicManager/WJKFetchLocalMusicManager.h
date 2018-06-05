//
//  WJKFetchLocalMusicManager.h
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define WJKFetchLocalMusicErrorDomain @"WJKFetchLocalMusicErrorDomain"

#define WJKUnknownError @"WJKUnknownError"
#define WJKFileExistsError @"WJKFileExistsError"

#define kWJKUnknownError -65536
#define kWJKFileExistsError -48

@interface WJKFetchLocalMusicManager : NSObject

+ (WJKFetchLocalMusicManager *)shareFetchLocalMusicManager;

- (void)fetchLocalMusicFromiPod:(void (^)(NSMutableArray *musicArray, NSError *error))completion;

- (void)importLocalMusicFromiPod:(NSURL *)musicURL importURL:(NSURL *)importURL completion:(void (^)(void))completion;

@end
