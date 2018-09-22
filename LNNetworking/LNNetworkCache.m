//
//  LNNetworkCache.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/20.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNNetworkCache.h"
#import <UIKit/UIApplication.h>
#import <CommonCrypto/CommonDigest.h>

@implementation LNNetworkCacheItem

- (instancetype)initWithData:(id)data validTime:(NSTimeInterval)validTime {
    self = [super init];
    if (self) {
        _data = data;
        _validTime = validTime;
        _cacheCreateTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return self;
    if (self == (id)kCFNull) return self;
    _data = [aDecoder decodeObjectForKey:@"data"];
    _cacheCreateTime = [aDecoder decodeDoubleForKey:@"cacheCreateTime"];
    _validTime = [aDecoder decodeDoubleForKey:@"validTime"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
    if (self == (id)kCFNull) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
    NSParameterAssert(_data);
    NSParameterAssert(_cacheCreateTime);
    NSParameterAssert(_validTime);
    [aCoder encodeObject:_data forKey:@"data"];
    [aCoder encodeDouble:_cacheCreateTime forKey:@"cacheCreateTime"];
    [aCoder encodeDouble:_validTime forKey:@"validTime"];
}

@end

@interface LNAutoPurgeCache : NSCache
@end

@implementation LNAutoPurgeCache

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end


static const NSInteger kDefaultCacheMaxCacheAge = 60; // 1 minute

@interface LNNetworkCache ()

@property (nonatomic, strong) LNAutoPurgeCache *memoryCache;
@property (nonatomic, strong) NSString *diskCachePath;
@property (nonatomic, strong) NSMutableArray *customPaths;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation LNNetworkCache

- (id)init {
    return [self initWithNamespace:@"default"];
}

- (id)initWithNamespace:(NSString *)ns {
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}

- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
    if ((self = [super init])) {
        NSString *fullNamespace = [@"com.lengain.LNNetworking." stringByAppendingString:ns];
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.lengain.LNNetworking", DISPATCH_QUEUE_SERIAL);
        
        // Init default values
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        
        // Init the memory cache
        _memoryCache = [[LNAutoPurgeCache alloc] init];
        _memoryCache.name = fullNamespace;
        
        // Init the disk cache
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }
        
//        // memory cache enabled
//        _shouldCacheImagesInMemory = YES;
//
//        // Disable iCloud
//        _shouldDisableiCloud = YES;
        
        dispatch_sync(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });
        
#if TARGET_OS_IOS
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
    }
    
    return self;
}

#pragma mark ImageCache

- (void)deleteCacheWithKey:(NSString *)key {
    [self.memoryCache removeObjectForKey:key];
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    [self.fileManager removeItemAtPath:cachePathForKey error:nil];
}

- (LNNetworkCacheItem *)itemFromCacheWithKey:(NSString *)key {
    LNNetworkCacheItem *item = [self itemFromMemoryCacheForKey:key];
    if (!item) {
        item = [self itemFromDiskCacheForKey:key];
    }
    if (item != nil) {
        NSTimeInterval cacheTimeLength = [[NSDate date] timeIntervalSince1970] - item.cacheCreateTime;
        if (cacheTimeLength > 0 && cacheTimeLength < item.validTime) {
            return item;
        }else {//过期删除
            [self deleteCacheWithKey:key];
            return nil;
        }
    }
    return item;
}

- (LNNetworkCacheItem *)itemFromMemoryCacheForKey:(NSString *)key {
    return [self.memoryCache objectForKey:key];
}

- (LNNetworkCacheItem *)itemFromDiskCacheForKey:(NSString *)key {
    // First check the in-memory cache...
    LNNetworkCacheItem *item = [self itemFromMemoryCacheForKey:key];
    if (item) {
        return item;
    }
    // Second check the disk cache...
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    LNNetworkCacheItem *diskItem = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePathForKey];
    if (diskItem) {
        [self.memoryCache setObject:diskItem forKey:key];
    }
    return diskItem;
}

- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key {
    [self storeNetworkCacheItem:item forKey:key toDisk:YES];
}

- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key toDisk:(BOOL)toDisk {
    if (!item || !key) {
        return;
    }
    [self.memoryCache setObject:item forKey:key];
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            if (![self.fileManager fileExistsAtPath:self.diskCachePath]) {
                [self.fileManager createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            // get cache Path for key
            NSString *cachePathForKey = [self defaultCachePathForKey:key];
            // transform to NSUrl
            [NSKeyedArchiver archiveRootObject:item toFile:cachePathForKey];
        });
    }
}


- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}

// Init the disk cache
- (NSString *)makeDiskCachePath:(NSString*)fullNamespace {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

#pragma mark - private method

- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}

- (void)cleanDisk {
    
}

- (void)backgroundCleanDisk {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
