//
//  LNNetworkManager.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNNetworkManager.h"

@interface LNNetworkManager()

@property (nonatomic, strong, readwrite) AFHTTPSessionManager *sessionManager;

@end

@implementation LNNetworkManager

+ (LNNetworkManager *)shareManager {
    static LNNetworkManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[LNNetworkManager alloc] init];
        [shareManager configureNetworkManager:[LNNetworkConfiguration defaultConfiguration]];
    });
    return shareManager;
}

- (void)configureNetworkManager:(LNNetworkConfiguration *)configuration {
    if (!_requestArray) {
        _requestArray = [[NSMutableArray alloc] init];
    }
    [self.requestArray removeAllObjects];
    
    [self.sessionManager setValue:configuration.baseURL forKey:@"baseURL"];
    self.sessionManager.securityPolicy = configuration.securityPolicy;
}

#pragma mark - Request

- (NSURLSessionDataTask *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *result, NSError *error))block {
    NSDictionary *processedDictionary;
    if (self.interceptor && [self.interceptor respondsToSelector:@selector(manager:processParameters:)]) {
        processedDictionary = [self.interceptor manager:self processParameters:parameters];
    }else {
        processedDictionary = parameters;
    }
    return [self.sessionManager GET:path parameters:processedDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = (NSDictionary *)responseObject;
        }else if([responseObject isKindOfClass:[NSData class]]){
            NSData *_data = responseObject;
            id _json = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
            result = [NSDictionary dictionaryWithDictionary:_json];
        }
        if (block) {
            block(result,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block([NSDictionary dictionary],error);
        }
    }];
}

- (NSURLSessionDataTask *)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *result, NSError *error))block {
    NSDictionary *processedDictionary;
    if (self.interceptor && [self.interceptor respondsToSelector:@selector(manager:processParameters:)]) {
        processedDictionary = [self.interceptor manager:self processParameters:parameters];
    }else {
        processedDictionary = parameters;
    }
    return [self.sessionManager POST:path parameters:processedDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = (NSDictionary *)responseObject;
        }else if([responseObject isKindOfClass:[NSData class]]){
            NSData *_data = responseObject;
            id _json = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
            result = [NSDictionary dictionaryWithDictionary:_json];
        }
        if (block) {
            block(result,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block([NSDictionary dictionary],error);
        }
    }];
}

#pragma mark - Methos

- (void)cancleAllRequest {
    [self.requestArray removeAllObjects];
    [self.sessionManager invalidateSessionCancelingTasks:YES];
}

- (void)cancleRequestWithIdentifier:(NSUInteger)identifier {
    for (NSURLSessionDataTask *task in self.sessionManager.tasks) {
        if (task.taskIdentifier == identifier) {
            [task cancel];
            for (NSInteger flag = 0; flag < self.requestArray.count; flag ++) {
                LNNetworkRequest *request = self.requestArray[flag];
                if ([request valueForKey:@"task"] == task) {
                    [self.requestArray removeObject:request];
                    break;
                }
            }
            break;
        }
    }
}


#pragma mark - Getters Setters

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    }
    return _sessionManager;
}

@end
