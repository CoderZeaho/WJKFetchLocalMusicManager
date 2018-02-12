//
//  TableViewCell.h
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJKLocalMusicModel.h"

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) WJKLocalMusicModel *localMusic;

@property (nonatomic, copy) void (^confirmTouchHandler)(void);

@property (nonatomic, assign) BOOL isPlaying;

@end
