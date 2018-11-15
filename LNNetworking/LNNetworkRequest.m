//
//  LNNetworkRequest.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNNetworkRequest.h"
#import "LNNetworkManager.h"

@implementation LNNetworkRequest

#pragma mark - Init

- (instancetype)initWithDelegate:(id<LNNetworkRequestDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Methods

- (void)loadDataWithPath:(NSString *)path {
    [self loadDataWithPath:path parameters:nil callBack:nil];
}

- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters {
    [self loadDataWithPath:path parameters:parameters callBack:nil];
}

- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(void (^)(BOOL success,id _Nullable result))callBack{
    [self loadDataWithPath:path parameters:parameters constructingBodyWithBlock:nil progress:nil callBack:callBack];
}

- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters  constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> _Nonnull))block progress:(nullable void (^)(NSProgress * _Nullable))uploadProgress callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack {
    if (path == nil) {
        return;
    }
    self.absoluteURLString = [self packageAbsoluteURLStringWithPath:path parameters:parameters];
    if ([[LNNetworkManager shareManager].requestArray containsObject:self]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkRequestRepeatRequestFail)]) {
            [self.delegate networkRequestRepeatRequestFail];
        }
        return;
    }
    [[LNNetworkManager shareManager].requestArray addObject:self];
    if ([self.delegate respondsToSelector:@selector(networkRequestBegainRequest)]) {
        self.requesting = YES;
        [self.delegate networkRequestBegainRequest];
    }
    self.parameters = parameters;
    [self resetBeginningState:parameters];
    //cache manage;缓存判断
    if (self.shouldCache) {
        LNNetworkCacheItem *item = [[[LNNetworkManager shareManager] cache] itemFromCacheWithKey:self.absoluteURLString];
        if (item != nil) {
            [self analyzeResult:item.data error:nil callBack:callBack];
            [self requestEnd];
            return;
        }
    }
    //request;请求
    self.task = [[LNNetworkManager shareManager] requestMethod:self.requestMethod path:path parameters:parameters constructingBodyWithBlock:block progress:uploadProgress result:^(id  _Nullable result, NSError * _Nullable error) {
        //请求成功再判断是否需要缓存，请求失败则不缓存。
        if (result != nil) {
            [self networkCache:result];
        }
        [self analyzeResult:result error:error callBack:callBack];
        [self requestEnd];
    }];
    self.requestIdentifier = self.task.taskIdentifier;
}

- (void)resetBeginningState:(NSDictionary *)parameters {}

- (void)networkCache:(id)result {
    if (self.shouldCache) {
        LNNetworkCacheItem *item = [[LNNetworkCacheItem alloc] initWithData:result validTime:self.expiryInverval];
        [[LNNetworkManager shareManager].cache storeNetworkCacheItem:item forKey:self.absoluteURLString];
    }
}

- (void)analyzeResult:(id)result error:(NSError *)error callBack:(void (^)(BOOL, id _Nullable))callBack {
    //此类由子类重写,主要是公共信息的处理(包括异常和正常数据)
    if (error) {
        NSLog(@"error:%@",error);
        NSString *LocalizedDescription = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        if (LocalizedDescription && LocalizedDescription.length) {
            NSLog(@"NSLocalizedDescription:%@",LocalizedDescription);
        }else {
            NSString *DebugDescription = [error.userInfo objectForKey:@"NSDebugDescription"];
            if (DebugDescription && DebugDescription.length) {
                NSLog(@"NSDebugDescription:%@",DebugDescription);
            }else {
                NSLog(@"无网络连接");
            }
        }
        //判断,无网络,访问超时等
        if([self.delegate respondsToSelector:@selector(networkRequestRequestError:)]){
            [self.delegate networkRequestRequestError:error];
        }
        if (callBack) {
            callBack(NO,nil);
        }
    }else{
        NSString *code = [result objectForKey:@"code"];
        NSLog(@"%@",code);
        if ([code.lowercaseString isEqualToString:@"success"]) {
            id data = [result objectForKey:@"model"];
            [self processData:data callBack:callBack];
        }else{
            NSString *message = [result objectForKey:@"message"];
            if (message && message.length) {
                NSLog(@"message->:%@",message);
            }else{
                NSString *code = [result objectForKey:@"code"];
                if (code && code.length) {
                    NSString *uppercaseCode = [code uppercaseString];
                    if ([uppercaseCode isEqualToString:@"ERR_ERR_FLOW_LIMIT"]) {
                        NSLog(@"服务器限流");
                    }else if ([uppercaseCode isEqualToString:@"ERR_SYS"]){
                        NSLog(@"系统异常");
                    }else if ([uppercaseCode isEqualToString:@"ERR_TOKEN_EXPIRED"]){
                        NSLog(@"未知错误!");
                    }
                }else{
                    NSLog(@"未知错误!");
                }
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(networkRequestRequestError:)]){
                NSError *myError = [[NSError alloc] initWithDomain:[LNNetworkManager shareManager].sessionManager.baseURL.absoluteString code:LNNetworkRequestErrorTypeServeBad userInfo:@{NSLocalizedDescriptionKey:message}];
                [self.delegate networkRequestRequestError:myError];
            }
            if (callBack) {
                callBack(NO,nil);
            }
        }
    }
}

