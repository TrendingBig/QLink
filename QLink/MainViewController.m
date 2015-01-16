//
//  MainViewController.m
//  QLink
//
//  Created by 尤日华 on 14-9-17.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "MainViewController.h"
#import "ILBarButtonItem.h"
#import "REMenuItem.h"
#import "KxMenu.h"
#import "NetworkUtil.h"
#import "RemoteViewController.h"
#import "LightViewController.h"
#import "DeviceConfigViewController.h"
#import "AboutViewController.h"
#import "SenceConfigViewController.h"
#import "SVProgressHUD.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "UIView+xib.h"
#import "SetIpView.h"
#import "DeviceInfoViewController.h"
#import "ReSetIpView.h"

#define kImageWidth  106 //UITableViewCell里面图片的宽度
#define kImageHeight  106 //UITableViewCell里面图片的高度

@interface MainViewController ()
{
    NSMutableArray *senceArr_;
    NSMutableArray *deviceArr_;
    NSArray *roomArr_;
    
    NSInteger senceCount_;
    NSInteger deviceCount_;
    
    NSInteger senceRowCount_;
    NSInteger deviceRowCount_;
    
    int svHeight_;
    
    NSMutableArray *iconArr_;
}
@property(nonatomic,retain) RenameView *renameView;
@property(nonatomic,retain) SetIpView *setIpView;
@property(nonatomic,retain) ReSetIpView *resetIpView;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    senceArr_ = [NSMutableArray array];
    deviceArr_ = [NSMutableArray array];
    
    [self initIconArr];
    
    [self initData];
    
    [self initNavigation];
    
    [self initControl];
    
    [self registerNotification];
    
    [self initLoginZK];
}

#pragma mark -
#pragma mark 初始化方法

-(void)initIconArr
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"iConPlist" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    iconArr_ = [NSMutableArray array];
    [iconArr_ addObjectsFromArray:[dataDic objectForKey:@"Sence"]];
    [iconArr_ addObjectsFromArray:[dataDic objectForKey:@"Device"]];
    [iconArr_ addObject:@"SANSAN_DEVICE_ADD"];
    [iconArr_ addObject:@"SANSAN_MACRO_ADD"];
}

//设置导航
-(void)initNavigation
{
    [self.navigationController.navigationBar setHidden:NO];
    
    UIButton *btnDDL = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDDL.frame = CGRectMake(0, 0, 135, 38);
    btnDDL.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [btnDDL setBackgroundImage:[UIImage imageNamed:@"首页_ddl.png"] forState:UIControlStateNormal];
    NSString *roomName = @"none";
    if ([roomArr_ count] > 0) {
        Room *obj = [roomArr_ objectAtIndex:0];
        roomName = obj.RoomName;
    }
    [btnDDL setTitle:roomName forState:UIControlStateNormal];
    [btnDDL addTarget:self action:@selector(showCenterMenu) forControlEvents:UIControlEventTouchUpInside];
    
    //将横向列表添加到导航栏
    self.navigationItem.titleView = btnDDL;
    
    self.navigationItem.hidesBackButton = YES;
    
    ILBarButtonItem *rightBtn =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_三横.png"]
                        selectedImage:[UIImage imageNamed:@"首页_三横.png"]
                               target:self
                               action:@selector(showRightMenu)];
    
    
    self.navigationItem.rightBarButtonItem = rightBtn;
}

-(void)initLoginZK
{
    if ([DataUtil isWifiNewWork]) {
        Config *configObj = [Config getConfig];
        if (!configObj.isWriteCenterControl && configObj.isSetSign && configObj.isSetIp && configObj.isBuyCenterControl)
        {
            [UIAlertView alertViewWithTitle:@"温馨提示"
                                    message:@"执行中控操作,是否继续?"
                          cancelButtonTitle:@"取消"
                          otherButtonTitles:@[@"继续"]
                                  onDismiss:^(int index){
                                      self.zkOperType = ZkOperNormal;
                                      [self load_typeSocket:SocketTypeWriteZk andOrderObj:nil];
                                  }onCancel:nil];
        }
    }
}

