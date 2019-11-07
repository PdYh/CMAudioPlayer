//
//  ViewController.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 17/3/25.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "ViewController.h"

#import "CMRemotePlayer.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *costTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *loadSlider;

@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (IBAction)play:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group22/M0B/60/85/wKgJM1g1g0ShoPalAJiI5nj3-yY200.m4a"];
    [[CMRemotePlayer shareInstance] playWithUrl:url isCache:YES];
}

- (IBAction)pause:(id)sender {
    [[CMRemotePlayer shareInstance] pausePlay];
}
- (IBAction)resume:(id)sender {
    [[CMRemotePlayer shareInstance] resumePlay];
}

- (IBAction)stop:(id)sender {
    [[CMRemotePlayer shareInstance] stopPlay];
}


- (IBAction)kuaijin15:(id)sender {
    [[CMRemotePlayer shareInstance] seekWithTimeInterval:15];
}

- (IBAction)progress:(UISlider *)sender {
    [[CMRemotePlayer shareInstance] seekToProgress:sender.value];
}
- (IBAction)doubleRate:(id)sender {
    [CMRemotePlayer shareInstance].rate = 2.0;
}
- (IBAction)volume:(UISlider *)sender {
    [CMRemotePlayer shareInstance].volume = sender.value;
}
- (IBAction)mute:(id)sender {
    [CMRemotePlayer shareInstance].muted = ![CMRemotePlayer shareInstance].muted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
    
    UIButton *btn1 = [[UIButton alloc] init];
    UIButton *btn2 = [[UIButton alloc] init];
    UIButton *btn = [[UIButton alloc] init];
}

- (void)update {
    
    self.costTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", (int)[CMRemotePlayer shareInstance].currentTime / 60, (int)[CMRemotePlayer shareInstance].currentTime % 60];
    
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", (int)[CMRemotePlayer shareInstance].duration / 60, (int)[CMRemotePlayer shareInstance].duration % 60];
    
    self.loadSlider.value = [CMRemotePlayer shareInstance].loadProgress;
    
    self.playSlider.value = [CMRemotePlayer shareInstance].progress;
    self.volumeSlider.value = [CMRemotePlayer shareInstance].volume;
    
    NSLog(@"%zd", [CMRemotePlayer shareInstance].remoteAudioPlayerState);
}
@end
