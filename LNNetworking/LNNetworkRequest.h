//
//  LNNetworkRequest.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNNetworkingEnumHeader.h"
#import <AFNetworking/AFURLRequestSerialization.h>
/*
 综述:
 LNNetworkRequest 用来主要用来发起请求,监听请求状态,接收请求结果,处理缓存逻辑,初步处理数据.
 它是LNNetworking的核心类之一.
 LNNetworking是围绕AFNetworking 3.2.1 来设计.
 设计目的:
 1.能够达到仅仅一次配置xxx 即可快速发起请求.
 2.支持Get Post Post(上传数据) Head Put Patch Delete
 3.支持缓存,可配置过期时间等
 4.支持Delegate,Block两种回调策略,可自由配置
 5.支持返回数据为模型转换后的对象
 */

typedef NS_ENUM(NSInteger,LNNetworkRequestErrorType) {
    LNNetworkRequestErrorTypeNoNetWork = 0,
    LNNetworkRequestErrorTypeNoData = 1,
    LNNetworkRequestErrorTypeServeBad = 2,
};

NS_ASSUME_NONNULL_BEGIN

@class LNNetworkRequest;
@protocol LNNetworkRequestDelegate <NSObject>

@optional
- (void)networkRequestBegainRequest;
- (void)networkRequestRepeatRequestFail;
- (void)networkRequestRequestError:(NSError *)error;
- (void)networkRequest:(LNNetworkRequest *)networkRequest data:(id)data;
- (void)networkRequest:(LNNetworkRequest *)networkRequest precessResult:(NSDictionary *)result error:(NSError *)error success:(void (^)(BOOL success))block;
- (void)networkRequestLoadedAllData;
- (void)networkRequest:(LNNetworkRequest *)networkRequest requestEndAllCompleted:(BOOL)completed;//if completed is YES,load All data

@end


@interface LNNetworkRequest : NSObject

@property (nonatomic, weak) id<LNNetworkRequestDelegate> delegate;
@property (nonatomic, weak) NSURLSessionDataTask *task;
@property (nonatomic, assign) NSUInteger requestIdentifier;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *absoluteURLString;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL requesting;
@property (nonatomic, assign) BOOL loadedAllData;
@property (nonatomic, strong) NSDictionary *extraInfomation;//user-defined extra infomation
@property (nonatomic, strong) id responseData;

/***配置信息****/
/**
 Request method,default is post; 请求方式 默认post
 */
@property (nonatomic, assign, readonly) LNNetworkRequestMethod requestMethod;

/**
 Is should cache, default is NO;是否使用缓存。默认NO
 */
@property (nonatomic, assign, readonly) BOOL shouldCache;//"post","get"

/**
 cache time,default is 180 seconds ; 缓存保留时长，默认180秒
 */
@property (nonatomic, assign, readonly) NSTimeInterval expiryInverval;


- (instancetype)initWithDelegate:(id <LNNetworkRequestDelegate>)delegate;

- (void)loadDataWithPath:(NSString *)path;
- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters;
- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;

- (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters  constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> _Nonnull))block progress:(nullable void (^)(NSProgress * _Nullable))uploadProgress callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;

- (void)setLoadedAllData:(BOOL)loadedAllData;


/**
 此类由子类重写，用于统一数据分析处理。可在此类中，统一处理错误，根据错误执行不同的操作。

 @param result 源数据
 @param error 错误信息
 @param callBack 回调
 */
- (void)analyzeResult:(nullable id)result error:(nullable NSError *)error callBack:(nullable void (^)(BOOL success, id _Nullable data))callBack;

/**
 在函数-analyzeResult:error:callBack:执行到正确结果后，可在此函数中进一步处理数据

 @param data 数据
 @param callBack 回调
 */
- (void)processData:(id)data callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;


#pragma mark - class methods

+ (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters success:(nullable void (^)(BOOL success))block;
+ (void)loadDataWithPath:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;
+ (void)loadDataWithDelegate:(id<LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(nullable NSDictionary *)parameters;
+ (void)loadDataWithDelegate:(nullable id <LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(nullable NSDictionary *)parameters callBack:(nullable void (^)(BOOL success,id _Nullable result))callBack;


@end

NS_ASSUME_NONNULL_END
