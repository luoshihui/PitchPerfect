//
//  PlayViewController.m
//  PitchPerfect-objc
//
//  Created by Lsh on 2018/11/30.
//  Copyright © 2018 Lsh. All rights reserved.
//

#import "PlayViewController.h"
#import "AudioPlayHelper.h"

@interface PlayViewController ()

@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISwitch *echoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *reverbSwitch;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;

@property (nonatomic, strong) AudioPlayHelper *playHelper;

@property (nonatomic, assign) float rate;
@property (nonatomic, assign) float pitch;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rate = 1;
    self.pitch = 0;
    [self.rateSlider addTarget:self action:@selector(rateSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.pitchSlider addTarget:self action:@selector(pitchSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.playHelper = [[AudioPlayHelper alloc] init];
    [self.playHelper setUpAudioFile:[NSURL fileURLWithPath:self.audioPath]];
}

- (void)rateSliderValueChanged:(UISlider *)slider {
    self.rate = slider.value;
    self.rateLabel.text = [NSString stringWithFormat:@"%.2f", self.rate];
    
}

- (void)pitchSliderValueChanged:(UISlider *)slider {
    self.pitch = slider.value;
    self.pitchLabel.text = [NSString stringWithFormat:@"%.0f", self.pitch];
}

- (IBAction)clickPlayButton:(id)sender {
    [self.playHelper stopAudio];
    [self.playHelper playVideoRate:self.rate pitch:self.pitch echo:self.echoSwitch.isOn reverb:self.reverbSwitch.isOn];
}

- (IBAction)clickStopButton:(id)sender {
    [self.playHelper stopAudio];
}


@end
