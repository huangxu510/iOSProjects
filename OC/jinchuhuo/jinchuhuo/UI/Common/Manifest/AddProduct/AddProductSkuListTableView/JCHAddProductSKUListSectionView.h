//
//  JCHAddProductSKUListSectionView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

@interface JCHAddProductSKUListSectionView : UIView

@property (nonatomic, retain) UIButton *selectedAllButton;
@property (nonatomic, retain) UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType;
- (void)hideSelectAllButton;

@end
