//
//  JCHRestaurantDishDetailFooterView.h
//  jinchuhuo
//
//  Created by apple on 2017/1/12.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHRestaurantDishDetailFooterViewDelegate <NSObject>

- (void)handleRestaurantAddDish;
- (void)handleRestaurantFinish;

@end

@interface JCHRestaurantDishDetailFooterView : UIView

@property (assign, nonatomic, readwrite) id<JCHRestaurantDishDetailFooterViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setPeopleCount:(NSInteger)peopleCount totalAmount:(CGFloat)totalAmount;

@end
