//
//  ViewController.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "ViewController.h"
#import "LNAPIOpenInfomationListRequest.h"
#import "LNTableHeaderView.h"
#import "LNRequestDelegateViewController.h"
#import "LNAPICacheRequest.h"
@interface ViewController ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ViewController

static NSString *UITableViewCellReuseId = @"ViewController.UITableViewCell";
static NSString *LNTableHeaderViewReuseId = @"ViewController.LNTableHeaderView";

- (NSArray *)titleArray {
    return @[@"Normal Request",
             @"Delegate",
             @"Cache Request",
             @"Judge Result",
             ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[LNTableHeaderView class] forHeaderFooterViewReuseIdentifier:LNTableHeaderViewReuseId];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LNTableHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:LNTableHeaderViewReuseId];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellReuseId];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
            case 0:{
                [LNAPIOpenInfomationListRequest requestInfomationListCallBack:^(BOOL success, id _Nullable result) {
                    if (result) {
                        NSLog(@"LNAPIOpenInfomationListRequest:请求成功");
                    }
                }];
            }
            break;
            case 1:{
                LNRequestDelegateViewController *delegateViewControler = [[LNRequestDelegateViewController alloc] init];
                delegateViewControler.title = @"Delegate";
                [self.navigationController pushViewController:delegateViewControler animated:YES];
            }
            break;
            case 2:{
                [LNAPICacheRequest requestInfomationListComplete:^(id  _Nonnull result) {
                    if (result) {
                        NSLog(@"LNAPIOpenInfomationListRequest:请求成功");
                    }
                }];
            }
            break;
            case 3:{
                [LNAPIJudgeRequest requestWithJudgeBlock:^(BOOL success) {
                    if (success) {
                        NSLog(@"Request Success");
                    }else {
                        NSLog(@"Request File");
                    }
                }];
            }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
