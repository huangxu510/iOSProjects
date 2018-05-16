//
//  JCHProductDetailTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductDetailTableViewCellData : NSObject

@property (nonatomic, retain) NSString *skuCombine;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) NSString *purchasePrice;
@property (nonatomic, retain) NSString *shipmentPrice;

@end

@interface JCHProductDetailTableViewCell : UITableViewCell

- (void)setCellData:(JCHProductDetailTableViewCellData *)data;

@end
