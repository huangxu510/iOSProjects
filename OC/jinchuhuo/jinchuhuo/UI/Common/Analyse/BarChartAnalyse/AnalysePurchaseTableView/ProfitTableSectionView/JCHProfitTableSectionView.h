//
//  JCHProfitTableSectionView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JCHProfitTableViewType)
{
    kJCHProfitTableViewTypeTradeDate,
    kJCHProfitTableViewTypeProductCategory,
    kJCHProfitTableViewTypeProductName,
};
@interface JCHProfitTableSectionView : UIView

- (instancetype)initWithFrame:(CGRect)frame tableViewType:(JCHProfitTableViewType)type;

@end
