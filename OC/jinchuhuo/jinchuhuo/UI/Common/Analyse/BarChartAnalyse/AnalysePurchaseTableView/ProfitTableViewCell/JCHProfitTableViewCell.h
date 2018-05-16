//
//  JCHProfitTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProfitTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productCategory;
@property (nonatomic, retain) NSString *productSaleAmount;
@property (nonatomic, retain) NSString *productProfitAmount;
@property (nonatomic, retain) NSString *productProfitRate;

@end

@interface JCHProfitTableViewCell : UITableViewCell

- (void)setData:(JCHProfitTableViewCellData *)data;

@end
