//
//  AudioPlayHelper.m
//  PitchPerfect-objc
//
//  Created by Lsh on 2018/11/30.
//  Copyright © 2018 Lsh. All rights reserved.
//

#import "AudioPlayHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayHelper()<AVAudioPlayerDelegate>

@property (nonatomic, strong) NSURL *recordedAudioURL;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) NSTimer *stopTimer;

@end

@implementation AudioPlayHelper

- (void)setUpAudioFile:(NSURL *)url {
    @try {
        self.audioFile = [[AVAudioFile alloc] initForReading:url error:nil];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    } @catch (NSException *exception) {
        NSLog(@"setUpAudioFile :%@", exception.description);
    }
}

- (void)playVideoRate:(float)rate pitch:(float)pitch echo:(BOOL)echo reverb:(BOOL)reverb {
    
    if (self.audioFile == nil) {
        NSLog(@"音频文件为空，请返回录音");
        return;
    }
    
    //初始化音频引擎 init audio engine components
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    //初始化播放节点并加入引擎中 init player node, add to engine
    self.audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.audioPlayerNode];
    
    //调整节点的速率/节距 node for adjusting rate/pitch
    AVAudioUnitTimePitch *changeRatePitchNode = [[AVAudioUnitTimePitch alloc] init];
    changeRatePitchNode.rate = rate;
    changeRatePitchNode.pitch = pitch;
    [self.audioEngine attachNode:changeRatePitchNode];
    
    //回声 node for echo
    AVAudioUnitDistortion *echoNode = [[AVAudioUnitDistortion alloc] init];
    [echoNode loadFactoryPreset:AVAudioUnitDistortionPresetMultiEcho1];
    [self.audioEngine attachNode:echoNode];
    
    //混响 node for reverb
    AVAudioUnitReverb *revrebNode = [[AVAudioUnitReverb alloc] init];
    [revrebNode loadFactoryPreset:AVAudioUnitReverbPresetCathedral];
    revrebNode.wetDryMix = 50;
    [self.audioEngine attachNode:revrebNode];
    
    //链接所有节点 connect nodes
    if (echo == true && reverb == true) {
        [self connectAudioNodes:@[self.audioPlayerNode,changeRatePitchNode,echoNode,revrebNode,self.audioEngine.outputNode]];
    }else if (echo == true) {
        [self connectAudioNodes:@[self.audioPlayerNode,changeRatePitchNode,echoNode,self.audioEngine.outputNode]];
    }else if (reverb == true) {
        [self connectAudioNodes:@[self.audioPlayerNode,changeRatePitchNode,revrebNode,self.audioEngine.outputNode]];
    }else {
        [self connectAudioNodes:@[self.audioPlayerNode,changeRatePitchNode,self.audioEngine.outputNode]];
    }
    
    //启动引擎 schedule to play and start the engine!
    [self.audioPlayerNode stop];
    [self.audioPlayerNode scheduleFile:self.audioFile atTime:nil completionHandler:^{
        double delayInSeconds = 0.0; //延迟秒数
        AVAudioTime *lastRenderTime = self.audioPlayerNode.lastRenderTime;
        AVAudioTime *playerTime = [self.audioPlayerNode playerTimeForNodeTime:lastRenderTime];
        delayInSeconds = (self.audioFile.length - playerTime.sampleTime)*1.0f/self.audioFile.processingFormat.sampleRate/rate;
        //组装一个定时器在播放完成时调用stopAudio schedule a stop timer for when audio finishes playing
        self.stopTimer = [NSTimer timerWithTimeInterval:delayInSeconds target:self selector:@selector(stopAudio) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.stopTimer forMode:NSRunLoopCommonModes];
    }];
    @try {
        [self.audioEngine startAndReturnError:nil];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        return;
    }
    [self.audioPlayerNode play];
}

- (void)stopAudio {
    if (self.audioPlayerNode != nil) {
        [self.audioPlayerNode stop];
    }
    
    if (self.stopTimer != nil) {
        [self.stopTimer invalidate];
    }
    
    if (self.audioEngine != nil) {
        [self.audioEngine stop];
        [self.audioEngine reset];
    }
}

- (void)connectAudioNodes:(NSArray *)nodes {
    for (int i = 0; i < nodes.count - 1; i++) {
        [self.audioEngine connect:nodes[i] to:nodes[i+1] format:self.audioFile.processingFormat];
    }
}

@end
