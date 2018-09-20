//
//  LNBaseNetworkRequest.m
//  LNNetworking-master
//
//  Created by 童玉龙 on 2018/9/19.
//  Copyright © 2018年 LN. All rights reserved.
//

#import "LNBaseNetworkRequest.h"
#import "LNNetworkManager.h"
@implementation LNBaseNetworkRequest

//https://www.apiopen.top/satinGodApi?type=1&page=1

- (void)analyzeResult:(id)result error:(NSError *)error callBack:(void (^)(BOOL, id _Nullable))callBack {
    if (error) {
        NSLog(@"error:%@",error);
        //        if (self.showErrorMessage) {
        NSString *LocalizedDescription = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        if (LocalizedDescription && LocalizedDescription.length) {
            NSLog(@"NSLocalizedDescription:%@",LocalizedDescription);
        }else {
            NSString *DebugDescription = [error.userInfo objectForKey:@"NSDebugDescription"];
            if (DebugDescription && DebugDescription.length) {
                NSLog(@"NSDebugDescription:%@",DebugDescription);
            }else {
                NSLog(@"无网络连接");
            }
        }
        //判断,无网络,访问超时等
        if([self.delegate respondsToSelector:@selector(networkRequestRequestError:)]){
            [self.delegate networkRequestRequestError:error];
        }
        if (callBack) {
            callBack(NO,nil);
        }
    }else{
        NSNumber *code = [result objectForKey:@"code"];
        NSLog(@"%@",code);
        if (code.intValue == 200) {
            id data = [result objectForKey:@"data"];
            [self processData:data callBack:callBack];
        }else{
            NSString *message = [result objectForKey:@"msg"];
            if (message && message.length) {
                NSLog(@"message->:%@",message);
            }else{
                NSString *code = [result objectForKey:@"code"];
                if (code && code.length) {
                    NSString *uppercaseCode = [code uppercaseString];
                    if ([uppercaseCode isEqualToString:@"ERR_ERR_FLOW_LIMIT"]) {
                        NSLog(@"服务器限流");
                    }else if ([uppercaseCode isEqualToString:@"ERR_SYS"]){
                        NSLog(@"系统异常");
                    }else if ([uppercaseCode isEqualToString:@"ERR_TOKEN_EXPIRED"]){
                        NSLog(@"未知错误!");
                    }
                }else{
                    NSLog(@"未知错误!");
                }
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(networkRequestRequestError:)]){
                NSError *myError = [[NSError alloc] initWithDomain:[LNNetworkManager shareManager].sessionManager.baseURL.absoluteString code:LNNetworkRequestErrorTypeServeBad userInfo:@{NSLocalizedDescriptionKey:message}];
                [self.delegate networkRequestRequestError:myError];
            }
            if (callBack) {
                callBack(NO,nil);
            }
        }
    }
}

@end
