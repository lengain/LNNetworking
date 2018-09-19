//
//  LNNetworkRequest.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 综述:
 LNNetworkRequest 用来主要用来发起请求,监听请求状态,接收请求结果,处理缓存逻辑,初步处理数据.
 它是OrangeNetwork的核心类之一.
 OrangeNetwork是围绕AFNetworking 3.1.0 来设计.
 设计目的:
 1.能够达到仅仅一次配置xxx 即可快速发起请求.
 2.重复发生请求时可以选择,是等待上一个请求返回数据后再请求,
 还是取消正在发送的请求直接请求.
 3.高度解耦
 */

typedef NS_ENUM(NSInteger,LNNetworkRequestMethod) {
    LNNetworkRequestMethodGet = 0,
    LNNetworkRequestMethodPost = 1,
};

typedef NS_ENUM(NSInteger,LNNetworkRequestErrorType) {
    LNNetworkRequestErrorTypeNoNetWork = 0,
    LNNetworkRequestErrorTypeNoData = 1,
    LNNetworkRequestErrorTypeServeBad = 2,
};


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
@property (nonatomic, assign) LNNetworkRequestMethod requestMethod;//"post","get"
@property (nonatomic, assign) BOOL requesting;
@property (nonatomic, assign) BOOL loadedAllData;
@property (nonatomic, strong) NSDictionary *extraInfomation;//user-defined extra infomation


- (instancetype)initWithDelegate:(id <LNNetworkRequestDelegate>)delegate;

- (void)loadDataWithPath:(NSString *)path;
- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters complete:(void (^)(id result))complete;
- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block;
- (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block complete:(void (^)(id result))complete;
- (void)setLoadedAllData:(BOOL)loadedAllData;

- (void)precessResult:(NSDictionary *)result error:(NSError *)error success:(void (^)(BOOL success))block complete:(void (^)(id))complete;
- (void)processOriginalData:(id)data complete:(void (^)(id))complete;

+ (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block;
+ (void)loadDataWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block complete:(void (^)(id result))complete;
+ (void)loadDataWithDelegate:(id <LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(BOOL success))block complete:(void (^)(id result))complete;
+ (void)loadDataWithDelegate:(id<LNNetworkRequestDelegate>)delegate path:(NSString *)path parameters:(NSDictionary *)parameters;


@end
