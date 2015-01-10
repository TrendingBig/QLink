//
//  UIView+xib.h
//  CocoSDKDemo
//
//  Created by Linyw on 14-3-28.
//  Copyright (c) 2014年 CocoaChina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (xib)
/**
 *  从xib中序列化出 一个View
 *
 *  @param xibName xib文件名
 *
 *  @return instance of View
 */
+(instancetype)viewFromXib:(NSString *)xibName;
/**
 *  同上一个方法，加载一个跟类同名的xib
 *
 *  @return instance of View
 */
+(instancetype)viewFromDefaultXib;
@end
