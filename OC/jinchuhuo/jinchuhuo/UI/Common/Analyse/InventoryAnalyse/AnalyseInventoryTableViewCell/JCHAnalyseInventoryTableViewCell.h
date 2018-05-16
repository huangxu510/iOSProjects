//
//  JCHAnaluseInventoryTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAnalyseInventoryTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productAmount;
@property (nonatomic, retain) NSString *productRate;

@end
@interface JCHAnalyseInventoryTableViewCell : UITableViewCell

- (void)setData:(JCHAnalyseInventoryTableViewCellData *)data;

@end