//添加左侧add菜单
-(void)setAddSenceModelNavigation
{
    ILBarButtonItem *senceModel =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"sence_cancle.png"]
                        selectedImage:[UIImage imageNamed:@"sence_cancle.png"]
                               target:self
                               action:@selector(btnCancleSenceModel)];
    
    self.navigationItem.leftBarButtonItem = senceModel;
    
    [self setAddSenceModelRightNavEnabledFalse];
}

//设置scrollview不能滚动，且右上角菜单隐藏
-(void)setAddSenceModelRightNavEnabledFalse
{
    self.btnSceneControl.enabled = false;
    self.svBig.scrollEnabled = false;
    self.navigationItem.rightBarButtonItem = nil;
}

//设置scrollview能滚动，且右上角菜单显示
-(void)setAddSenceModelRightNavEnabledYES
{
    self.btnSceneControl.selected = YES;
    self.btnDeviceControl.selected = NO;
    self.btnSceneControl.enabled = YES;
    self.svBig.scrollEnabled = YES;
    ILBarButtonItem *rightBtn =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_三横.png"]
                        selectedImage:[UIImage imageNamed:@"首页_三横.png"]
                               target:self
                               action:@selector(showRightMenu)];
    
    
    self.navigationItem.rightBarButtonItem = rightBtn;
}


//设置控件
-(void)initControl
{
    self.navigationItem.titleView.hidden = YES;
    
    _svBig.frame = CGRectMake(0, 29, 320, svHeight_);
    _svBig.contentSize = CGSizeMake(640, svHeight_);
    _svBig.delegate = self;
    
    _tvScene.delegate = self;
    _tvScene.dataSource = self;
    _tvDevice.delegate = self;
    _tvDevice.dataSource = self;
}

-(void)initSence
{
    GlobalAttr *obj = [DataUtil shareInstanceToRoom];
    [senceArr_ removeAllObjects];
    [senceArr_ addObjectsFromArray:[SQLiteUtil getSenceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId]];
    
    senceCount_ = [senceArr_ count];
    senceRowCount_ = senceCount_%3 == 0 ? senceCount_/3 : (senceCount_/3 + 1);
    
    [_tvScene reloadData];
}

-(void)initDevice:(BOOL)isAddSence
{
    GlobalAttr *obj = [DataUtil shareInstanceToRoom];
    [deviceArr_ removeAllObjects];
    [deviceArr_ addObjectsFromArray:[SQLiteUtil getDeviceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId]];
    
    if (deviceArr_.count > 0 && isAddSence) {
        [deviceArr_ removeLastObject];
    }
    
    deviceCount_ = [deviceArr_ count];
    deviceRowCount_ = deviceCount_%3 == 0 ? deviceCount_/3 : (deviceCount_/3 + 1);
    
    [_tvDevice reloadData];
}

-(void)initData
{
    GlobalAttr *obj = [DataUtil shareInstanceToRoom];
    
    [senceArr_ removeAllObjects];
    [senceArr_ addObjectsFromArray:[SQLiteUtil getSenceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId]];
    senceCount_ = [senceArr_ count];
    senceRowCount_ = senceCount_%3 == 0 ? senceCount_/3 : (senceCount_/3 + 1);
    
    [deviceArr_ removeAllObjects];
    [deviceArr_ addObjectsFromArray:[SQLiteUtil getDeviceList:obj.HouseId andLayerId:obj.LayerId andRoomId:obj.RoomId]];
    deviceCount_ = [deviceArr_ count];
    deviceRowCount_ = deviceCount_%3 == 0 ? deviceCount_/3 : (deviceCount_/3 + 1);
    
    roomArr_ = [SQLiteUtil getRoomList:obj.HouseId andLayerId:obj.LayerId];
    
    svHeight_ = [UIScreen mainScreen].applicationFrame.size.height - 44 - 29;
    
    //设置是否添加场景模式
    [DataUtil setGlobalIsAddSence:NO];
    [self setAddSenceModelRightNavEnabledYES];
    
    [self setZkConfig];
}

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(refreshSenceTab) name:@"refreshSenceTab" object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(refreshDeviceTab) name:@"refreshDeviceTab" object:nil];
}

#pragma mark -
#pragma mark IBAction Methods

