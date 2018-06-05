//
//  ViewController.m
//  WJKFetchLocalMusicManagerDemo
//
//  Created by Zeaho on 2018/2/10.
//  Copyright © 2018年 Zeaho. All rights reserved.
//

#import "ViewController.h"

// tool
#import "WJKFetchLocalMusicManager.h"
#import "WJKAudioPlayer.h"

// macro
#import "FileMacro.h"

// view
#import "TableViewCell.h"
#import "WJKMaskLoadingView.h"

#import "AppDelegate.h"

static NSString *const WJKLocalMusicCompleteCheckAuthorUserDefaultKey = @"WJKLocalMusicCompleteCheckAuthorUserDefaultKey";

#define TEMPWINDOW [(AppDelegate *)[UIApplication sharedApplication].delegate window]

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, WJKAudioPlayerDelegate>

@property (nonatomic, strong) UIButton *importButton;

@property (nonatomic, strong) WJKAudioPlayer *audioPlayer;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSArray *> *dataSource;

@property (nonatomic, strong) WJKMaskLoadingView *progressView;

@end

@implementation ViewController {
    BOOL _isFirstPlay;
    BOOL _isSelected;
    NSIndexPath *_previousSelectedIndexPath;
}

- (instancetype)init{
    if (self = [super init]) {
        self.title = @"本地曲库";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    
    self.importButton.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 50);
    [[self view] addSubview:[self importButton]];
    
    self.tableView.frame = CGRectMake(0, CGRectGetHeight(self.importButton.frame) + 74, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.importButton.frame) - 74);
    [[self tableView] registerClass:[TableViewCell class] forCellReuseIdentifier:NSStringFromClass([TableViewCell class])];
    [[self view] addSubview:[self tableView]];
    
    
    //默认进入进行授权检查
    [self _requestAppleMusicAccessWithAuthorizedHandler:^{
        //数据库没有创建好 暂时使用归档反归档本地化本地曲库
        NSString *musicArrayPath = [WJKCacheDirectory stringByAppendingPathComponent:@"localMusic.plist"];
        NSArray *musicArray = [NSKeyedUnarchiver unarchiveObjectWithFile:musicArrayPath];
        [self _createLocalMusicResource:musicArray];
        if (musicArray.count > 0) {
            self.dataSource = @[musicArray];
        }
        [[self tableView] reloadData];
    } unAuthorizedHandler:^{
        
        self.dataSource = @[];
        [[self tableView] reloadData];
    }];
}

#pragma mark - private
- (void)_fetchLocalMusicFromIPod {
    __weak typeof(self)weakSelf = self;
    [[WJKFetchLocalMusicManager shareFetchLocalMusicManager] fetchLocalMusicFromiPod:^(NSMutableArray *musicArray, NSError *error) {
        [weakSelf _handleLocalMusic:musicArray];
    }];
}

- (void)_handleLocalMusic:(NSMutableArray *)musicArray {
    
    NSMutableArray *sectionDataSource = [NSMutableArray arrayWithArray:musicArray];
    
    // 创建缓存文件夹
    [self _createCacheDirectory];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _createLocalMusicResource:musicArray];
    });
    
    // 数据库没有创建好暂使用归档反归档本地化本地曲库
    NSString *musicArrayPath = [WJKCacheDirectory stringByAppendingPathComponent:@"localMusic.plist"];
    [NSKeyedArchiver archiveRootObject:sectionDataSource toFile:musicArrayPath];
    NSLog(@"localMusicArrayPath: %@", musicArrayPath);
    
    self.dataSource = @[sectionDataSource];
}

