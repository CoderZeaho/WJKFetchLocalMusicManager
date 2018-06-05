//
//  WJKMaskLoadingView.m
//  iOSwujike
//
//  Created by Zeaho on 2017/8/23.
//  Copyright © 2017年 xhb_iOS. All rights reserved.
//

#import "WJKMaskLoadingView.h"

@interface WJKMaskLoadingView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIControl *indicatorView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation WJKMaskLoadingView {
    NSInteger _progress;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _createSubviews];
        [self _configurateSubviewsDefault];
        [self _installConstraints];
    }
    return self;
}

- (void)_createSubviews {
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:[self backgroundView]];
    
    self.indicatorView = [[UIControl alloc] initWithFrame:CGRectZero];
    [[self backgroundView] addSubview:[self indicatorView]];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [[self backgroundView] addSubview:[self textLabel]];
}

- (void)_configurateSubviewsDefault {
    
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.text = @"扫描中0％";
}

- (void)_installConstraints {
    
    [[self backgroundView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [[self textLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backgroundView);
        make.right.mas_equalTo(self.backgroundView);
        make.width.mas_equalTo(self.backgroundView).multipliedBy(0.6);
    }];
    
    [[self indicatorView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.textLabel);
        make.right.mas_equalTo(self.textLabel.mas_left).mas_offset(5);
        make.height.width.mas_equalTo(40);
    }];
}

- (UIActivityIndicatorView *)loadingActivityIndicator {
    if (!_loadingActivityIndicator) {
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:[[self indicatorView] bounds]];
        [_loadingActivityIndicator setUserInteractionEnabled:YES];
        [_loadingActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        _loadingActivityIndicator.hidden = YES;
    }
    return _loadingActivityIndicator;
}

- (void)progressDidChanged {
    _progress = _progress + 5;
    if (_progress <= 100) {
        
        self.textLabel.text = [NSString stringWithFormat:@"扫描中%ld％", _progress];
    } else {
        
        [[self timer] invalidate];
        self.timer = nil;
        _progress = 0;
        [self dismissInView];
    }
}

- (void)dismissInView {
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.hidden = YES;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        self.reloadDataHandler();
        
        [self removeFromSuperview];
    }];
}

- (void)showInView:(UIView *)inView {
    [inView addSubview:self];
    self.frame = [inView bounds];
    
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.hidden = NO;
        [[self indicatorView] addSubview:[self loadingActivityIndicator]];
        [[self loadingActivityIndicator] startAnimating];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.timer =[NSTimer scheduledTimerWithTimeInterval:0.2
                                                target:self
                                              selector:@selector(progressDidChanged)
                                              userInfo:nil
                                               repeats:YES];
    }];
}

#pragma mark - accessor
- (void)setFetchProgress:(float)fetchProgress {
    if (fetchProgress <= 100) {
        self.textLabel.text = [NSString stringWithFormat:@"扫描中%.2f％", fetchProgress];
    } else {
        [[self timer] invalidate];
        self.timer = nil;
        [self dismissInView];
    }
}

@end