- (void)requestEnd {
    [self removeCurrentRequest];
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkRequest:requestEndAllCompleted:)]) {
        [self.delegate networkRequest:self requestEndAllCompleted:self.loadedAllData];
    }
    self.requesting = NO;
}

- (void)removeCurrentRequest {
    if ([[LNNetworkManager shareManager].requestArray containsObject:self]) {
        [[LNNetworkManager shareManager].requestArray removeObject:self];
    }
}

- (void)processData:(id)data callBack:(void (^)(BOOL, id _Nullable))callBack {
    if (callBack) {
        callBack(YES,data);
    }
    if ([self.delegate respondsToSelector:@selector(networkRequest:data:)]) {
        [self.delegate networkRequest:self data:data];
    }
    if (!self.loadedAllData && [data isKindOfClass:[NSArray class]]) {
        if (!data || [(NSArray *)data count] == 0) {
            [self setLoadedAllData:YES];
        }else {
            [self setLoadedAllData:NO];
        }
    }
}

- (NSString *)packageAbsoluteURLStringWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    NSString *pathURLString = [[NSURL URLWithString:path relativeToURL:[LNNetworkManager shareManager].sessionManager.baseURL] absoluteString];
    if (parameters) {
        return [NSString stringWithFormat:@"%@?%@",pathURLString,AFQueryStringFromParameters(parameters)];
    }else {
        return pathURLString;
    }
}

#pragma mark - override

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[LNNetworkRequest class]]) {
        return self.hash == [(LNNetworkRequest *)object hash];
    }else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.absoluteURLString.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@,requestIdentifier:%lu,absoluteURLString:%@",[super description],(unsigned long)self.requestIdentifier,self.absoluteURLString];
}

- (void)dealloc {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - class methods

+ (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters success:(nullable void (^)(BOOL))block {
    [[self class] loadDataWithPath:path parameters:parameters callBack:^(BOOL success, id  _Nullable result) {
        if (block) {
            block(success);
        }
    }];
}

+ (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(nullable void (^)(BOOL, id _Nullable))callBack {
    [[self class] loadDataWithDelegate:nil path:path parameters:parameters callBack:callBack];
}

+ (void)loadDataWithDelegate:(id<LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(nullable NSDictionary *)parameters {
    [[self class] loadDataWithDelegate:delegate path:path parameters:parameters callBack:nil];
}

+ (void)loadDataWithDelegate:(id <LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack {
    LNNetworkRequest *request = [[[self class] alloc] init];
    request.delegate = delegate;
    [request loadDataWithPath:path parameters:parameters callBack:callBack];
}

#pragma mark - Getter Setter

- (LNNetworkRequestMethod)requestMethod {
    return LNNetworkRequestMethodPost;
}

- (BOOL)shouldCache {
    return NO;
}

- (NSTimeInterval)expiryInverval {
    return 180;
}

@end
