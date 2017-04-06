//
//  CMRemotePlayer.h
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/3/29.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RemoteAudioPlayerState) {
    RemoteAudioPlayerStateUnknown   = 0, // 未知状态
    RemoteAudioPlayerStateLoading   = 1, // 正在加载
    RemoteAudioPlayerStatePlaying   = 2, // 正在播放
    RemoteAudioPlayerStateStopped   = 3, // 停止播放
    RemoteAudioPlayerStatePause     = 4, // 暂停播放
    RemoteAudioPlayerStateFailed    = 5  // 播放失败
};

@interface CMRemotePlayer : NSObject

@property (nonatomic, weak, readonly) NSURL *url;
// 倍速
@property (nonatomic, assign) float rate;
// 静音
@property (nonatomic, assign) BOOL muted;
// 音量
@property (nonatomic, assign) float volume;

@property (nonatomic, assign, readonly) NSTimeInterval duration;

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

@property (nonatomic, assign, readonly) float progress;

@property (nonatomic, assign, readonly) float loadProgress;

@property (nonatomic, assign, readonly) RemoteAudioPlayerState remoteAudioPlayerState;

+ (instancetype)shareInstance;

- (void)pausePlay;

- (void)resumePlay;

- (void)stopPlay;

- (void)playWithUrl:(NSURL *)url isCache:(BOOL)isCache;

- (void)seekWithTimeInterval:(NSTimeInterval)timeInterval;

- (void)seekToProgress:(float)progress;


@end