-(IBAction)btnScenePressed:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    _btnDeviceControl.selected = NO;
    self.navigationItem.titleView.hidden = YES;
    
    CGRect rect = CGRectMake(0, 0,
                             320, svHeight_);
    [_svBig scrollRectToVisible:rect animated:NO];
}
-(IBAction)btnDevicePressed:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    _btnSceneControl.selected = NO;
    self.navigationItem.titleView.hidden = NO;
    
    CGRect rect = CGRectMake(320, 0,
                             320, svHeight_);
    [_svBig scrollRectToVisible:rect animated:NO];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((scrollView.contentOffset.x - 320 / 2) / 320) + 1;
    if (currentPage == 0) {
        _btnSceneControl.selected = YES;
        _btnDeviceControl.selected = NO;
        self.navigationItem.titleView.hidden = YES;
    }else{
        _btnSceneControl.selected = NO;
        _btnDeviceControl.selected = YES;
        self.navigationItem.titleView.hidden = NO;
    }
}

#pragma mark -
#pragma mark UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 101) {//场景
        return senceRowCount_;
    }else{//设备
        return deviceRowCount_;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    if (tableView.tag == 101) {//场景
        //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] init];
        }
        
        for (UIView *views in cell.contentView.subviews)
        {
            [views removeFromSuperview];
        }
        
        for (int i=0; i<3; i++) {
            NSInteger index = 3*indexPath.row+i;
            if (index >= senceCount_) {
                break;
            }
            Sence *obj = [senceArr_ objectAtIndex:index];
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            iConView *iconView = [[iConView alloc] init];
            iconView.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            iconView.center = CGPointMake(kImageWidth *(0.5 + i), kImageHeight * 0.5);
            iconView.delegate = self;
            
            NSString *icon = @"";
            if (obj.IconType) {
                icon = obj.IconType;
            }else{
                icon = obj.Type;
            }
            if (![iconArr_ containsObject:icon]) {
                icon = @"other";
            }
            [iconView setIcon:icon andTitle:obj.SenceName andType:obj.Type];
            [iconView setValue:[NSNumber numberWithInt:index] forKey:@"index"];
            [iconView setValue:obj.Type forKey:@"pType"];
            
            [cell.contentView addSubview:iconView];
        }
        return cell;
    }else{
        //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] init];
        }
        
        for (UIView *views in cell.contentView.subviews)
        {
            [views removeFromSuperview];
        }
        
        for (int i=0; i<3; i++) {
            NSInteger index = 3*indexPath.row+i;
            if (index >= deviceCount_) {
                break;
            }
            Device *obj = [deviceArr_ objectAtIndex:index];
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            iConView *iconView = [[iConView alloc] init];
            iconView.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            iconView.center = CGPointMake(kImageWidth *(0.5 + i), kImageHeight * 0.5);
            iconView.delegate = self;
            NSString *icon = @"";
            if (obj.IconType) {
                icon = obj.IconType;
            }else{
                icon = obj.Type;
            }
            if (![iconArr_ containsObject:icon]) {
                icon = @"other";
            }
            [iconView setIcon:icon andTitle:obj.DeviceName andType:obj.Type];
            [iconView setValue:[NSNumber numberWithInt:index] forKey:@"index"];
            [iconView setValue:obj.Type forKey:@"pType"];
            
            [cell.contentView addSubview:iconView];
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 106;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //不让tableviewcell有选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark iConViewDelegate

-(void)handleLongPressed:(int)index andType:(NSString *)pType
{
    if ([pType isEqualToString:MACRO]) {//场景
        Sence *obj = [senceArr_ objectAtIndex:index];
        define_weakself;
        [UIAlertView alertViewWithTitle:@"温馨提示"
                                message:nil
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@[@"重命名",@"图标重置",@"删除",@"编辑",@"设备信息"]
                              onDismiss:^(int btnIdx){
                                  switch (btnIdx) {
                                      case 0://重命名
                                      {
                                          self.renameView = [RenameView viewFromDefaultXib];
                                          self.renameView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                                          self.renameView.backgroundColor = [UIColor clearColor];
                                          self.renameView.tfContent.text = obj.SenceName;
                                          [self.renameView setCanclePressed:^{
                                              [weakSelf.renameView removeFromSuperview];
                                          }];
                                          [self.renameView setConfirmPressed:^(UILabel *lTitle,NSString *newName){
                                              NSString *sUrl = [NetworkUtil getChangeSenceName:newName andSenceId:obj.SenceId];
                                              
                                              NSURL *url = [NSURL URLWithString:sUrl];
                                              NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                                              NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                              NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                                              if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
                                                 [SQLiteUtil renameSenceName:obj.SenceId andNewName:newName];
                                                  
                                                  [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                          message:@"更新成功"
                                                                cancelButtonTitle:@"确定"];
                                                  
                                                  [weakSelf.renameView removeFromSuperview];
                                                  
                                                  [weakSelf initSence];
                                              }else{
                                                  [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                          message:@"更新失败,请稍后再试."
                                                                cancelButtonTitle:@"关闭"];
                                              }
                                          }];
                                          [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.renameView];
                                          
                                          break;
                                      }
                                      case 1://图标重置
                                      {
                                          IconViewController *iconVC = [[IconViewController alloc] init];
                                          iconVC.pDeviceId = obj.SenceId;
                                          iconVC.pType = obj.Type;
                                          iconVC.delegate = self;
                                          [self.navigationController pushViewController:iconVC animated:YES];
                                          
                                          break;
                                      }
                                      case 2://删除
                                      {
                                          NSString *sUrl = [NetworkUtil getDelSence:obj.SenceId];;
                                          
                                          NSURL *url = [NSURL URLWithString:sUrl];
                                          NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                                          NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                          NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                                          if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
                                              [SQLiteUtil removeSence:obj.SenceId];
                                              [self initSence];
                                              
                                              [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                      message:@"删除成功"
                                                            cancelButtonTitle:@"确定"];
                                              
                                          }else{
                                              [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                      message:@"删除失败.请稍后再试."
                                                            cancelButtonTitle:@"关闭"];
                                          }
                                          
                                          break;
                                      }
                                      case 3://编辑
                                      {
                                          [DataUtil setUpdateInsertSenceInfo:obj.SenceId andSenceName:obj.SenceName];
                                        
                                          SenceConfigViewController *configVC = [[SenceConfigViewController alloc] init];
                                          configVC.delegate = self;
                                          [self.navigationController pushViewController:configVC animated:YES];
                                          break;
                                    }
                                      default:
                                          break;
                                  }
        }onCancel:nil];
    } else{
        Device *obj = [deviceArr_ objectAtIndex:index];
        define_weakself;
        [UIAlertView alertViewWithTitle:@"操作"
                                message:nil
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@[@"重命名",@"图标重置",@"删除",@"设置IP",@"设备信息"]
                              onDismiss:^(int buttonIndex){
                                  switch (buttonIndex) {
                                      case 0://重命名
                                      {
                                          self.renameView = [RenameView viewFromDefaultXib];
                                          self.renameView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                                          self.renameView.backgroundColor = [UIColor clearColor];
                                          self.renameView.tfContent.text = obj.DeviceName;
                                          [self.renameView setCanclePressed:^{
                                              [weakSelf.renameView removeFromSuperview];
                                          }];
                                          [self.renameView setConfirmPressed:^(UILabel *lTitle,NSString *newName){
                                              NSString *sUrl = [NetworkUtil getChangeDeviceName:newName andDeviceId:obj.DeviceId];
                                              
                                              NSURL *url = [NSURL URLWithString:sUrl];
                                              NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                                              NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                              NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                                              if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
                                                  [SQLiteUtil renameDeviceName:obj.DeviceId andNewName:newName];
                                                  
                                                  [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                          message:@"更新成功"
                                                                cancelButtonTitle:@"确定"];
                                                  
                                                  [weakSelf.renameView removeFromSuperview];
                                                  
                                                  [weakSelf initDevice:NO];
                                              }else{
                                                  [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                          message:@"更新失败,请稍后再试."
                                                                cancelButtonTitle:@"关闭"];
                                              }
                                          }];
                                          [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.renameView];
                                          
                                          break;
                                      }
                                      case 1://图标重置
                                      {
                                          IconViewController *iconVC = [[IconViewController alloc] init];
                                          iconVC.pDeviceId = obj.DeviceId;
                                          iconVC.pType = obj.Type;
                                          iconVC.delegate = self;
                                          [self.navigationController pushViewController:iconVC animated:YES];
                                          
                                          break;
                                      }
                                      case 2://删除
                                      {
                                          NSString *sUrl = [NetworkUtil getDelDevice:obj.DeviceId];;
                                          
                                          NSURL *url = [NSURL URLWithString:sUrl];
                                          NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                                          NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                          NSString *sResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                                          if ([[sResult lowercaseString] isEqualToString:@"ok"]) {
                                              [SQLiteUtil removeDevice:obj.DeviceId];
                                              [self initDevice:NO];
                                              
                                              [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                      message:@"删除成功"
                                                            cancelButtonTitle:@"确定"];
                                              
                                          }else{
                                              [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                      message:@"删除失败.请稍后再试."
                                                            cancelButtonTitle:@"关闭"];
                                          }
                                          
                                          break;
                                      }
                                      case 3://设置IP
                                      {
                                          define_weakself;
                                          self.setIpView = [SetIpView viewFromDefaultXib];
                                          self.setIpView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                                          self.setIpView.backgroundColor = [UIColor clearColor];
                                          self.setIpView.deviceId = obj.DeviceId;
                                          [self.setIpView setCancleBlock:^{
                                              [weakSelf.setIpView removeFromSuperview];
                                          }];
                                          [self.setIpView setComfirmBlock:^(NSString *ip) {
                                          }];
                                         
                                          [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.setIpView];
                                          break;
                                      }
                                      case 4://设备信息
                                      {
                                          NSArray *array = [SQLiteUtil getOrderListByDeviceId:obj.DeviceId];
                                          if (array.count <= 0) {
                                              return;
                                          }
                                          
                                          Order *order = [array firstObject];
                                          NSArray *arrayOrderTips = [order.Address componentsSeparatedByString:@":"];
                                          if ([arrayOrderTips count] < 2) {
                                              [UIAlertView alertViewWithTitle:@"温馨提示"
                                                                      message:@"您还没有设置IP,现在设置?"
                                                            cancelButtonTitle:@"取消"
                                                            otherButtonTitles:@[@"确定"]
                                                                    onDismiss:^(int buttonIndex) {
                                                                        define_weakself;
                                                                        self.setIpView = [SetIpView viewFromDefaultXib];
                                                                        self.setIpView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                                                                        self.setIpView.backgroundColor = [UIColor clearColor];
                                                                        self.setIpView.deviceId = obj.DeviceId;
                                                                        [self.setIpView setCancleBlock:^{
                                                                            [weakSelf.setIpView removeFromSuperview];
                                                                        }];
                                                                        [self.setIpView setComfirmBlock:^(NSString *ip) {
                                                                        }];
                                                                        
                                                                        [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.setIpView];
                                                                    }onCancel:^{
                                                                        DeviceInfoViewController *vc = [[DeviceInfoViewController alloc] init];
                                                                        vc.deviceName = obj.DeviceName;
                                                                        vc.deviceId = obj.DeviceId;
                                                                        [self.navigationController pushViewController:vc animated:YES];
                                                                    }];
                                          } else {
                                              DeviceInfoViewController *vc = [[DeviceInfoViewController alloc] init];
                                              vc.deviceName = obj.DeviceName;
                                              vc.deviceId = obj.DeviceId;
                                              [self.navigationController pushViewController:vc animated:YES];
                                          }
                                          break;
                                      }
                                      default:
                                          break;
                                  }
        }onCancel:nil];
    }
}

