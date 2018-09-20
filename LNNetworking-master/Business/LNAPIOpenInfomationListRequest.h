//
//  LNAPIOpenInfomationListRequest.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNBaseNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNAPIOpenInfomationListRequest : LNBaseNetworkRequest

+ (void)requestInfomationListCallBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;
+ (void)requestInfomationListComplete:(void (^)(id result))complete;

@end

NS_ASSUME_NONNULL_END
