//
//  LNRequestDelegateViewController.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/27.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNRequestDelegateViewController.h"
#import "LNAPIOpenInfomationListRequest.h"
#import "SVProgressHUD.h"
@interface LNRequestDelegateViewController ()

@end

@implementation LNRequestDelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self loadData];
}

- (void)loadData {
    [LNAPIOpenInfomationModelListRequest requestInfomationListWithDelegate:self parameters:@{@"page":@"1"}];
}

#pragma mark - LNNetworkRequestDelegate

- (void)networkRequestBegainRequest {
    [SVProgressHUD show];
}

- (void)networkRequest:(LNNetworkRequest *)networkRequest data:(id)data {
    [SVProgressHUD dismiss];
    NSLog(@"%@",data);
}

- (void)networkRequest:(LNNetworkRequest *)networkRequest requestEndAllCompleted:(BOOL)completed {
    [SVProgressHUD dismiss];
}


- (void)networkRequestRequestError:(NSError *)error {
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
