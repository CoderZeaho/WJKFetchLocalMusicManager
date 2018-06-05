//
//  WJKFetchLocalMusicManager.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "WJKFetchLocalMusicManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WJKLocalMusicModel.h"

static WJKFetchLocalMusicManager *shareFetchMusicManager = nil;

@interface WJKFetchLocalMusicManager ()

@property (strong, nonatomic) AVAssetExportSession *exportSession;

@property (strong, nonatomic) NSError *error;

@property (assign, nonatomic) AVAssetExportSessionStatus status;

@property (assign, nonatomic) float progress;

@end

@implementation WJKFetchLocalMusicManager {
    NSError *movieFileError;
}

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
    __block NSMutableArray *musicArray = [NSMutableArray array];
    __block NSError *error = nil;
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeAnyAudio) forProperty:MPMediaItemPropertyMediaType];
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates:nil];
    [mediaQuery addFilterPredicate:predicate];
    
    NSArray *items = [mediaQuery items];
    for (int i = 0; i < [items count]; i++) {
        // 初始化音乐信息
        WJKLocalMusicModel *music = [[WJKLocalMusicModel alloc] initWithMPMediaItem:items[i]];
        // 由于苹果对音乐版权的保护,无法读取购买的音乐,只能读取由iTunes导入的音乐
        if (music.assetUrl != nil) {
            [musicArray addObject:music];
        }
    }
    if (completion) {
        completion(musicArray, error);
    }
}

+ (BOOL)validIpodLibraryURL:(NSURL*)url {
    NSString *IPOD_SCHEME = @"ipod-library";
    if (nil == url) return NO;
    if (nil == url.scheme) return NO;
    if ([url.scheme compare:IPOD_SCHEME] != NSOrderedSame) return NO;
    if ([url.pathExtension compare:@"mp3"] != NSOrderedSame &&
        [url.pathExtension compare:@"aif"] != NSOrderedSame &&
        [url.pathExtension compare:@"m4a"] != NSOrderedSame &&
        [url.pathExtension compare:@"wav"] != NSOrderedSame) {
        return NO;
    }
    return YES;
}


/**
 导出MP3格式文件

 @param importURL 文件地址
 @param completion completion
 */
- (void)importMP3ExtensionFile:(NSURL*)importURL completion:(void (^)(void))completion {
    
    NSURL *tmpURL = [[importURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"mov"];
    [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
    
    self.exportSession.outputURL = tmpURL;
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [[self exportSession] exportAsynchronouslyWithCompletionHandler:^(void) {
        if (self.exportSession.status == AVAssetExportSessionStatusFailed) {
            completion();
        } else if (self.exportSession.status == AVAssetExportSessionStatusCancelled) {
            completion();
        } else {
            @try {
                [self extractQuicktimeMovie:tmpURL toFile:importURL];
            }
            @catch (NSException *e) {
                OSStatus code = noErr;
                if ([e.name compare:WJKUnknownError]) code = kWJKUnknownError;
                else if ([e.name compare:WJKFileExistsError]) code = kWJKFileExistsError;
                NSDictionary* errorDict = [NSDictionary dictionaryWithObject:e.reason forKey:NSLocalizedDescriptionKey];
                
                movieFileError = [[NSError alloc] initWithDomain:WJKFetchLocalMusicErrorDomain code:code userInfo:errorDict];
            }
            [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
            completion();
        }
        
        self.exportSession = nil;
    }];
}


/**
 导出本地音乐文件

 @param musicURL 本地音乐地址
 @param importURL 导出路径
 @param completion completion
 */
- (void)importLocalMusicFromiPod:(NSURL *)musicURL importURL:(NSURL *)importURL completion:(void (^)(void))completion {
    if (nil == musicURL || nil == importURL) {
        return;
    }
    if (![WJKFetchLocalMusicManager validIpodLibraryURL:musicURL]) {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[importURL path]]) {
        return;
    }
    
    NSDictionary *options = [[NSDictionary alloc] init];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:musicURL options:options];
    if (nil == asset) {
        return;
    }
    
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    if (nil == self.exportSession) {
        return;
    }
    if ([[musicURL pathExtension] compare:@"mp3"] == NSOrderedSame) {
        [self importMP3ExtensionFile:importURL completion:completion];
        return;
    }
    
    NSLog(@"copyURL = %@",importURL);
    
    self.exportSession.outputURL = importURL;
    
    if ([[musicURL pathExtension] compare:@"m4a"] == NSOrderedSame) {
        self.exportSession.outputFileType = AVFileTypeAppleM4A;
    } else if ([[musicURL pathExtension] compare:@"wav"] == NSOrderedSame) {
        self.exportSession.outputFileType = AVFileTypeWAVE;
    } else if ([[musicURL pathExtension] compare:@"aif"] == NSOrderedSame) {
        self.exportSession.outputFileType = AVFileTypeAIFF;
    } else {
    }
    
    [[self exportSession] exportAsynchronouslyWithCompletionHandler:^(void) {
        completion();
        
        self.exportSession = nil;
    }];
}

- (void)extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL {
    FILE* src = fopen([[movieURL path] cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (NULL == src) {
        return;
    }
    char atom_name[5];
    atom_name[4] = '\0';
    unsigned long atom_size = 0;
    while (true) {
        if (feof(src)) {
            break;
        }
        fread((void*)&atom_size, 4, 1, src);
        fread(atom_name, 4, 1, src);
        atom_size = ntohl(atom_size);
        const size_t bufferSize = 1024*100;
        if (strcmp("mdat", atom_name) == 0) {
            FILE* dst = fopen([[destURL path] cStringUsingEncoding:NSUTF8StringEncoding], "w");
            unsigned char buf[bufferSize];
            if (NULL == dst) {
                fclose(src);
                return;
            }
            atom_size -= 8;
            while (atom_size != 0) {
                size_t read_size = (bufferSize < atom_size)?bufferSize:atom_size;
                if (fread(buf, read_size, 1, src) == 1) {
                    fwrite(buf, read_size, 1, dst);
                }
                atom_size -= read_size;
            }
            fclose(dst);
            fclose(src);
            return;
        }
        if (atom_size == 0)
            break;
        fseek(src, atom_size, SEEK_CUR);
    }
    fclose(src);
}

@end
