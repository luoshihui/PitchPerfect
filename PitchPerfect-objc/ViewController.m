//
//  ViewController.m
//  PitchPerfect-objc
//
//  Created by Lsh on 2018/11/30.
//  Copyright © 2018 Lsh. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UIButton *stopImageVIEW;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSString *audioName;
@property (nonatomic, strong) NSString *audioPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILongPressGestureRecognizer *longTop = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestAction:)];
    [self.recordImageView addGestureRecognizer:longTop];
    [self setUpRecord];
}

// MARK: -  按钮响应函数
//长按响应函数
- (void)longGestAction:(UILongPressGestureRecognizer *)gest {
    switch (gest.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"录音开始");
            if ([self canRecord]) {
                [_audioRecorder record];
            }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"录音结束");
            [_audioRecorder stop];
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"录音取消");
            [_audioRecorder stop];
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"录音失败");
            break;
        default:
            break;
    }
}

// MARK: -  网络请求

// MARK: -  协议函数

// MARK: -  组装数据、创建视图、自定义方法
//初始化录音器
- (void)setUpRecord {
    //创建录音文件保存路径
    NSURL *url = [self getSavePath];
    //创建录音格式设置
    NSDictionary *settingDic = [self getAudioSetting];
    //创建录音机
    @try {
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settingDic error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        NSLog(@"成功初始化");
    } @catch (NSException *exception) {
        NSLog(@"初始化失败");
    }
}

//获取录音权限. 返回值,YES为无拒绝,NO为拒绝录音.
- (BOOL)canRecord {
    __block BOOL canR = NO;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession requestRecordPermission:^(BOOL granted) {
                canR = granted;
                if (granted) {
                    NSLog(@"granted");
                } else{
                    NSLog(@"not granted");
                }
            }];
        }
    }else{
        canR = YES;
    }
    
    return canR;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileNme = [str stringByAppendingString:@".aac"];
    _audioName = fileNme;
    
    NSString *urlStr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [NSString stringWithFormat:@"%@/%@", urlStr, fileNme];
    NSURL *url = [NSURL fileURLWithPath:path];
    _audioPath = path;
    
    return url;
}

- (NSDictionary *)getAudioSetting{
    NSDictionary *recDic = @{AVEncoderAudioQualityKey:@(AVAudioQualityLow),
                             AVNumberOfChannelsKey:@(2),
                             AVSampleRateKey:@(44100.0),
                             AVFormatIDKey:@(kAudioFormatMPEG4AAC)};//录音质量：low；每个采样点位数,分为8、16、24、32； 频道类型：双声道，1为单声道；录音采样率：随意设置，一般为8000； , AVFormatIDKey:kAudioFormatMPEG4AAC 录音格式：AAC格式
    return recDic;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sende {
    if ([segue.identifier isEqualToString:@"ToPlay"]) {
        PlayViewController *theVc = segue.destinationViewController;
        theVc.audioPath = self.audioPath;
    }
}

@end
