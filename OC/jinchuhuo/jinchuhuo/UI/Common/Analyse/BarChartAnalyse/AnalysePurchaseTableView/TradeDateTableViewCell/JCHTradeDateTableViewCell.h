//
//  JCHTradeDateTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTradeDateTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productDate;
@property (nonatomic, retain) NSString *productPurchaseAmount;

@end
@interface JCHTradeDateTableViewCell : UITableViewCell

- (void)setData:(JCHTradeDateTableViewCellData *)data;

@end
