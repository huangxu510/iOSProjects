//
//  JCHTakeoutDishCharacterLabelEditView.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTakeoutDishesCharacterLabelEditView : UIView

@property (copy, nonatomic) dispatch_block_t addLabelBlock;
@property (copy, nonatomic) dispatch_block_t deleteLabelBlock;
@property (retain, nonatomic) UITextField *labelTextField;

- (instancetype)initWithFrame:(CGRect)frame
                 isFooterView:(BOOL)isFooterView;

@end
