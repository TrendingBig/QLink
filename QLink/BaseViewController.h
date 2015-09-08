//
//  BaseViewController.h
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataUtil.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

typedef NS_ENUM(NSInteger, SocketType){
    SocketTypeNormal = 1, // 正常模式
    SocketTypeEmergency = 2, // 紧急模式
    SocketTypeWriteZk = 3, // 中控模式
    SocketTypeStudy = 4, // 学习模式
    SocketTypeRemoteIp = 5 // 远程模式
};

typedef NS_ENUM(NSInteger, ZkOper){
    ZkOperNormal = 1,
    ZkOperSence = 2,
    ZkOperDevice = 3
};

@interface BaseViewController : UIViewController
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,assign) SocketType socketType;
@property(nonatomic,assign) BOOL isSence;
@property(nonatomic,assign) ZkOper zkOperType;

//写入中控，重复尝试 3 次
@property(nonatomic,assign) int iTimeoutCount;

-(void)load_typeSocket:(SocketType)socket andOrderObj:(Order *)order;

@end
