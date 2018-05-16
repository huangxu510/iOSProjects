//
//  JCHProductCategoryTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductCategoryTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productCategory;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productPurchaseAmount;

@end
@interface JCHProductCategoryTableViewCell : UITableViewCell

- (void)setData:(JCHProductCategoryTableViewCellData *)data;

@end