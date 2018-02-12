//
//  WJKLocalMusicModel.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "WJKLocalMusicModel.h"

@implementation WJKLocalMusicModel

- (instancetype)initWithMPMediaItem:(MPMediaItem *)item{
    self = [super init];
    if (self) {
        self.audio = item;
        self.assetUrl = [item valueForProperty:MPMediaItemPropertyAssetURL];
        self.title = [item valueForProperty:MPMediaItemPropertyTitle];
        self.artist = [item valueForProperty:MPMediaItemPropertyArtist];
        self.albumTitle = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
        if (artwork!=nil) {
            self.albumThumb = [artwork imageWithSize:artwork.bounds.size];
        }
        NSString *fileSuffix = @".mp3";
        self.fileName = [NSString stringWithFormat:@"%@%@", self.title, fileSuffix];
        self.totalTime = [self getIntDurationOfAudioWithItem:item];
        self.totalTimeFormat = [self getDurationOfAudioWithItem:item];
    }
    return self;
}


- (NSString *)getDurationOfAudioWithItem:(id)item{
    
    NSNumber *time = NULL;
    
    if ([item isKindOfClass:[ALAsset class]]) {
        time = [(ALAsset*)item valueForProperty:ALAssetPropertyDuration];
    }else{
        time = [(MPMediaItem *)item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    }
    NSInteger minute = [[NSString stringWithFormat:@"%@",time] integerValue]/60;
    NSInteger second = [[NSString stringWithFormat:@"%@",time] integerValue]%60;
    NSInteger hour = [[NSString stringWithFormat:@"%@",time] integerValue]/3600;
    NSString *duration = @"";
    if (minute < 60) {
        duration=[NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
    } else {
        duration=[NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)minute,(long)second];
    }
    return duration;
}


- (NSNumber *)getIntDurationOfAudioWithItem:(id)item{
    
    NSNumber *time = NULL;
    if ([item isKindOfClass:[ALAsset class]]) {
        time = [(ALAsset*)item valueForProperty:ALAssetPropertyDuration];
    }else{
        time = [(MPMediaItem *)item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    }
    return time;
}

//序列化:(归档时使用)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.audio forKey:@"audio"];
    [aCoder encodeObject:self.assetUrl forKey:@"assetUrl"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.albumTitle forKey:@"albumTitle"];
    [aCoder encodeObject:self.albumThumb forKey:@"albumThumb"];
    [aCoder encodeObject:self.totalTime forKey:@"totalTime"];
    [aCoder encodeObject:self.totalTimeFormat forKey:@"totalTimeFormat"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
}

//反序列化:(反归档使用)
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.audio = [aDecoder decodeObjectForKey:@"audio"];
        self.assetUrl = [aDecoder decodeObjectForKey:@"assetUrl"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.artist = [aDecoder decodeObjectForKey:@"artist"];
        self.albumTitle = [aDecoder decodeObjectForKey:@"albumThumb"];
        self.albumThumb = [aDecoder decodeObjectForKey:@"thumbnail"];
        self.totalTime = [aDecoder decodeObjectForKey:@"totalTime"];
        self.totalTimeFormat = [aDecoder decodeObjectForKey:@"totalTimeFormat"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
    }
    return self;
}

@end
