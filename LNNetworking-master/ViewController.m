//
//  ViewController.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "ViewController.h"
#import "LNAPIOpenInfomationListRequest.h"
@interface ViewController ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ViewController

static NSString *UITableViewCellReuseId = @"ViewController.UITableViewCell";

- (NSArray *)titleArray {
    return @[@"常规请求"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
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
                
            }
            break;
            case 2:{
                
            }
            break;
            case 3:{
                
            }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
