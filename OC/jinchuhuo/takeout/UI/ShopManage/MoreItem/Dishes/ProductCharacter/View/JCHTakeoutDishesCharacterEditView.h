//
//  JCHDishesCharacterEditView.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTakeoutDishesCharacterEditView : UIView

@property (retain, nonatomic) UITextField *characterTitleTextField;
@property (assign, nonatomic) CGFloat viewHeight;
@property (copy, nonatomic) void(^delectCharacterBlock)(JCHTakeoutDishesCharacterEditView *editView);
@property (copy, nonatomic) void(^updateViewHeightBlock)(JCHTakeoutDishesCharacterEditView *editView);

- (NSDictionary *)getData;
- (void)setData:(NSDictionary *)data;

@end
