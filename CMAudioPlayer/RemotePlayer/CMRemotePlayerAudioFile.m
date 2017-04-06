//
//  CMRemotePlayerAudioFile.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "CMRemotePlayerAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmp NSTemporaryDirectory()

@implementation CMRemotePlayerAudioFile

+ (NSString *)cacheAudioFilePath:(NSURL *)url
{
    return [kCache stringByAppendingPathComponent:url.lastPathComponent];
}

+ (NSString *)tmpAudioFilePath:(NSURL *)url
{
    return [kTmp stringByAppendingPathComponent:url.lastPathComponent];
}

+ (BOOL)fileExists:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+ (BOOL)fileExistsWithAudioURL:(NSURL *)url
{
    return [self fileExists:[self cacheAudioFilePath:url]];
    
}

+ (NSString *)contentTypeWithURL:(NSURL *)url
{
    // 拿到缓存路径扩展名
    NSString *fileExtension = [self cacheAudioFilePath:url].pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    // C语言对象转成OC对象, C语言对象在ARC环境下不会自动释放,需要手动释放
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

+ (long long)fileSizeWithURL:(NSURL *)url
{
    // 拿到缓存路径
    NSString *path = [self cacheAudioFilePath:url];
    // 拿到资源信息
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    // 返回资源大小
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)removeTmpFileWithURL:(NSURL *)url {
    // 拿到临时缓存路径
    NSString *tmp = [self tmpAudioFilePath:url];
    BOOL isDirectory;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmp isDirectory:&isDirectory]) {
        
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:tmp error:nil];
        }
    }
}

+ (void)moveTmpFileToCacheFileWithURL:(NSURL *)url {
    
    NSString *tmp = [self tmpAudioFilePath:url];
    NSString *cache = [self cacheAudioFilePath:url];
    if ([self fileExists:tmp]) {
        [[NSFileManager defaultManager] moveItemAtPath:tmp toPath:cache error:nil];
    }
}

@end