-(void)handleSingleTapPressed:(int)index andType:(NSString *)pType
{
    NSLog(@"单击====%d",index);
    
    if ([pType isEqualToString:MACRO]) {//场景
        Sence *obj = [senceArr_ objectAtIndex:index];
        Order *orderObj = [[Order alloc] init];
        orderObj.OrderCmd = obj.Macrocmd;
        orderObj.senceId = obj.SenceId;
        self.isSence = YES;
        [self load_typeSocket:999 andOrderObj:orderObj];
    } else if([pType isEqualToString:@"light"]){ // 照明
        LightViewController *lightVC = [[LightViewController alloc] init];
        [self.navigationController pushViewController:lightVC animated:YES];
    } else if([pType isEqualToString:SANSANADDDEVICE]){ // 添加设备
        DeviceConfigViewController *deviceConfigVC = [[DeviceConfigViewController alloc] init];
        [self.navigationController pushViewController:deviceConfigVC animated:YES];
    } else if([pType isEqualToString:SANSANADDMACRO]){ // 添加场景
        
        [DataUtil setUpdateInsertSenceInfo:@"" andSenceName:@""];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"您已进入选择模式,所有按键失效,请选择您要构成场景的动作."
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        CGRect rect = CGRectMake(320, 0, 320, _svBig.frame.size.height);
        [_svBig scrollRectToVisible:rect animated:NO];
        
        [self initDevice:YES];
        
        [DataUtil setGlobalIsAddSence:YES];
        [self setAddSenceModelNavigation];
    } else { //设备
        Device *obj = [deviceArr_ objectAtIndex:index];
        
        RemoteViewController *remoteVC = [[RemoteViewController alloc] init];
        remoteVC.deviceId = obj.DeviceId;
        remoteVC.deviceName = obj.DeviceName;
        [self.navigationController pushViewController:remoteVC animated:YES];
    }
}

