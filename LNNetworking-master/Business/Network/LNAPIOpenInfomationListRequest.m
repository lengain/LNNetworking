//
//  LNAPIOpenInfomationListRequest.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNAPIOpenInfomationListRequest.h"

@implementation LNAPIOpenInfomationListRequest

+ (void)requestInfomationListCallBack:(nullable void (^)(BOOL success,id _Nullable result))callBack {
    [LNAPIOpenInfomationListRequest loadDataWithPath:@"/users/lengain/repos" parameters:nil callBack:callBack];
}

+ (void)requestInfomationListComplete:(void (^)(id result))complete {
    [LNAPIOpenInfomationListRequest loadDataWithPath:@"/users/lengain/repos" parameters:nil callBack:^(BOOL success, id  _Nullable result) {
        complete(result);
    }];
}

- (LNNetworkRequestMethod)requestMethod {
    return LNNetworkRequestMethodGet;
}

@end

#import "LNOpenInfomationItemModel.h"

@implementation LNAPIOpenInfomationModelListRequest

+ (void)requestInfomationListWithDelegate:(id<LNNetworkRequestDelegate>)delegate parameters:(NSDictionary *)parameters {
    [LNAPIOpenInfomationModelListRequest loadDataWithDelegate:delegate path:@"/users/lengain/repos" parameters:parameters];
}

- (void)processData:(id)data callBack:(void (^)(BOOL, id _Nullable))callBack {
    NSArray *dataArray = [NSArray yy_modelArrayWithClass:[LNOpenInfomationItemModel class] json:data];
    [super processData:dataArray callBack:callBack];
}

- (LNNetworkRequestMethod)requestMethod {
    return LNNetworkRequestMethodGet;
}

@end


@implementation LNAPIJudgeRequest

+ (void)requestWithJudgeBlock:(void (^)(BOOL success))block {
    [LNAPIJudgeRequest loadDataWithPath:@"/users/lengain/repos" parameters:nil success:block];
}

- (LNNetworkRequestMethod)requestMethod {
    return LNNetworkRequestMethodGet;
}

@end
