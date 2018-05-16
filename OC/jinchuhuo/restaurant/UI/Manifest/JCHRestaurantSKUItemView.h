//
//  JCHRestaurantSKUItemView.h
//  jinchuhuo
//
//  Created by apple on 2017/1/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceFactory.h"

@protocol JCHRestaurantSKUItemViewDelegate <NSObject>

- (void)handleRestaurantIncreaseSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property;
- (void)handleRestaurantDecreaseSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property;
- (NSInteger)getRestaurantSKUDishCount:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property;
- (CGFloat)getRestaurantSKUDishPrice:(NSArray *)skuArray goodsRecord:(ProductRecord4Cocoa *)goodsRecord property:(NSString *)property;
- (void)handleCloseView;

@end

@interface JCHRestaurantSKUItemView : UIView

@property (assign, nonatomic, readwrite) id<JCHRestaurantSKUItemViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
        goodsRecord:(ProductRecord4Cocoa *)goodsRecord
     goodsSKURecord:(GoodsSKURecord4Cocoa *)goodsSKURecord;

@end
