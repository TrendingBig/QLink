//
//  SeriesNumberView.m
//  QLink
//
//  Created by 尤日华 on 15-1-16.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import "SeriesNumberView.h"
#import "DataUtil.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"

@interface SeriesNumberView()

@property (weak, nonatomic) IBOutlet UITextField *tfNumber;

@end

@implementation SeriesNumberView
- (IBAction)actionCancle:(id)sender {
    [self removeFromSuperview];
}
- (IBAction)actionConfirm:(id)sender {
    NSString *num = self.tfNumber.text;
    if ([DataUtil checkNullOrEmpty:num]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"请输入密码"];
        return;
    }
    NSString *sUrl = [NetworkUtil setNumber:num];
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *sResult = [[NSString alloc]initWithData:received encoding:[DataUtil getGB2312Code]];
    if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置成功"];
        [self removeFromSuperview];
        if (self.comfirmBlock) {
            self.comfirmBlock();
        }
    } else {
        NSRange range = [sResult rangeOfString:@"error"];
        if (range.location != NSNotFound)
        {
            NSArray *errorArr = [sResult componentsSeparatedByString:@":"];
            if (errorArr.count > 1) {
                [self removeFromSuperview];
                [SVProgressHUD showErrorWithStatus:errorArr[1]];
            }
        } else {
            [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
        }
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
