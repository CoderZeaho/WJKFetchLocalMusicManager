//
//  TableViewCell.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell ()

@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UILabel *musicNameLabel;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIImageView *symbolImageView;

@end

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _createSubviews];
        [self _configurateSubviewsDefault];
        [self _installConstraints];
    }
    return self;
}

- (void)_createSubviews {
    
    self.durationLabel = [[UILabel alloc] init];
    [[self contentView] addSubview:[self durationLabel]];
    
    self.musicNameLabel = [[UILabel alloc] init];
    [[self contentView] addSubview:[self musicNameLabel]];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[self contentView] addSubview:[self confirmButton]];
    
    self.symbolImageView = [[UIImageView alloc] init];
    [[self contentView] addSubview:[self symbolImageView]];
}

- (void)_configurateSubviewsDefault {
    
    self.durationLabel.text = @"00:56";
    self.durationLabel.font = [UIFont systemFontOfSize:14];
    self.durationLabel.textColor = [UIColor blackColor];
    
    self.musicNameLabel.text = @"歌曲名称";
    self.musicNameLabel.font = [UIFont systemFontOfSize:14];
    self.musicNameLabel.textColor = [UIColor blackColor];
    
    [[self confirmButton] setBackgroundColor:[UIColor orangeColor]];
    [[self confirmButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self confirmButton] setTitle:@"确定" forState:UIControlStateNormal];
    [[self confirmButton] addTarget:self action:@selector(didClickedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.confirmButton.hidden = YES;
    
    NSMutableArray *symbloImages = [NSMutableArray array];
    for (NSInteger i = 1; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"common_icon_symbol_%ld", i]];
        [symbloImages addObject:image];
    }
    self.symbolImageView.animationImages = symbloImages;
    self.symbolImageView.animationDuration = 1.f;
    self.symbolImageView.animationRepeatCount = 0;
    self.symbolImageView.hidden = YES;
    [[self symbolImageView] startAnimating];
}

- (void)_installConstraints {

    
    self.durationLabel.frame = CGRectMake(18, 0, 45, CGRectGetHeight(self.bounds));
    
    self.confirmButton.frame = CGRectMake(self.bounds.size.width, (50 - 25) / 2, 50, 25);
    
    self.symbolImageView.frame = CGRectMake(self.confirmButton.frame.origin.x - 45, self.confirmButton.frame.origin.y + 2, 21, CGRectGetHeight(self.confirmButton.frame) - 4);
    
    self.musicNameLabel.frame = CGRectMake(self.durationLabel.frame.origin.x + self.durationLabel.frame.size.width + 3, 0, CGRectGetWidth(self.bounds) - self.durationLabel.frame.size.width - self.confirmButton.frame.size.width - self.symbolImageView.frame.size.width - 65, CGRectGetHeight(self.bounds));
}

- (void)_updatePlayStatusContentLayout {
    self.symbolImageView.hidden = NO;
    [[self symbolImageView] startAnimating];
    self.confirmButton.hidden = NO;
}

- (void)_updateStopStatusContentLayout {
    self.symbolImageView.hidden = YES;
    [[self symbolImageView] stopAnimating];
    self.confirmButton.hidden = YES;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (_isPlaying != isPlaying) {
        _isPlaying = isPlaying;
    }
    if (_isPlaying) {
        [self _updatePlayStatusContentLayout];
    } else {
        [self _updateStopStatusContentLayout];
    }
}

- (void)setLocalMusic:(WJKLocalMusicModel *)localMusic {
    if (_localMusic != localMusic) {
        _localMusic = localMusic;
    }
    
    self.musicNameLabel.text = localMusic.title;
    self.durationLabel.text = localMusic.totalTimeFormat;
}

- (void)didClickedConfirmButton:(UIButton *)sender {
    NSLog(@"选中了《%@》", self.localMusic.title);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
