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

//仅仅返回result
+ (void)requestInfomationListComplete:(void (^)(id result))complete {
    [LNAPIOpenInfomationListRequest loadDataWithPath:@"/satinGodApi" parameters:@{@"type":@(1),@"page":@(1)} callBack:^(BOOL success, id  _Nullable result) {
        complete(result);
    }];
}

@end
