//
//  CMRemotePlayer.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/3/29.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "CMRemotePlayer.h"

#import "NSURL+Custom.h"
#import "CMResourceLoader.h"
#import <AVFoundation/AVFoundation.h>
#define playStatus @"status"
#define playLikelyToKeepUp @"playbackLikelyToKeepUp"
@interface CMRemotePlayer ()
{
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *avPlayer;

@property (nonatomic, strong) CMResourceLoader *loader;

@end


@implementation CMRemotePlayer

static CMRemotePlayer * _shareInstance;

+ (instancetype)shareInstance {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[self alloc] init];
        });
    }
    return _shareInstance;
}

- (CMResourceLoader *)loader
{
    if (!_loader) {
        _loader = [[CMResourceLoader alloc] init];
    }
    return _loader;
}

#pragma mark - public methods
- (void)playWithUrl:(NSURL *)url isCache:(BOOL)isCache
{
    if ([url isEqual:self.url]) {
        
        if (self.remoteAudioPlayerState == RemoteAudioPlayerStateLoading) {
            
            return;
        }
        if (self.remoteAudioPlayerState == RemoteAudioPlayerStatePlaying) {
            
            return;
        }
        if (self.remoteAudioPlayerState == RemoteAudioPlayerStatePause) {
            [self resumePlay];
            return;
        }
    }
    
    // 资源请求
    self.url = url;
    NSURL *resultURL = url;
    if (isCache) {
        // 重写资源代理要自定义请求协议
        resultURL = [url customURL];
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:resultURL];
    if (self.avPlayer.currentItem) {
        [self clearObserver];
    }
    [asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
    
    // 处理下载/缓存的资源
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [item addObserver:self forKeyPath:playStatus options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:playLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    // 播放资源
    self.avPlayer = [AVPlayer playerWithPlayerItem:item];
}

- (void)seekWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSTimeInterval sec = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime) + timeInterval;
    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(sec, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间段的资源");
        }else {
            NSLog(@"取消加载这个时间段的资源");
        }
    }];
}

- (void)seekToProgress:(float)progress
{
    NSTimeInterval sec = CMTimeGetSeconds(self.avPlayer.currentItem.duration) * progress;
    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(sec, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间段的资源");
        }else {
            NSLog(@"取消加载这个时间段的资源");
        }
    }];
}

#pragma mark - getter,setter
- (void)pausePlay
{
    [self.avPlayer pause];
    
    if (self.avPlayer) {
        
        _isUserPause = YES;
        
        self.remoteAudioPlayerState = RemoteAudioPlayerStatePause;
    }
}

- (void)resumePlay
{
    [self.avPlayer play];
    if (self.avPlayer.rate != 0.0) {
        _isUserPause = NO;
        self.remoteAudioPlayerState = RemoteAudioPlayerStatePlaying;
    }
}

- (void)stopPlay
{
    [self.avPlayer pause];
    [self clearObserver];
    self.avPlayer = nil;
    _isUserPause = YES;
    self.remoteAudioPlayerState = RemoteAudioPlayerStateStopped;
}

- (float)rate
{
    return self.avPlayer.rate;
}

- (BOOL)muted
{
    return self.avPlayer.muted;
}

- (float)volume
{
    return self.avPlayer.volume;
}

- (void)setRate:(float)rate
{
    self.avPlayer.rate = rate;
}

- (void)setMuted:(BOOL)muted
{
    self.avPlayer.muted = muted;
}

- (void)setVolume:(float)volume
{
    if (volume > 0.0) {
        self.muted = NO;
    }
    [self.avPlayer setVolume:volume];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
}

- (void)setRemoteAudioPlayerState:(RemoteAudioPlayerState)remoteAudioPlayerState
{
    _remoteAudioPlayerState = remoteAudioPlayerState;
}

- (NSTimeInterval)duration
{
    NSTimeInterval totalTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    if (isnan(totalTime)) {
        return 0.0;
    }
    return totalTime;
}

- (NSTimeInterval)currentTime
{
    NSTimeInterval currTime = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
    if (isnan(currTime)) {
        return 0.0;
    }
    return currTime;
}

- (float)progress
{
    if (self.duration == 0.0) {
        return 0;
    }
    return self.currentTime / self.duration;
}

- (float)loadProgress
{
    if (self.duration == 0.0) {
        return 0;
    }
    
    CMTimeRange range = [self.avPlayer.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(range.start, range.duration);
    NSTimeInterval loadTiemSec = CMTimeGetSeconds(loadTime);
    
    return  (loadTiemSec / self.duration);
}

#pragma mark - methods
- (void)clearObserver
{
    [self.avPlayer.currentItem removeObserver:self forKeyPath:playStatus];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:playLikelyToKeepUp];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playInterupt {
    NSLog(@"播放被打断");
    self.remoteAudioPlayerState = RemoteAudioPlayerStatePause;
}

- (void)playEnd {
    NSLog(@"播放完成");
    self.remoteAudioPlayerState = RemoteAudioPlayerStateStopped;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if([keyPath isEqualToString:playStatus]) {
        AVPlayerItemStatus status =  [change[NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerItemStatusUnknown:{
                NSLog(@"资源无效");
                self.remoteAudioPlayerState = RemoteAudioPlayerStateFailed;
                break;
            }
            case AVPlayerItemStatusReadyToPlay:{
                NSLog(@"资源准备好了, 已经可以播放");
                [self resumePlay];
                break;
            }
            case AVPlayerItemStatusFailed:{
                NSLog(@"资源加载失败");
                self.remoteAudioPlayerState = RemoteAudioPlayerStateFailed;
                break;
            }
            default:
                break;
        }
    }
    
    if ([keyPath isEqualToString:playLikelyToKeepUp]) {
        BOOL playbackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (playbackLikelyToKeepUp) {
            NSLog(@"资源加载的可以播放了");
            // 具体要不要自动播放, 不能确定;
            // 用户手动暂停优先级, 最高 > 自动播放
            if (!_isUserPause) {
                [self resumePlay];
            }
            
        } else {
            
            NSLog(@"资源正在加载");
            self.remoteAudioPlayerState = RemoteAudioPlayerStateLoading;
        }
    }
}


@end
