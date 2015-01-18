//
//  SetDeviceOrderView.h
//  QLink
//
//  Created by 尤日华 on 15-1-13.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetDeviceOrderView : UIView

@property(nonatomic,strong) void(^confirmBlock)(NSString *orderCmd,NSString *address);
@property(nonatomic,strong) void(^errorBlock)();

@property(nonatomic,retain) NSString *orderId;
@property (weak, nonatomic) IBOutlet UITextField *tfOrder;

@end