#pragma mark -
#pragma mark IconViewDelegate

-(void)refreshTable:(NSString *)pType
{
    if ([pType isEqualToString:MACRO]) {
        [self initSence];
    }else{
        [self initDevice:NO];
    }
}

#pragma mark -
#pragma mark SenDelegate

-(void)refreshSenceTab
{
    [self btnCancleSenceModel];
    
    [self initSence];
}

-(void)goOnChoose
{
    [self initDevice:YES];
    
    [DataUtil setGlobalIsAddSence:YES];
    [self setAddSenceModelRightNavEnabledFalse];
    
    CGRect rect = CGRectMake(320, 0, 320, _svBig.frame.size.height);
    [_svBig scrollRectToVisible:rect animated:NO];
}

#pragma mark -
#pragma mark SimpDel

- (void)pingResult:(NSNumber*)success {
    if (success.boolValue) {
        [DataUtil setGlobalModel:Model_ZKIp];
    } else {
        [DataUtil setGlobalModel:Model_ZKDOMAIN];
    }
}

#pragma mark -
#pragma mark Custom Methods

-(void)setZkConfig
{
    //设置当前模式
    Config *configObj = [Config getConfig];
    if (configObj.isBuyCenterControl) {//购买中控
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                {
                    [DataUtil setGlobalModel:Model_ZKDOMAIN];
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi:
                {   
                    Control *control = [SQLiteUtil getControlObj];
                    [SimplePingHelper ping:control.Ip
                                    target:self
                                       sel:@selector(pingResult:)];
                    break;
                }
                case AFNetworkReachabilityStatusNotReachable:{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:@"连接失败\n请确认网络是否连接." delegate:nil
                                                              cancelButtonTitle:@"关闭"
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                    break ;
                }
                default:
                    break;
            };
        }];
    
    } else {
        [DataUtil setGlobalModel:Model_JJ];
    }
}

