//
//  JCHProductListTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHMutipleSelectedTableViewCell.h"
#import "JCHItemListTableViewCell.h"

@interface ProductInfo : NSObject
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *inventoryCount;
@property (retain, nonatomic, readwrite) NSString *inventoryUnit;
@property (retain, nonatomic, readwrite) NSString *productType;
@property (assign, nonatomic, readwrite) BOOL sku_hidden_flag;
@end

@interface JCHProductListTableViewCell : JCHItemListTableViewCell

@property (copy, nonatomic) dispatch_block_t putawayBlock;
@property (copy, nonatomic) dispatch_block_t soldoutBlock;

- (void)setData:(ProductInfo *)productInfo;

@end
