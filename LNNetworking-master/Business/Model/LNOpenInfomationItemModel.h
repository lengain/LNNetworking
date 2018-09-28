//
//  LNOpenInfomationItemModel.h
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/27.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNOpenInfomationItemModel : LNBaseModel

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger comment;

@end

NS_ASSUME_NONNULL_END
