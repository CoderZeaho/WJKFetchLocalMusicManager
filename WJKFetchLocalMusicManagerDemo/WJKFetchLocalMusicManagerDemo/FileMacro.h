//
//  FileMacro.h
//  iOSwujike
//
//  Created by Zeaho on 2017/8/30.
//  Copyright © 2017年 xhb_iOS. All rights reserved.
//

#ifndef FileMacro_h
#define FileMacro_h

// 缓存主目录
#define WJKCacheDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"WJKCache"]

//*****************************   音乐   **********************
// 缓存音乐文件目录
#define WJKCacheMusicDirectory [WJKCacheDirectory stringByAppendingPathComponent:@"WJKMusicCache"]

#endif /* FileMacro_h */
