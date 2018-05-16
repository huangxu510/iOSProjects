//
//  JCHContactTopTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

enum
{
    kJCHContactTopViewButtonTagClient = 1,    //客户
    kJCHContactTopViewButtonTagSupplier,    //供应商
    kJCHContactTopViewButtonTagColleague, //同事
};

@interface JCHContactTopViewButton : UIButton

@property (nonatomic, retain) UILabel *numberLabel;
@property (nonatomic, retain) UILabel *categoryLabel;

@end

@class JCHContactsTopTableViewCell;
@protocol JCHContactTopTableViewCellDelegate <NSObject>

- (void)handleSwitchToGroupList:(JCHContactsTopTableViewCell *)cell button:(UIButton *)button;

@end

@interface JCHContactsTopTableViewCellData : NSObject

@property (nonatomic, assign) NSInteger clientCount;
@property (nonatomic, assign) NSInteger supplierCount;
@property (nonatomic, assign) NSInteger colleagueCount;

@end

@interface JCHContactsTopTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) id <JCHContactTopTableViewCellDelegate> delegate;

- (void)setCellData:(JCHContactsTopTableViewCellData *)data;

@end
