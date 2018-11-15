//
//  LNAPICacheRequest.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/11/15.
//  Copyright © 2018 LN. All rights reserved.
//

#import "LNBaseNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNAPICacheRequest : LNBaseNetworkRequest

/**
 request infomation
 
 @param complete (callback Data)
 */
+ (void)requestInfomationListComplete:(void (^)(id result))complete;

@end

NS_ASSUME_NONNULL_END
