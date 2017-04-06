//
//  NSURL+Custom.m
//  CMAudioPlayer
//
//  Created by 蔡明 on 2017/4/6.
//  Copyright © 2017年 com.baleijia. All rights reserved.
//

#import "NSURL+Custom.h"

@implementation NSURL (Custom)

- (NSURL *)customURL
{
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"custom";
    return compents.URL;
}

- (NSURL *)httpURL
{
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}


@end
