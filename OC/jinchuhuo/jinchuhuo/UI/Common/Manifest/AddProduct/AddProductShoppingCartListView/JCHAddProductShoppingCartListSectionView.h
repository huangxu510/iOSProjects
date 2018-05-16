//
//  JCHAddProductShoppingCartListSectionView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

@interface JCHAddProductShoppingCartListSectionViewData : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productPrice;
@property (nonatomic, retain) NSString *productDiscount;

@end
@interface JCHAddProductShoppingCartListSectionView : UIView
@property (nonatomic, retain) UILabel *productNameLabel;
@property (nonatomic, retain) UIButton *deletaButton;
@property (nonatomic, assign) NSInteger section;

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType;
- (void)setData:(JCHAddProductShoppingCartListSectionViewData *)data;
@end
