//
//  JCHAddProductFooterView.h
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHAddProductFooterViewDelegate <NSObject>

- (void)handleEditRemark;
- (void)handleShowTransactionList;
- (void)handleClickSaveOrderList;

@end

@interface JCHAddProductFooterViewData : NSObject
@property (retain, nonatomic, readwrite) NSString *productAmount;
@property (assign, nonatomic, readwrite) NSInteger transactionCount;
@property (retain, nonatomic, readwrite) NSString *remark;

//@property (assign, nonatomic, readwrite) NSInteger productCount;
@end

@interface JCHAddProductFooterView : UIView

@property (assign, nonatomic, readwrite) id<JCHAddProductFooterViewDelegate> delegate;
@property (retain, nonatomic, readwrite) UIButton *shoppingCartButton;

- (id)initWithFrame:(CGRect)frame;
- (void)setViewData:(JCHAddProductFooterViewData *)viewData animation:(BOOL)animation;
- (void)enableSaveButton;

@end
