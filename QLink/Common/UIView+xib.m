//
//  UIView+xib.m
//  CocoSDKDemo
//
//  Created by Linyw on 14-3-28.
//  Copyright (c) 2014年 CocoaChina. All rights reserved.
//

#import "UIView+xib.h"

@implementation UIView (xib)

+(instancetype)viewFromXib:(NSString *)xibName
{
    UINib * nib = [UINib nibWithNibName:xibName bundle:nil];
    UIView * view  = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    return view;
}

+(instancetype)viewFromDefaultXib
{
    NSString * defaultXibName = NSStringFromClass([self class]);
    return [self viewFromXib:defaultXibName];
}

@end
