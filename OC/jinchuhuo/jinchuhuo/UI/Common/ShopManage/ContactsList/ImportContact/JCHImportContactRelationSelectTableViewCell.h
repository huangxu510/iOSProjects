//
//  JCHImportContactRelationSelectTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

enum
{
    kJCHClientButtonTag = 0,
    kJCHSupplierButtonTag,
    kJCHColleagueButtonTag,
};

@interface JCHImportContactRelationSelectTableViewCellData : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL clientButtonSelected;
@property (nonatomic, assign) BOOL supplierButtonSelected;
@property (nonatomic, assign) BOOL colleagueButtonSelected;

@end

@class JCHImportContactRelationSelectTableViewCell;
@protocol JCHImportContactRelationSelectTableViewCellDelegate <NSObject>

- (void)handleSelectCell:(JCHImportContactRelationSelectTableViewCell *)cell Relation:(UIButton *)button;

@end

@interface JCHImportContactRelationSelectTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) id <JCHImportContactRelationSelectTableViewCellDelegate> delegate;
- (void)setCellData:(JCHImportContactRelationSelectTableViewCellData *)data;
- (void)setTitleLabelColor:(UIColor *)color;

@end
