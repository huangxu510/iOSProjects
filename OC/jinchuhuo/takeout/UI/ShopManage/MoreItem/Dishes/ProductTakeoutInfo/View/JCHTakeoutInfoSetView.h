//
//  JCHTakeoutInfoSetView.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHAddDishesViewController.h"

typedef NS_ENUM(NSInteger, JCHProductSKUMode)
{
    kJCHProductWithoutSKU,     // 无规格菜品
    kJCHProductWithSKU,        // 多规格菜品
};

@interface JCHTakeoutInfoSetViewData : NSObject

@property (retain, nonatomic) NSString *skuName;
@property (retain, nonatomic) NSArray *skuUUIDVector;
@property (assign, nonatomic) NSInteger boxCount;
@property (assign, nonatomic) CGFloat boxPrice;

@end

@interface JCHTakeoutInfoSetView : UIView

@property (assign, nonatomic) CGFloat viewHeight;

- (instancetype)initWithFrame:(CGRect)frame
               productSKUMode:(JCHProductSKUMode)productSKUMode;

- (void)setViewData:(JCHTakeoutInfoSetViewData *)data;
- (JCHTakeoutInfoSetViewData *)getData;

@end
