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


static const NSInteger kDefaultCacheMaxCacheAge = 60; // 1 minute

@interface LNNetworkCache ()

@property (nonatomic, strong) NSString *diskCachePath;
@property (nonatomic, strong) NSMutableArray *customPaths;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation LNNetworkCache

- (id)init {
    return [self initWithNamespace:@"DefaultCache"];
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
        
        // Init the disk cache
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }
        
        dispatch_sync(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });
    }
    
    return self;
}

#pragma mark ImageCache

- (void)deleteCacheWithKey:(NSString *)key {
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    [self.fileManager removeItemAtPath:cachePathForKey error:nil];
}

- (LNNetworkCacheItem *)itemFromCacheWithKey:(NSString *)key {
    LNNetworkCacheItem *item = [self itemFromDiskCacheForKey:key];
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

- (LNNetworkCacheItem *)itemFromDiskCacheForKey:(NSString *)key {
    //check the disk cache...
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    LNNetworkCacheItem *diskItem = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePathForKey];
    return diskItem;
}

- (void)storeNetworkCacheItem:(LNNetworkCacheItem *)item forKey:(NSString *)key {
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
                          r[11], r[12], r[13], r[14], r[15],@".reponsedata"];
    
    return filename;
}

// Init the disk cache
- (NSString *)makeDiskCachePath:(NSString*)fullNamespace {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

- (void)cleanCache {
    [self cleanCacheWithCompletionBlock:nil];
}

- (void)cleanCacheWithCompletionBlock:(nullable dispatch_block_t)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        //枚举器预取有用的条目
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        // 枚举在缓存字典里的所有file，这个循环有两个目的：1.移除过期文件 2.存储基于大小的清理过程的文件属性
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            [self.fileManager removeItemAtURL:fileURL error:nil];

        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

- (void)cacheSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
            fileCount += 1;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}

#pragma mark - private method

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
