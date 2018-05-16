//
//  JCHTableViewItemModel.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTableViewItemModel.h"

@implementation JCHTableViewItemModel

- (void)dealloc
{
    self.title = nil;
    self.detail = nil;
    self.iconName = nil;
    
    [super dealloc];
}

@end
