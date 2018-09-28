//
//  LNNetworkManager.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNNetworkManager.h"
#import <Objc/runtime.h>

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

- (NSURLSessionDataTask *)requestMethod:(LNNetworkRequestMethod)requestMethod path:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nonnull, NSError * _Nonnull))failure {
    return nil;
}

- (NSURLSessionDataTask *)requestMethod:(LNNetworkRequestMethod)requestMethod path:(NSString *)URLString parameters:(nullable id)parameters constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> _Nonnull))block progress:(nullable void (^)(NSProgress * _Nullable))uploadProgress result:(void (^)(id _Nullable result, NSError * _Nullable error))result {
    NSDictionary *processedDictionary;
    if (self.interceptor && [self.interceptor respondsToSelector:@selector(manager:processParameters:)]) {
        processedDictionary = [self.interceptor manager:self processParameters:parameters];
    }else {
        processedDictionary = parameters;
    }
    void (^success)(NSURLSessionDataTask * _Nonnull, id _Nonnull) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (result) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                result(responseObject,nil);
            }else if([responseObject isKindOfClass:[NSData class]]){
                NSData *sourceData = (NSData *)responseObject;
                id jsonData = [NSJSONSerialization JSONObjectWithData:sourceData options:0 error:nil];
                if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
                    result(jsonData,nil);
                }else {
                    result(responseObject,nil);
                }
            }else {
                result(responseObject,nil);
            }
        }
    };
    void (^failure)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (result) {
            result(nil,error);
        }
    };
    
    switch (requestMethod) {
            case LNNetworkRequestMethodPost:{
                if (block != nil) {
                    return [self.sessionManager POST:URLString parameters:processedDictionary constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure];
                }else {
                    return [self.sessionManager POST:URLString parameters:processedDictionary progress:uploadProgress success:success failure:failure];
                }
            }
            break;
            case LNNetworkRequestMethodGet: {
                return [self.sessionManager GET:URLString parameters:processedDictionary progress:uploadProgress success:success failure:failure];
            }
            case LNNetworkRequestMethodHead: {
                return [self.sessionManager HEAD:URLString parameters:processedDictionary success:^(NSURLSessionDataTask * _Nonnull task) {
                    result([[NSNumber alloc] initWithBool:YES],nil);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    result([[NSNumber alloc] initWithBool:NO],error);
                }];
            }
            break;
            case LNNetworkRequestMethodPut: {
                return [self.sessionManager PUT:URLString parameters:processedDictionary success:success failure:failure];
            }
            break;
            case LNNetworkRequestMethodPatch: {
                return [self.sessionManager PATCH:URLString parameters:processedDictionary success:success failure:failure];
            }
            break;
            case LNNetworkRequestMethodDelete: {
                return [self.sessionManager DELETE:URLString parameters:processedDictionary success:success failure:failure];
            }
        default:
            return nil;
            break;
    }
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

- (void)setCache:(LNNetworkCache *)cache {
    objc_setAssociatedObject(self, @selector(cache), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LNNetworkCache *)cache {
    LNNetworkCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[LNNetworkCache alloc] init];
        [self setCache:cache];
    }
    return cache;
}

@end


