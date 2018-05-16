//
//  JCHAddProductShoppingCartListTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

@interface JCHAddProductShoppingCartListTableViewCellData : NSObject

@property (nonatomic, retain) NSString *skuCombine;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *discount;

@end

@class JCHAddProductShoppingCartListTableViewCell;
@protocol JCHAddProductShoppingCartListTableViewCellDelegate <NSObject>

- (void)handleDeleteTransaction:(JCHAddProductShoppingCartListTableViewCell *)cell;

@end

@interface JCHAddProductShoppingCartListTableViewCell : UITableViewCell

@property (nonatomic, assign) id <JCHAddProductShoppingCartListTableViewCellDelegate> delegate;
- (void)hideBottomLine:(BOOL)hidden;
- (void)setData:(JCHAddProductShoppingCartListTableViewCellData *)data;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType;

@end