- (void)_createCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:WJKCacheDirectory]) {
        [fileManager createDirectoryAtPath:WJKCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)_createLocalMusicResource:(NSArray *)musicArray
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    for (WJKLocalMusicModel *music in musicArray) {
        NSString *folder = [[WJKCacheDirectory stringByAppendingPathComponent:@"LocalMusic"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", music.objectID]];
        
        NSString *file = [[folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", music.artist, music.title]] stringByAppendingPathExtension:[[music assetUrl] pathExtension]];
        
        // 若拷贝音乐已经存在 则执行下一条拷贝
        if ([[NSFileManager defaultManager] fileExistsAtPath:folder]) {
            break;
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
        [[WJKFetchLocalMusicManager shareFetchLocalMusicManager] importLocalMusicFromiPod:[music assetUrl] importURL:[NSURL fileURLWithPath:file] completion:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
}

//判断是否授权访问媒体资源库
- (void)_requestAppleMusicAccessWithAuthorizedHandler:(void(^)(void))authorizedHandler
                                  unAuthorizedHandler:(void(^)(void))unAuthorizedHandler{
    if (@available(iOS 9.3, *)) {
        MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
        if (authStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedHandler ? authorizedHandler() : nil;
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        unAuthorizedHandler ? unAuthorizedHandler() : nil;
                    });
                }
            }];
        }else if (authStatus == MPMediaLibraryAuthorizationStatusAuthorized){
            authorizedHandler ? authorizedHandler() : nil;
        }else{
            unAuthorizedHandler ? unAuthorizedHandler() : nil;
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)_handleSettingAuthorizedWithCompletion:(void (^)(BOOL success))completion {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"访问媒体资源库" message:@"你没有开启访问媒体资源库权限，开启后即可导入iPod音乐" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"以后再说" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:settingAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)_revertPlayingStatus {
    
    [[self audioPlayer] stop];
    //重置播放状态
    if (_previousSelectedIndexPath) {
        
        TableViewCell *currentSelectedCell = [[self tableView] cellForRowAtIndexPath:_previousSelectedIndexPath];
        currentSelectedCell.isPlaying = NO;
        [[self tableView] reloadRowsAtIndexPaths:@[_previousSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        _isSelected = NO;
    }
}

#pragma mark - accessor
- (UIButton *)importButton {
    if (!_importButton) {
        _importButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_importButton setBackgroundImage:[UIImage imageNamed:@"common_img_background"] forState:UIControlStateNormal];
        [_importButton setTitle:@"扫描音乐" forState:UIControlStateNormal];
        [_importButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_importButton addTarget:self action:@selector(didClickedImportMusicButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _importButton;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[];
    }
    return _dataSource;
}

- (WJKAudioPlayer *)audioPlayer {
    if(_audioPlayer == nil) {
        _audioPlayer = [[WJKAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (WJKMaskLoadingView *)progressView {
    if (!_progressView) {
        _progressView = [[WJKMaskLoadingView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    }
    return _progressView;
}

#pragma mark - action
- (void)didClickedImportMusicButton:(UIButton *)sender {
    
    [self _revertPlayingStatus];
    
    //点击扫面再一次进行授权检查
    [self _requestAppleMusicAccessWithAuthorizedHandler:^{
        
        [[self progressView] showInView:TEMPWINDOW];
        
        //导入iPod音乐
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _fetchLocalMusicFromIPod];
        });
        
        __weak typeof(self) wself = self;
        self.progressView.reloadDataHandler = ^{
            [[wself tableView] reloadData];
        };
        
    } unAuthorizedHandler:^{
        //第一次访问媒体资料库授权
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeAnyAudio) forProperty:MPMediaItemPropertyMediaType];
        MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates:nil];
        [mediaQuery addFilterPredicate:predicate];
        //检查是否进行过授权
        if ([[NSUserDefaults standardUserDefaults] boolForKey:WJKLocalMusicCompleteCheckAuthorUserDefaultKey]) {
            [self _handleSettingAuthorizedWithCompletion:^(BOOL success) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WJKLocalMusicCompleteCheckAuthorUserDefaultKey];
    }];
}

#pragma mark - WJKAudioPlayerDelegate
- (void)audioPlayerWillStopMusic {
    [self _revertPlayingStatus];
}

#pragma mark - tableView delegate && dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *sectionDataSource = [NSMutableArray arrayWithArray:[[self dataSource] firstObject] ?: @[]];
    return [sectionDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TableViewCell class])];
    }
    NSArray *sectionDataSource = self.dataSource[[indexPath section]];
    WJKLocalMusicModel *localMusic = sectionDataSource[[indexPath row]];
    cell.localMusic = localMusic;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TableViewCell *currentSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
    TableViewCell *previousSelectedCell = [tableView cellForRowAtIndexPath:_previousSelectedIndexPath];
    
    NSArray *sectionDataSource = self.dataSource[[indexPath section]];
    WJKLocalMusicModel *localMusic = sectionDataSource[[indexPath row]];
    
    if (_previousSelectedIndexPath == indexPath) {
        if (_isSelected) {
            [[self audioPlayer] pause];
            currentSelectedCell.isPlaying = NO;
            _isSelected = NO;
        } else {
            if (_isFirstPlay) {
                [[self audioPlayer] playWithURL:[localMusic assetUrl]];
                _isFirstPlay = NO;
            } else {
                [[self audioPlayer] resume];
            }
            currentSelectedCell.isPlaying = YES;
            _isSelected = YES;
        }
    } else {
        if (_isSelected) {
            [[self audioPlayer] playWithURL:[localMusic assetUrl]];
            [[self audioPlayer] resume];
            previousSelectedCell.isPlaying = NO;
            currentSelectedCell.isPlaying = YES;
            _isSelected = YES;
        } else {
            [[self audioPlayer] playWithURL:[localMusic assetUrl]];
            currentSelectedCell.isPlaying = YES;
            _isSelected = YES;
        }
    }
    _previousSelectedIndexPath = indexPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
