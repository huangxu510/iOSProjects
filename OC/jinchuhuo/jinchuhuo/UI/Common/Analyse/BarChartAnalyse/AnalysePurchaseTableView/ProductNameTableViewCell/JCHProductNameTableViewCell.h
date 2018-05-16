//
//  JCHProductNameTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductNameTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productPurchaseAmount;

@end
@interface JCHProductNameTableViewCell : UITableViewCell

- (void)setData:(JCHProductNameTableViewCellData *)data;

@end
