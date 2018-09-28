//
//  LNBaseModel.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/27.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LNBaseModel : NSObject

#if DEBUG

+ (NSDictionary *)modelCustomPropertyMapper;

+ (NSDictionary *)modelContainerPropertyGenericClass;

+ (NSArray *)modelPropertyBlacklist;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;
#endif

@end

NS_ASSUME_NONNULL_END
