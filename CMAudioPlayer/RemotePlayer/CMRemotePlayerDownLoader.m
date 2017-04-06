//
//  CMRemotePlayerDownLoader.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "CMRemotePlayerDownLoader.h"
#import "CMRemotePlayerAudioFile.h"

@interface CMRemotePlayerDownLoader ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSOutputStream *outputStream; // 输出流

@end

@implementation CMRemotePlayerDownLoader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}


- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
    
    self.url = url;
    
    [self cancelAndCleanTempData];
    
    self.offset = offset;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:0];
    
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];

    [task resume];
}

- (void)cancelAndCleanTempData
{
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [CMRemotePlayerAudioFile removeTmpFileWithURL:self.url];
    
    self.loadedSize = 0;
    self.offset = 0;
    self.totalSize = 0;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.contentType = response.allHeaderFields[@"Content-Type"];
    
    NSString *rangeStr = response.allHeaderFields[@"Content-Range"];
    
    self.totalSize = [[rangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[CMRemotePlayerAudioFile tmpAudioFilePath:self.url] append:YES];
    
    [self.outputStream open];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    if ([self.delegate respondsToSelector:@selector(remotePlayerDownLoaderReciveNewData)]) {
        [self.delegate remotePlayerDownLoaderReciveNewData];
    }
    
    self.loadedSize += data.length;
    // 把数据写到临时文件
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
    
    if (error == nil) {
        
        if (self.offset == 0) {
            [CMRemotePlayerAudioFile moveTmpFileToCacheFileWithURL:self.url];
        }
    }else {
        
        NSLog(@"%@", error);
    }
}
@end
