//
//  JCHAddProductShoppingCartListView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

@class JCHAddProductShoppingCartListView;

@protocol JCHAddProductShoppingCartListViewDelegate <NSObject>

- (void)handleHideListView:(JCHAddProductShoppingCartListView *)listView;
- (void)handleDeleteTransaction:(JCHAddProductShoppingCartListView *)listView;

@end

@interface JCHAddProductShoppingCartListView : UIView

@property (nonatomic, assign) id <JCHAddProductShoppingCartListViewDelegate> delegate;
@property (nonatomic, assign) CGFloat viewHeight;

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType;

@end
