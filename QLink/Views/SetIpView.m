//
//  SetIpView.m
//  QLink
//
//  Created by 尤日华 on 15-1-10.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import "SetIpView.h"
#import "DataUtil.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "SVProgressHUD.h"
#import "NetworkUtil.h"
#import "AFHTTPRequestOperation.h"
#import "DataUtil.h"

@interface SetIpView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnTcp;
@property (weak, nonatomic) IBOutlet UIButton *btnUdp;
@property (weak, nonatomic) IBOutlet UITextField *tfCode1;
@property (weak, nonatomic) IBOutlet UITextField *tfCode2;
@property (weak, nonatomic) IBOutlet UITextField *tfCode3;
@property (weak, nonatomic) IBOutlet UITextField *tfCode4;
@property (weak, nonatomic) IBOutlet UITextField *tfCode5;

@end

@implementation SetIpView

-(void)awakeFromNib
{
    self.tfCode1.delegate = self;
    self.tfCode2.delegate = self;
    self.tfCode3.delegate = self;
    self.tfCode4.delegate = self;
    self.tfCode5.delegate = self;
}

-(void)fillContent:(NSString *)deviceId
{
    NSArray *array = [SQLiteUtil getOrderListByDeviceId:deviceId];
    if (array.count <= 0) {
        Control *control = [SQLiteUtil getControlObj];
        NSArray *array = [control.Ip componentsSeparatedByString:@"."];
        if (array.count > 3) {
            self.tfCode1.text = array[0];
            self.tfCode2.text = array[1];
            self.tfCode3.text = array[2];
        }
    } else {
        Order *order = [array firstObject];
        NSArray *arrayOrderTips = [order.Address componentsSeparatedByString:@":"];
        
        if ([arrayOrderTips count] > 2) {
            if ( [[arrayOrderTips[0] lowercaseString] isEqualToString:@"tcp"]) {
                self.btnTcp.selected = YES;
                self.btnUdp.selected = NO;
            } else {
                self.btnUdp.selected = YES;
                self.btnTcp.selected = NO;
            }
            NSArray *ipAr = [arrayOrderTips[1] componentsSeparatedByString:@"."];
            self.tfCode1.text = ipAr[0];
            self.tfCode2.text = ipAr[1];
            self.tfCode3.text = ipAr[2];
            self.tfCode4.text = ipAr[3];
            self.tfCode5.text = arrayOrderTips[2];
        }
    }
}

- (IBAction)btnTcpPressed:(UIButton *)sender {
    self.btnUdp.selected = NO;
    sender.selected = YES;
}
- (IBAction)btnUdpPressed:(UIButton *)sender
{
    self.btnTcp.selected = NO;
    sender.selected = YES;
}

//取消
- (IBAction)btnCanclePressed:(id)sender
{
    if (self.cancleBlock) {
        self.cancleBlock();
    }
}
//确定
- (IBAction)btnComfirmPressed:(id)sender
{
    NSString *code1 = self.tfCode1.text;
    NSString *code2 = self.tfCode2.text;
    NSString *code3 = self.tfCode3.text;
    NSString *code4 = self.tfCode4.text;
    NSString *code5 = self.tfCode5.text;
    
    if ([DataUtil checkNullOrEmpty:code1] ||
        [DataUtil checkNullOrEmpty:code2] ||
        [DataUtil checkNullOrEmpty:code3] ||
        [DataUtil checkNullOrEmpty:code4] ||
        [DataUtil checkNullOrEmpty:code5]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"请输入完整信息"];
        return;
    }
    if (![DataUtil isPureInt:code1] ||
        ![DataUtil isPureInt:code2] ||
        ![DataUtil isPureInt:code3] ||
        ![DataUtil isPureInt:code4] ||
        ![DataUtil isPureInt:code5]) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"输入信息包含非数字"];
        return;
    }
    if (([code1 integerValue] > 255 || [code1 integerValue] < 0) ||
        ([code2 integerValue] > 255 || [code2 integerValue] < 0) ||
        ([code3 integerValue] > 255 || [code3 integerValue] < 0) ||
        ([code4 integerValue] > 255 || [code4 integerValue] < 0) ||
        ([code5 integerValue] > 65534 || [code5 integerValue] < 300)) {
        [UIAlertView alertViewWithTitle:@"温馨提示" message:@"请输入合理的\nIP或端口号范围"];
        return;
    }
    
    if (self.comfirmBlock) {
        NSString *ip = [NSString stringWithFormat:@"%@.%@.%@.%@:%@",code1,code2,code3,code4,code5];
        if (self.btnTcp.selected) {
            ip = [NSString stringWithFormat:@"TCP:%@",ip];
        } else {
            ip = [NSString stringWithFormat:@"UDP:%@",ip];
        }
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        NSString *sUrl = [NetworkUtil geSetDeviceIp:_deviceId andChangeVar:ip];
        NSURL *url = [NSURL URLWithString:sUrl];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        define_weakself;
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *sResult = [[NSString alloc]initWithData:responseObject encoding:[DataUtil getGB2312Code]];
             if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
                 [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置成功"];
                 [weakSelf removeFromSuperview];
                 [SVProgressHUD dismiss];
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
                     [SVProgressHUD dismiss];
                 }
                 return;
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
         }];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:operation];
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
