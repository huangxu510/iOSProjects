//
//  JCHCategoryListFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHCategoryListFooterView.h"

@implementation JCHCategoryListFooterView

- (void)setData:(NSInteger)count
{
    if (_selectAllButton.hidden)
    {
        _productCountLabel.text = [NSString stringWithFormat:@"%ld种类型", (long)count];
    }
    else
    {
        _productCountLabel.text = [NSString stringWithFormat:@"已选中%ld种", (long)count];
    }
}

@end
