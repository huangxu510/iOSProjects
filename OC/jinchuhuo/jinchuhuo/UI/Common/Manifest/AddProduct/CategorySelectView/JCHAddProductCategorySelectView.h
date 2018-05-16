//
//  JCHAddProductCategorySelectView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAddProductCategorySelectView : UIView

@property (nonatomic, copy) void(^titleLabelClickAction)(NSInteger labelTag);

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSArray *)dataSource;

- (void)setTitleLabelScale:(CGFloat)value;
- (void)handleTitleLabelClick:(NSInteger)labelTag;

@end
