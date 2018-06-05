//
//	WJKLocalMusicModel.h
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface WJKLocalMusicModel : NSObject

@property (nonatomic, strong) UIImage * albumThumb;
@property (nonatomic, copy) NSString * albumTitle;
@property (nonatomic, copy) NSString * artist;
@property (nonatomic, strong) NSURL * assetUrl;
@property (nonatomic, strong) MPMediaItem * audio;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * objectID;  
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * totalTime;
@property (nonatomic, strong) NSString * totalTimeFormat;

- (instancetype)initWithMPMediaItem:(MPMediaItem *)item;

@end
