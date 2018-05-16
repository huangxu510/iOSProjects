//
//  JCHSavingCardLadderCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, JCHSavingCardLadderCellTextFieldTag)
{
    kJCHSavingCardLadderCellDiscountTextFieldTag = 0,
    kJCHSavingCardLadderCellLowerLimitAmountTextFieldTag,
    kJCHSavingCardLadderCellUpperLimitAmountTextFieldTag,
};


@interface JCHSavingCardLadderCellData : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat lowerLimitAmount;
@property (nonatomic, assign) CGFloat upperLimitAmount;
@property (nonatomic, assign) CGFloat discount;

@end

@interface JCHSavingCardLadderCell : JCHBaseTableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) void(^textFieldDidEndEditingBlock)(UITextField *, JCHSavingCardLadderCell *);
@property (nonatomic, copy) void(^textFieldEditingChangedBlock)(UITextField *, JCHSavingCardLadderCell *);

- (void)setCellData:(JCHSavingCardLadderCellData *)data;
- (void)setLowerLimitAmountTextFieldEnabled:(BOOL)enabled;

@end
