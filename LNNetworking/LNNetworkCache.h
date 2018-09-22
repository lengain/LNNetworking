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

@property (assign, nonatomic) NSUInteger maxCacheSize;

- (LNNetworkCacheItem *)itemFromCacheWithKey:(NSString *)key;
- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key;
- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key toDisk:(BOOL)toDisk;

@end

NS_ASSUME_NONNULL_END
