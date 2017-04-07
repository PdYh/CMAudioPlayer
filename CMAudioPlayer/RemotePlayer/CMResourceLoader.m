//
//  CMResourceLoader.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "CMResourceLoader.h"

#import "NSURL+Custom.h"
#import "CMRemotePlayerAudioFile.h"
#import "CMRemotePlayerDownLoader.h"
@interface CMResourceLoader ()<CMRemotePlayerDownLoaderDelegate>

@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *loadRequests; // 下载请求数组

@property (nonatomic, strong) CMRemotePlayerDownLoader *downLoader;

@end

@implementation CMResourceLoader
- (CMRemotePlayerDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader = [[CMRemotePlayerDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray *)loadRequests
{
    if (!_loadRequests) {
        _loadRequests = [NSMutableArray array];
    }
    return _loadRequests;
}

/**
  处理下载的资源加载请求
 */
- (void)handleAllLoadingRequests {
    
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadRequests) {
        
        if ([loadingRequest isFinished] || [loadingRequest isCancelled]) {
            [deleteRequests addObject:loadingRequest];
            
            continue;
        }
        
        loadingRequest.contentInformationRequest.contentType = self.downLoader.contentType;
        loadingRequest.contentInformationRequest.contentLength = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
        NSData *data = [NSData dataWithContentsOfFile:[CMRemotePlayerAudioFile tmpAudioFilePath:self.downLoader.url] options:NSDataReadingMappedIfSafe error:nil];
        
        if (data.length == 0) { // 代表临时缓存文件被删除 ,去cache文件找
            data = [NSData dataWithContentsOfFile:[CMRemotePlayerAudioFile cacheAudioFilePath:self.downLoader.url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        if (data.length == 0) { // cache文件没有直接结束循环 重新去下载
            break;
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        if (loadingRequest.dataRequest.currentOffset != 0) {
            requestOffset = loadingRequest.dataRequest.currentOffset;
        }
        
        long long requestLength = loadingRequest.dataRequest.requestedLength;
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength);
        
        // 抛出的数据
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        // 开始响应给播放器
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 完成
        if (responseLength == requestLength) { // 请求长度等于响应长度 代表该次请求完毕
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest]; // 把已完成的请求加入的待删除数组
        }
        
    }
    // 移除/删除已经结束的请求
    [self.loadRequests removeObjectsInArray:deleteRequests];
}

/*
    处理缓存资源
 */
#warning mark - Has wrong when audio cache play ,This error occurs when the user stops playing the audio, and when the user plays the audio again it will fail

- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURL *url = loadingRequest.request.URL;
    
    NSData *data = [NSData dataWithContentsOfFile:[CMRemotePlayerAudioFile cacheAudioFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    loadingRequest.contentInformationRequest.contentType = [CMRemotePlayerAudioFile contentTypeWithURL:url];
    
    loadingRequest.contentInformationRequest.contentLength = [CMRemotePlayerAudioFile fileSizeWithURL:url];

    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    // 该次请求的数据
    [loadingRequest.dataRequest respondWithData:subData];
    // 结束该次请求
    [loadingRequest finishLoading];
    
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.loadRequests addObject:loadingRequest];
    
    NSURL *url = loadingRequest.request.URL;
    
    // 处理本地缓存的请求资源
    if ([CMRemotePlayerAudioFile fileExistsWithAudioURL:url]) {
        
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // 下载无缓存资源
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;

    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downLoadWithURL:[url httpURL] offset:requestOffset];
        return YES;
    }
    
    // 判断下载请求是否在下载区间内,如不在,重新下载
    if (requestOffset > self.downLoader.offset + self.downLoader.loadedSize + 666 || requestOffset < self.downLoader.offset) {
        [self.downLoader downLoadWithURL:[url httpURL] offset:requestOffset];
        return YES;
    }
    
    // 处理下载的资源
    [self handleAllLoadingRequests];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [loadingRequest finishLoading];
}

#pragma mark - CMRemotePlayerDownLoaderDelegate

- (void)remotePlayerDownLoaderReciveNewData
{
    [self handleAllLoadingRequests];
}
@end
