//
//  WJKMaskLoadingView.h
//  iOSwujike
//
//  Created by Zeaho on 2017/8/23.
//  Copyright © 2017年 xhb_iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJKMaskLoadingView : UIView

@property (nonatomic, copy) void (^reloadDataHandler)(void);

- (void)showInView:(UIView *)inView;

@end
