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
    [LNAPIOpenInfomationListRequest loadDataWithPath:@"/satinGodApi" parameters:@{@"type":@(1),@"page":@(1)} callBack:callBack];
}

+ (void)requestInfomationListComplete:(void (^)(id result))complete {
    [LNAPIOpenInfomationListRequest loadDataWithPath:@"/satinGodApi" parameters:@{@"type":@(1),@"page":@(1)} callBack:^(BOOL success, id  _Nullable result) {
        complete(result);
    }];
}

@end

#import "LNOpenInfomationItemModel.h"

@implementation LNAPIOpenInfomationModelListRequest

+ (void)requestInfomationListWithDelegate:(id<LNNetworkRequestDelegate>)delegate parameters:(NSDictionary *)parameters {
    [LNAPIOpenInfomationModelListRequest loadDataWithDelegate:delegate path:@"/satinGodApi" parameters:parameters];
}

- (void)processData:(id)data callBack:(void (^)(BOOL, id _Nullable))callBack {
    NSArray *dataArray = [NSArray yy_modelArrayWithClass:[LNOpenInfomationItemModel class] json:data];
    [super processData:dataArray callBack:callBack];
}

@end


@implementation LNAPIJudgeRequest

+ (void)requestWithJudgeBlock:(void (^)(BOOL success))block {
    [LNAPIJudgeRequest loadDataWithPath:@"/satinGodApi" parameters:nil success:block];
}

@end
