//
//  LNNetworkCache.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/20.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNNetworkCacheItem : NSObject <NSCoding>

@property (nonatomic, strong, readonly) id data;

/**
 The length of vilid time, in seconds;有效时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval validTime;
/**
 The cache creates time; 缓存时的时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval cacheCreateTime;

- (instancetype)initWithData:(id)data validTime:(NSTimeInterval)validTime;

@end

@interface LNNetworkCache : NSObject

/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 Get the cache item(LNNetworkCacheItem) with key;根据key获取缓存文件

 @param key key
 @return cache 缓存文件
 */
- (LNNetworkCacheItem *)itemFromCacheWithKey:(NSString *)key;

- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key;

- (void)cleanCache;

/**
 clean cache with completion block;清理缓存文件,附带回调

 @param completionBlock 回调
 */
- (void)cleanCacheWithCompletionBlock:(nullable dispatch_block_t)completionBlock;

/**
 calculate cache file count and size;计算缓存文件数量和大小

 @param completionBlock 回调
 */
- (void)cacheSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock;

@end

NS_ASSUME_NONNULL_END
