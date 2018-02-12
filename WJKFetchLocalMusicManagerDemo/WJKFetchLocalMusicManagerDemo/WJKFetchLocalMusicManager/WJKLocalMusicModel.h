//
//  WJKLocalMusicModel.h
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface WJKLocalMusicModel : NSObject

@property (strong, nonatomic) MPMediaItem        *audio;
@property (strong, nonatomic) NSURL              *assetUrl;
@property (strong, nonatomic) NSString           *title;
@property (strong, nonatomic) NSString           *artist;
@property (strong, nonatomic) NSString           *albumTitle;
@property (strong, nonatomic) UIImage            *albumThumb;
@property (strong, nonatomic) NSString           *fileName;
@property (strong, nonatomic) NSNumber           *totalTime;
@property (strong, nonatomic) NSString           *totalTimeFormat;

- (instancetype)initWithMPMediaItem:(MPMediaItem *)item;

@end
