//
//  LNNetworkConfiguration.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNNetworkConfiguration.h"

@implementation LNNetworkConfiguration

+ (LNNetworkConfiguration *)defaultConfiguration {
    LNNetworkConfiguration *configuration = [[LNNetworkConfiguration alloc] init];
    configuration.securityPolicy = [AFSecurityPolicy defaultPolicy];
    return configuration;
}


@end