-(void)refreshDeviceTab
{
    [self initDevice:NO];
}

//楼层菜单
- (void)showCenterMenu
{
    if (_menu.isOpen)
        return [_menu close];
    
    //房间下拉
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < [roomArr_ count]; i ++) {
        Room *obj = [roomArr_ objectAtIndex:i];
        REMenuItem *item = [[REMenuItem alloc] initWithTitle:obj.RoomName
                                                    subtitle:@""
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          [self pushRoomItem:item];
                                                      }];
        
        item.tag = i;
        [items addObject:item];
    }
    
    _menu = [[REMenu alloc] initWithItems:items];
    _menu.cornerRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);
    
    [_menu showFromNavigationController:self.navigationController];
}

//配置菜单
-(void)showRightMenu
{
    [_menu close];
    
    if ([KxMenu isOpen]) {
        return [KxMenu dismissMenu];
    }
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    Config *configObj = [Config getConfig];
    if (configObj.isBuyCenterControl) {
        KxMenuItem *zhengchangItem = [KxMenuItem menuItem:@"正常模式"
                                                    image:nil
                                                   target:self
                                                   action:@selector(pushMenuItem:)];
        
        KxMenuItem *jinjiItem = [KxMenuItem menuItem:@"紧急模式"
                                               image:nil
                                              target:self
                                              action:@selector(pushMenuItem:)];
        
        NSString *model = [DataUtil getGlobalModel];
        
        if ([model isEqualToString:Model_ZKDOMAIN] || [model isEqualToString:Model_ZKIp]) {
            zhengchangItem = [KxMenuItem menuItem:@"正常模式"
                                            image:[UIImage imageNamed:@"success"]
                                           target:self
                                           action:@selector(pushMenuItem:)];
        } else if ([model isEqualToString:Model_JJ]) {
            jinjiItem = [KxMenuItem menuItem:@"紧急模式"
                                       image:[UIImage imageNamed:@"success"]
                                      target:self
                                      action:@selector(pushMenuItem:)];
        }
        
        menuItems = [NSMutableArray arrayWithObjects:zhengchangItem,
                     jinjiItem,
                     
                     [KxMenuItem menuItem:@"写入中控"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)],
                     
                     [KxMenuItem menuItem:@"初始化"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)],
                     [KxMenuItem menuItem:@"重写中控"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)],
                     [KxMenuItem menuItem:@"重设IP"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)],
                     
                     [KxMenuItem menuItem:@"关于"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)], nil];
    } else {
        menuItems = [NSMutableArray arrayWithObjects:
                     [KxMenuItem menuItem:@"重设IP"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)],
                     [KxMenuItem menuItem:@"关于"
                                    image:nil
                                   target:self
                                   action:@selector(pushMenuItem:)], nil];
    }
    
    
    
    CGRect rect = CGRectMake(215, -50, 100, 50);
    
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:menuItems];
}

