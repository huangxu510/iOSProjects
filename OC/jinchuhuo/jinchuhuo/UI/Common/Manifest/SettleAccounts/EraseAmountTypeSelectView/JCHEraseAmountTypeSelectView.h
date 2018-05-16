//
//  JCHEraseAmountTypeSelectView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kJCHEraseAmountTypeSelectViewItemHeight = 50,
};

@interface JCHEraseAmountTypeSelectView : UIView

@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, copy) void(^selectBlock)(NSInteger index);

- (void)showView;
- (void)hideView;

@end
