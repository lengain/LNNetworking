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
    [self loadDataWithPath:path parameters:nil success:nil];
}

- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    [self loadDataWithPath:path parameters:parameters success:nil];
}

- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters complete:(void (^)(id))complete {
    [self loadDataWithPath:path parameters:parameters success:nil complete:complete];
}

- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL))block {
    [self loadDataWithPath:path parameters:parameters success:block complete:nil];
}

- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block complete:(void (^)(id))complete {
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
    self.task = [[LNNetworkManager shareManager] postPath:path parameters:parameters withBlock:^(NSDictionary *result, NSError *error) {
        [self precessResult:result error:error success:block complete:complete];
        [self requestEnd];
        self.requesting = NO;
    }];
    self.requestIdentifier = self.task.taskIdentifier;
}

- (void)resetBeginningState:(NSDictionary *)parameters {}

- (void)precessResult:(NSDictionary *)result error:(NSError *)error success:(void (^)(BOOL success))block complete:(void (^)(id))complete{
    //此类由子类重写,主要是公共信息的处理(包括异常和正常数据)
    if (error) {
        NSLog(@"error:%@",error);
        //        if (self.showErrorMessage) {
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
        //        }
        //判断,无网络,访问超时等
        if([self.delegate respondsToSelector:@selector(networkRequestRequestError:)]){
            [self.delegate networkRequestRequestError:error];
        }
        if (block) {
            block(NO);
        }
    }else{
        NSString *code = [result objectForKey:@"code"];
        NSLog(@"%@",code);
        if ([code.lowercaseString isEqualToString:@"success"]) {
            id data = [result objectForKey:@"model"];
            [self processOriginalData:data complete:complete];
            if (block) {
                block(YES);
            }
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
            if (block) {
                block(NO);
            }
        }
    }
}

- (void)requestEnd {
    [self removeCurrentRequest];
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkRequest:requestEndAllCompleted:)]) {
        [self.delegate networkRequest:self requestEndAllCompleted:self.loadedAllData];
        self.requesting = NO;
    }
}

- (void)removeCurrentRequest {
    if ([[LNNetworkManager shareManager].requestArray containsObject:self]) {
        [[LNNetworkManager shareManager].requestArray removeObject:self];
    }
}

- (void)processOriginalData:(id)data complete:(void (^)(id))complete {
    if (complete) {
        complete(data);
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
    return [NSString stringWithFormat:@"%@,requestIdentifier:%ld,absoluteURLString:%@",[super description],self.requestIdentifier,self.absoluteURLString];
}

- (void)dealloc {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - class methods

+ (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL))block {
    [[self class] loadDataWithPath:path parameters:parameters success:block complete:nil];
}

+ (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL))block complete:(void (^)(id))complete {
    [[self class] loadDataWithDelegate:nil path:path parameters:parameters success:block complete:complete];
}

+ (void)loadDataWithDelegate:(id<LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL))block complete:(void (^)(id))complete {
    LNNetworkRequest *request = [[[self class] alloc] init];
    request.delegate = delegate;
    [request loadDataWithPath:path parameters:parameters success:block complete:complete];
}

+ (void)loadDataWithDelegate:(id<LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(NSDictionary *)parameters {
    LNNetworkRequest *request = [[[self class] alloc] init];
    request.delegate = delegate;
    [request loadDataWithPath:path parameters:parameters success:nil complete:nil];
}


@end
