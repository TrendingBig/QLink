//
//  SetDeviceOrderView.m
//  QLink
//
//  Created by 尤日华 on 15-1-13.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import "SetDeviceOrderView.h"

#import "DataUtil.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"

@interface SetDeviceOrderView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfOrder;
@property (weak, nonatomic) IBOutlet UIButton *btnAsc;

@end

@implementation SetDeviceOrderView
-(void)awakeFromNib
{
    self.tfOrder.delegate = self;
    self.tfOrder.text = self.orderCmd;
}

- (IBAction)actionAsc:(UIButton *)sender
{
    sender.selected = !sender.selected;
}
- (IBAction)actionCancle:(id)sender
{
    [self removeFromSuperview];
}
- (IBAction)actionConfirm:(id)sender
{
    NSString *order = self.tfOrder.text;
    if ([DataUtil checkNullOrEmpty:order]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"请输入命令"];
        return;
    }
    
    NSString *inputw = self.btnAsc.selected ? @"1" : @"";
    
    NSString *sUrl = [NetworkUtil geSetDeviceOrder:_deviceId andChangeVar:order andInputw:inputw];
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *sResult = [[NSString alloc]initWithData:received encoding:[DataUtil getGB2312Code]];
    if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置成功"];
        [self removeFromSuperview];
    } else {
        NSRange range = [sResult rangeOfString:@"error"];
        if (range.location != NSNotFound)
        {
            NSArray *errorArr = [sResult componentsSeparatedByString:@":"];
            if (errorArr.count > 1) {
                [SVProgressHUD showErrorWithStatus:errorArr[1]];
                return;
            }
        } else {
            [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
        }
        return;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"登录页_输入框02.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"登录页_输入框01.png"];
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

@end
