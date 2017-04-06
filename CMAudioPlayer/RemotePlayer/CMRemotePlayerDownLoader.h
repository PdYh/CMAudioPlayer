//
//  CMRemotePlayerDownLoader.h
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMRemotePlayerDownLoaderDelegate <NSObject>

- (void)remotePlayerDownLoaderReciveNewData;

@end

@interface CMRemotePlayerDownLoader : NSObject

@property (nonatomic, weak) id<CMRemotePlayerDownLoaderDelegate> delegate;

@property (nonatomic, assign) long long loadedSize;

@property (nonatomic, assign) long long offset;

@property (nonatomic, assign) long long totalSize;

@property (nonatomic, copy) NSString *contentType;

@property (nonatomic, strong) NSURL *url;

- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;

@end
