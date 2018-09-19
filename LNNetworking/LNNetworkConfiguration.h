//
//  LNNetworkConfiguration.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFSecurityPolicy.h>

@interface LNNetworkConfiguration : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, strong) NSString *certificatePath;

+ (LNNetworkConfiguration *)defaultConfiguration;

@end
