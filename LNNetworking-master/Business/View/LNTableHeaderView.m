//
//  LNTableHeaderView.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/27.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNTableHeaderView.h"
#import "LNNetworking.h"
#import "SVProgressHUD.h"
@implementation LNTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.refreshButton];
        [self.titleLabel setFrame:CGRectMake(15, 0, 250, 44)];
        [self.refreshButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 0, 50, 44)];
        [self refreshButtonAction:nil];
    }
    return self;
}

- (void)refreshButtonAction:(UIButton *)button {
    [SVProgressHUD show];
    [[LNNetworkManager shareManager].cache cacheSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        [SVProgressHUD dismiss];
        CGFloat cacheSize = totalSize/1000.f;
        self.titleLabel.text = [NSString stringWithFormat:@"cache:%.2fkb,fileCount:%ld",cacheSize,fileCount];
    }];
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor darkGrayColor];
    }
    return _titleLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _refreshButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
