//
//  JCHSettlementTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

enum
{
    kJCHSettlementStatusApply = 0,   //可以申请
    kJCHSettlementStatusHasApply,    //已申请
    kJCHSettlementStatusOnAuditing,  //审核中
    kJCHSettlementStatusOpen,        //可以开通
    kJCHSettlementStatusHasOpen,     //已经开通
    kJCHSettlementStatusDisable,     //
};

@interface JCHSettlementTableViewCellData : NSObject

@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *detailText;
@property (nonatomic, assign) NSInteger settlementStatus;

@end

@class JCHSettlementTableViewCell;
@protocol JCHSettlementTableViewCellDelegate <NSObject>

- (void)handleJCHSettlementTableViewCellDelegateClick:(JCHSettlementTableViewCell *)cell;

@end

@interface JCHSettlementTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) id <JCHSettlementTableViewCellDelegate> delegate;

- (void)setCellData:(JCHSettlementTableViewCellData *)data;

@end
