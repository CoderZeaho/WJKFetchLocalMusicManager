//
//  WJKFetchLocalMusicManager.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "WJKFetchLocalMusicManager.h"

static WJKFetchLocalMusicManager *shareFetchMusicManager = nil;

@interface WJKFetchLocalMusicManager ()

@property (nonatomic, strong) AVAssetExportSession *exportSessionMusic;

@end

@implementation WJKFetchLocalMusicManager

+ (WJKFetchLocalMusicManager *)shareFetchLocalMusicManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareFetchMusicManager = [[WJKFetchLocalMusicManager alloc] init];
    });
    return shareFetchMusicManager;
}

/**
 读取音乐文件

 @param completion 包含所有音乐信息的数组
 */
- (void)fetchLocalMusicFromiPod:(void (^)(NSMutableArray *musicArray, NSError *error))completion{
    __block NSMutableArray *musicItemsArray = [NSMutableArray array];
    __block NSError *error = nil;
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeAnyAudio) forProperty:MPMediaItemPropertyMediaType];
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates:nil];
    [mediaQuery addFilterPredicate:predicate];
    
    NSArray *items = [mediaQuery items];
    for (int i = 0; i < [items count]; i++) {
        // 初始化音乐信息
        WJKLocalMusicModel *musicItem = [[WJKLocalMusicModel alloc] initWithMPMediaItem:items[i]];
        // 由于苹果对音乐版权的保护,无法读取购买的音乐,只能读取由iTunes导入的音乐
        if (musicItem.assetUrl != nil) {
            [musicItemsArray addObject:musicItem];
        }
    }
    if (completion) {
        completion(musicItemsArray, error);
    }
}

@end
