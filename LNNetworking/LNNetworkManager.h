//
//  LNNetworkManager.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LNNetworkConfiguration.h"
#import "LNNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN
@class LNNetworkManager;

/*
 LNNetworkManager的派生类必须符合这些protocal
 */


/*************************************************************************************************/
/*                                  LNNetworkManagerInterceptor                                  */
/*************************************************************************************************/

/**
 拦截器:可对请求进行拦截处理
 */
@protocol LNNetworkManagerInterceptor <NSObject>
@optional

- (BOOL)manager:(LNNetworkManager *)manager shouldCallAPIWithParameters:(NSDictionary *)parameters;

/**
 用于所有请求发送配置前对参数进行排序,加密,配置等.最终参数用此函数处理过的参数.
 @param manager LNNetworkManager
 @param parameters 原参数
 @return 经过处理后的参数
 */
- (NSDictionary *)manager:(LNNetworkManager *)manager processParameters:(NSDictionary *)parameters;
- (void)manager:(LNNetworkManager *)manager afterCallingAPIWithParameters:(NSDictionary *)parameters;

@end


/*************************************************************************************************/
/*                                       LNNetworkManager                                        */
/*************************************************************************************************/
@interface LNNetworkManager : NSObject

@property (nonatomic, weak) id <LNNetworkManagerInterceptor> interceptor;

+ (LNNetworkManager *)shareManager;

@property (nonatomic, strong, readonly) NSMutableArray <LNNetworkRequest *> *requestArray;

/**
 加载配置,sessionManager会在加载配置时初始化
 @param configuration 配置类
 */
- (void)configureNetworkManager:(LNNetworkConfiguration *)configuration;

@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;


/**
 *  get请求
 *
 *  @param path       url路径
 *  @param parameters 参数
 *  @param block      block
 */
- (NSURLSessionDataTask *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *result, NSError *error))block;

/**
 *  post请求
 *
 *  @param path       url路径
 *  @param parameters 参数
 *  @param block      block
 */
- (NSURLSessionDataTask *)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *result, NSError *error))block;

- (void)cancleRequestWithIdentifier:(NSUInteger)identifier;

@end

NS_ASSUME_NONNULL_END