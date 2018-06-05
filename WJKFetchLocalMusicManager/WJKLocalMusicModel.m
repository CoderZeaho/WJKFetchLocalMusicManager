//
//	WJKLocalMusicModel.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "WJKLocalMusicModel.h"

NSString *const kWJKLocalMusicModelAlbumThumb = @"albumThumb";
NSString *const kWJKLocalMusicModelAlbumTitle = @"albumTitle";
NSString *const kWJKLocalMusicModelArtist = @"artist";
NSString *const kWJKLocalMusicModelAssetUrl = @"assetUrl";
NSString *const kWJKLocalMusicModelAudio = @"audio";
NSString *const kWJKLocalMusicModelFileName = @"fileName";
NSString *const kWJKLocalMusicModelObjectID = @"id";
NSString *const kWJKLocalMusicModelTitle = @"title";
NSString *const kWJKLocalMusicModelTotalTime = @"totalTime";
NSString *const kWJKLocalMusicModelTotalTimeFormat = @"totalTimeFormat";

@interface WJKLocalMusicModel ()
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@end
@implementation WJKLocalMusicModel

- (instancetype)initWithMPMediaItem:(MPMediaItem *)item{
    self = [super init];
    if (self) {
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
        if (artwork != nil) {
            self.albumThumb = [artwork imageWithSize:artwork.bounds.size];
        }
        self.albumTitle = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
        self.artist = [item valueForProperty:MPMediaItemPropertyArtist];
        self.assetUrl = [item valueForProperty:MPMediaItemPropertyAssetURL];
        self.audio = item;
        NSString *fileSuffix = @".mp3";
        self.fileName = [NSString stringWithFormat:@"%@%@", self.title, fileSuffix];
        self.objectID = [item valueForProperty:MPMediaItemPropertyPersistentID];
        self.title = [item valueForProperty:MPMediaItemPropertyTitle];
        self.totalTime = [self getDurationOfAudioWithItem:item];
        self.totalTimeFormat = [self getFormatDurationOfAudioWithItem:item];
    }
	return self;
}

- (NSNumber *)getDurationOfAudioWithItem:(id)item{
    NSNumber *time = NULL;
    if ([item isKindOfClass:[ALAsset class]]) {
        time = [(ALAsset*)item valueForProperty:ALAssetPropertyDuration];
    }else{
        time = [(MPMediaItem *)item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    }
    return time;
}

- (NSString *)getFormatDurationOfAudioWithItem:(id)item{
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

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.albumThumb != nil){
		[aCoder encodeObject:self.albumThumb forKey:kWJKLocalMusicModelAlbumThumb];
	}
	if(self.albumTitle != nil){
		[aCoder encodeObject:self.albumTitle forKey:kWJKLocalMusicModelAlbumTitle];
	}
	if(self.artist != nil){
		[aCoder encodeObject:self.artist forKey:kWJKLocalMusicModelArtist];
	}
	if(self.assetUrl != nil){
		[aCoder encodeObject:self.assetUrl forKey:kWJKLocalMusicModelAssetUrl];
	}
	if(self.audio != nil){
		[aCoder encodeObject:self.audio forKey:kWJKLocalMusicModelAudio];
	}
	if(self.fileName != nil){
		[aCoder encodeObject:self.fileName forKey:kWJKLocalMusicModelFileName];
	}
    if(self.objectID != nil){
        [aCoder encodeObject:self.objectID forKey:kWJKLocalMusicModelObjectID];
    }
	if(self.title != nil){
		[aCoder encodeObject:self.title forKey:kWJKLocalMusicModelTitle];
	}
	if(self.totalTime != nil){
		[aCoder encodeObject:self.totalTime forKey:kWJKLocalMusicModelTotalTime];
	}
	if(self.totalTimeFormat != nil){
		[aCoder encodeObject:self.totalTimeFormat forKey:kWJKLocalMusicModelTotalTimeFormat];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.albumThumb = [aDecoder decodeObjectForKey:kWJKLocalMusicModelAlbumThumb];
	self.albumTitle = [aDecoder decodeObjectForKey:kWJKLocalMusicModelAlbumTitle];
	self.artist = [aDecoder decodeObjectForKey:kWJKLocalMusicModelArtist];
	self.assetUrl = [aDecoder decodeObjectForKey:kWJKLocalMusicModelAssetUrl];
	self.audio = [aDecoder decodeObjectForKey:kWJKLocalMusicModelAudio];
	self.fileName = [aDecoder decodeObjectForKey:kWJKLocalMusicModelFileName];
    self.objectID = [aDecoder decodeObjectForKey:kWJKLocalMusicModelObjectID];
	self.title = [aDecoder decodeObjectForKey:kWJKLocalMusicModelTitle];
	self.totalTime = [aDecoder decodeObjectForKey:kWJKLocalMusicModelTotalTime];
	self.totalTimeFormat = [aDecoder decodeObjectForKey:kWJKLocalMusicModelTotalTimeFormat];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	WJKLocalMusicModel *copy = [WJKLocalMusicModel new];

	copy.albumThumb = [self.albumThumb copy];
	copy.albumTitle = [self.albumTitle copy];
	copy.artist = [self.artist copy];
	copy.assetUrl = [self.assetUrl copy];
	copy.audio = [self.audio copy];
	copy.fileName = [self.fileName copy];
    copy.objectID = [self.objectID copy];
	copy.title = [self.title copy];
	copy.totalTime = [self.totalTime copy];
	copy.totalTimeFormat = [self.totalTimeFormat copy];

	return copy;
}
#pragma clang diagnostic pop
@end
