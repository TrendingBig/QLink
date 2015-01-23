//
//  DeviceInfoViewController.m
//  QLink
//
//  Created by 尤日华 on 15-1-12.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import "DeviceInfoCell.h"
#import "DataUtil.h"
#import "ILBarButtonItem.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "SetIpView.h"
#import "NSString+NSStringHexToBytes.h"

@interface DeviceInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lblIp;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblPort;

@property(nonatomic,retain) NSArray *models;

@property(nonatomic,retain) SetIpView *setIpView;

@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigation];
    
    [self loadData];
    
    [self setUI];
}

//设置导航
-(void)initNavigation
{
    ILBarButtonItem *back =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_返回.png"]
                        selectedImage:[UIImage imageNamed:@"首页_返回.png"]
                               target:self
                               action:@selector(btnBackPressed)];
    
    self.navigationItem.leftBarButtonItem = back;
    
    UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTitle.frame = CGRectMake(0, 0, 100, 20);
    [btnTitle setTitle:@"设备信息" forState:UIControlStateNormal];
    btnTitle.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    btnTitle.backgroundColor = [UIColor clearColor];
    
    [btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.navigationItem.titleView = btnTitle;
}

-(void)setUI
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    [self.tableview reloadData];
}

-(void)loadData
{
    self.models = [SQLiteUtil getOrderListByDeviceId:self.deviceId];
    
    if (self.models.count <= 0) {
        return;
    }
    
    for (Order *order in self.models) {
        if (![DataUtil checkNullOrEmpty:order.Address]) {
            NSArray *arrayOrderTips = [order.Address componentsSeparatedByString:@":"];
            if ([arrayOrderTips count] > 2) {
                self.lblType.text = arrayOrderTips[0];
                self.lblIp.text = arrayOrderTips[1];
                self.lblPort.text = arrayOrderTips[2];
            }
            break;
        }
    }
    self.lblDeviceName.text = self.deviceName;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.models count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CELL";
    DeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceInfoCell" owner:self options:nil] objectAtIndex:0];
    }
    
    Order *obj = [self.models objectAtIndex:indexPath.row];
    cell.lblOrderName.text = obj.OrderName;
    
    NSString *orderValue = @"";
    
    if ([[DataUtil getGlobalModel] isEqualToString:Model_ZKDOMAIN] ||[[DataUtil getGlobalModel] isEqualToString:Model_ZKIp] || [DataUtil checkNullOrEmpty:obj.OrderCmd]) {//中控模式 不变
        NSString *orderValue1 = [DataUtil checkNullOrEmpty:obj.OrderCmd] ? @"暂无" : obj.OrderCmd;
        cell.lblOrderValue.text = orderValue1;
        orderValue = orderValue1;
    } else { //紧急模式(修改Order取值显示出来的时候省略4个字节；之后如果返回命令冒号后为“1”表示为ASCII码，将省略4字节后的报文，转化为ASCII码，2个为一组；“0”表示原声为16进制，无需更改)
        NSString *handleOrderCmd = [obj.OrderCmd substringFromIndex:4];
        if ([obj.Hora isEqualToString:@"1"]) { //转ASCII
            NSData *data = [handleOrderCmd hexToBytes];
            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
            
            cell.lblOrderValue.text = [NSString stringWithFormat:@"%@(A)",result];
            orderValue = [NSString stringWithFormat:@"%@(A)",result];
        } else { //0
            cell.lblOrderValue.text = [NSString stringWithFormat:@"%@(H)",handleOrderCmd];
            orderValue = [NSString stringWithFormat:@"%@(H)",handleOrderCmd];
        }
    }
    
    //设置自动行数与字符换行
    [cell.lblOrderValue setNumberOfLines:0];
    cell.lblOrderValue.lineBreakMode = UILineBreakModeWordWrap;
    UIFont *font = [UIFont fontWithName:@"Arial" size:14];
    //设置一个行高上限
    CGSize size = CGSizeMake(215,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [orderValue sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    int height = labelsize.height < 21 ? 21 : labelsize.height;
    cell.lblOrderValue.frame = CGRectMake(76,37, 215, height);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *obj = [self.models objectAtIndex:indexPath.row];
    
    NSString *orderValue = [DataUtil checkNullOrEmpty:obj.OrderCmd] ? @"暂无" : obj.OrderCmd;
    UIFont *font = [UIFont fontWithName:@"Arial" size:14];
    //设置一个行高上限
    CGSize size = CGSizeMake(215,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [orderValue sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    int height = labelsize.height < 21 ? 21 : labelsize.height;
    return height + 45;
}

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

@end
