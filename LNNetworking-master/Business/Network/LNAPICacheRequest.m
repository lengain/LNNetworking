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
    [LNAPICacheRequest loadDataWithPath:@"/users/lengain/repos" parameters:nil callBack:^(BOOL success, id  _Nullable result) {
        complete(result);
    }];
}

- (LNNetworkRequestMethod)requestMethod {
    return LNNetworkRequestMethodGet;
}

- (BOOL)shouldCache {
    return YES;
}

- (NSTimeInterval)expiryInverval {
    return 60;
}

@end
