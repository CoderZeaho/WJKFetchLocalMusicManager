//
//  WJKFetchLocalMusicManager.h
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "WJKLocalMusicModel.h"

@interface WJKFetchLocalMusicManager : NSObject

+ (WJKFetchLocalMusicManager *)shareFetchLocalMusicManager;

- (void)fetchLocalMusicFromiPod:(void (^)(NSMutableArray *musicArray, NSError *error))completion;

@end
