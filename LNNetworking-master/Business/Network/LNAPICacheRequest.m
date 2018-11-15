//
//  LNAPICacheRequest.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/11/15.
//  Copyright © 2018 LN. All rights reserved.
//

#import "LNAPICacheRequest.h"

@implementation LNAPICacheRequest

+ (void)requestInfomationListComplete:(void (^)(id _Nonnull))complete {
    [LNAPICacheRequest loadDataWithPath:@"/satinGodApi" parameters:@{@"type":@(1),@"page":@(1)} callBack:^(BOOL success, id  _Nullable result) {
        complete(result);
    }];
}

- (BOOL)shouldCache {
    return YES;
}

- (NSTimeInterval)expiryInverval {
    return 60;
}

@end
