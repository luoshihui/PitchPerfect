//
//  AudioPlayHelper.h
//  PitchPerfect-objc
//
//  Created by Lsh on 2018/11/30.
//  Copyright © 2018 Lsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayHelper : NSObject

- (void)setUpAudioFile:(NSURL *)url;

- (void)playVideoRate:(float)rate pitch:(float)pitch echo:(BOOL)echo reverb:(BOOL)reverb;

- (void)stopAudio;

@end

NS_ASSUME_NONNULL_END
