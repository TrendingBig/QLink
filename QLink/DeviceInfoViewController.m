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

@interface DeviceInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lblIp;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblPort;

@property(nonatomic,retain) NSArray *models;

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
    
    Order *order = [self.models firstObject];
    self.lblDeviceName.text = self.deviceName;
    NSArray *arrayOrderTips = [order.Address componentsSeparatedByString:@":"];
    if ([arrayOrderTips count] > 2) {
        self.lblType.text = arrayOrderTips[0];
        self.lblIp.text = arrayOrderTips[1];
        self.lblPort.text = arrayOrderTips[2];
    }
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
    cell.lblOrderValue.text = obj.OrderCmd;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

@end
