//
//  JCHInventoryPullDownCategoryView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHInventoryPullDownBaseView.h"


enum
{
    kCategoryButtonTagBase = 10000, //全部类型
};

@interface JCHInventoryPullDownCategoryView : JCHInventoryPullDownBaseView

- (void)selectButton:(NSInteger)index;
- (NSString *)getSelectButtonTitle;

@end