-(void)pushRoomItem:(REMenuItem *)item
{
    Room *obj = [roomArr_ objectAtIndex:item.tag];
    
    //设置导航标题
    UIButton *btnTitle = (UIButton *)[self.navigationItem titleView];
    
    if ([btnTitle.titleLabel.text isEqualToString:obj.RoomName]) {
        return;
    }
    
    [btnTitle setTitle:obj.RoomName forState:UIControlStateNormal];
    
    [DataUtil setGlobalAttrRoom:obj.RoomId];
    
    [self initSence];
    
    [self initDevice:NO];
}

//点击下拉事件
- (void)pushMenuItem:(KxMenuItem *)sender
{
    if ([sender.title isEqualToString:@"正常模式"]) {
        [SVProgressHUD showSuccessWithStatus:@"正常模式"];
        [self setZkConfig];
    } else if ([sender.title isEqualToString:@"紧急模式"])
    {
        [SVProgressHUD showSuccessWithStatus:@"紧急模式"];
        [DataUtil setGlobalModel:Model_JJ];
    } else if ([sender.title isEqualToString:@"写入中控"])
    {
        self.zkOperType = ZkOperNormal;
        [self load_typeSocket:SocketTypeWriteZk andOrderObj:nil];
        
    } else if ([sender.title isEqualToString:@"初始化"])
    {
        
    } else if ([sender.title isEqualToString:@"关于"])
    {
        AboutViewController *aboutVC = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    } else if ([sender.title isEqualToString:@"重写中控"]) {
        NSString *sUrl = [NetworkUtil geResetZK];
        NSURL *url = [NSURL URLWithString:sUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSString *sConfig = [[NSString alloc] initWithData:responseObject encoding:[DataUtil getGB2312Code]];
             NSRange range = [sConfig rangeOfString:@"error"];
             if (range.location != NSNotFound)
             {
                 NSArray *errorArr = [sConfig componentsSeparatedByString:@":"];
                 if (errorArr.count > 1) {
                     [SVProgressHUD showErrorWithStatus:errorArr[1]];
                     return;
                 }
             }
             
             [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置成功,重启应用后生效."];
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [UIAlertView alertViewWithTitle:@"温馨提示" message:@"设置失败,请稍后再试."];
         }];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:operation];
    } else if([sender.title isEqualToString:@"重设IP"]) {
        define_weakself;
        self.resetIpView = [ReSetIpView viewFromDefaultXib];
        self.resetIpView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.resetIpView.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.resetIpView];
    }
}

//取消场景模式
-(void)btnCancleSenceModel
{
    [self initDevice:NO];
    
    [DataUtil setGlobalIsAddSence:NO];
    [self setAddSenceModelRightNavEnabledYES];
    
    [SQLiteUtil removeShoppingCar];
    self.navigationItem.leftBarButtonItem = nil;
    CGRect rect = CGRectMake(0, 0, 320, _svBig.frame.size.height);
    [_svBig scrollRectToVisible:rect animated:NO];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
