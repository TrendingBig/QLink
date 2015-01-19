//
//  SetIpView.h
//  QLink
//
//  Created by 尤日华 on 15-1-10.
//  Copyright (c) 2015年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetIpView : UIView

@property(nonatomic,strong) void(^cancleBlock)();
@property(nonatomic,strong) void(^comfirmBlock)(NSString *changeVar);

@property(nonatomic,retain) NSString *deviceId;

-(void)fillContent:(NSString *)deviceId;

@end
