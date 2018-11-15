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

/**
 request infomation

 @param callBack (request result, callback Data)
 */
+ (void)requestInfomationListCallBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;


/**
 request infomation

 @param complete (callback Data)
 */
+ (void)requestInfomationListComplete:(void (^)(id result))complete;

@end

@interface LNAPIOpenInfomationModelListRequest : LNBaseNetworkRequest


/**
 request infomation

 @param delegate the delegate of request
 @param parameters the parameter of request
 */
+ (void)requestInfomationListWithDelegate:(id<LNNetworkRequestDelegate>)delegate parameters:(NSDictionary *)parameters;

@end

@interface LNAPIJudgeRequest : LNBaseNetworkRequest

+ (void)requestWithJudgeBlock:(void (^)(BOOL success))block;

@end


NS_ASSUME_NONNULL_END
