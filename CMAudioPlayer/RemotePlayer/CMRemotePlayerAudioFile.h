//
//  CMRemotePlayerAudioFile.h
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMRemotePlayerAudioFile : NSObject

// 通过url返回该资源的缓存路径
+ (NSString *)cacheAudioFilePath:(NSURL *)url;

// 通过url拿到临时缓存路径
+ (NSString *)tmpAudioFilePath:(NSURL *)url;

// 判断缓存路径的是否存在
+ (BOOL)fileExists:(NSString *)path;

// 判断url对应的缓存路径文件是否存在
+ (BOOL)fileExistsWithAudioURL:(NSURL *)url;

// 通过url返回资源类型
+ (NSString *)contentTypeWithURL:(NSURL *)url;

// 通过url返回资源大小
+ (long long)fileSizeWithURL:(NSURL *)url;

// 通过url清除临时缓存
+ (void)removeTmpFileWithURL:(NSURL *)url;

// 通过url把文件移到cache文件
+ (void)moveTmpFileToCacheFileWithURL:(NSURL *)url;

@end
