//
//  ReSetIpView.m
//  QLink
//
//  Created by 尤日华 on 15-1-16.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import "ReSetIpView.h"
#import "DataUtil.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "AFHTTPRequestOperation.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"

@interface ReSetIpView()

@property (weak, nonatomic) IBOutlet UITextField *tfPwd;


@end

@implementation ReSetIpView

- (IBAction)actionCancle:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)actionComfirm:(id)sender
{
    NSString *pwd = self.tfPwd.text;
    if ([DataUtil checkNullOrEmpty:pwd]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"请输入密码"];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSString *sUrl = [NetworkUtil getResetIp:pwd];
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    define_weakself;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *sResult = [[NSString alloc] initWithData:responseObject encoding:[DataUtil getGB2312Code]];
         if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
             [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置成功,重启应用后生效."];
             [weakSelf removeFromSuperview];
             [SVProgressHUD dismiss];
         } else {
             NSRange range = [sResult rangeOfString:@"error"];
             if (range.location != NSNotFound)
             {
                 NSArray *errorArr = [sResult componentsSeparatedByString:@":"];
                 if (errorArr.count > 1) {
                     [weakSelf removeFromSuperview];
                     [SVProgressHUD showErrorWithStatus:errorArr[1]];
                 }
             } else {
                 [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
                 [SVProgressHUD dismiss];
             }
         }
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD dismiss];
         [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
     }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

@end
