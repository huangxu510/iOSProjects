//
//  JCHCreateManifestTableSectionView.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestTableSectionView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "CommonHeader.h"

@interface JCHCreateManifestTableSectionView ()
{

}
@end

@implementation JCHCreateManifestTableSectionView

- (id)initWithTopLine:(BOOL)topLine BottomLine:(BOOL)bottomLine
{
    self = [super initWithTopLine:topLine BottomLine:bottomLine];
    if (self) {
        
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    self.backgroundColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0f];
    UIColor *titleColor = JCHColorAuxiliary;
    
    CGFloat priceLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:78.0f];
    CGFloat currentStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    
    CGFloat nameLabelRightOffset = 0;
    if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        nameLabelRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
        
        priceLabelWidth = (kScreenWidth / 2 + nameLabelRightOffset - 1.5 * currentStandardLeftMargin) / 3;
    }
    
    if (manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
        nameLabelRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
        
        priceLabelWidth = (kScreenWidth / 2 + nameLabelRightOffset - 1.5 * currentStandardLeftMargin) / 3;
    }
    
    UILabel *nameLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"品名"
                                              font:titleFont
                                         textColor:titleColor
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(currentStandardLeftMargin);
        make.right.equalTo(self.mas_centerX).with.offset(-nameLabelRightOffset);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    

    UILabel *additionalLabel = nil;
    if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        additionalLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"盘后数量"
                                                        font:titleFont
                                                   textColor:titleColor
                                                      aligin:NSTextAlignmentRight];
        additionalLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:additionalLabel];
        [additionalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).with.offset(currentStandardLeftMargin / 2);
            make.top.bottom.equalTo(nameLabel);
            make.width.mas_equalTo(priceLabelWidth);
        }];
    }
    
    if (manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
        additionalLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"盘后数量"
                                               font:titleFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
        additionalLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:additionalLabel];
        [additionalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).with.offset(currentStandardLeftMargin / 2);
            make.top.bottom.equalTo(nameLabel);
            make.width.mas_equalTo(priceLabelWidth);
        }];
    }
    
    
    UILabel *priceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"单价"
                                               font:titleFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
    priceLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:priceLabel];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(additionalLabel ? additionalLabel.mas_right : nameLabel.mas_right);
        make.width.mas_equalTo(priceLabelWidth);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    UILabel *countLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"数量"
                                               font:titleFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
    countLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:countLabel];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceLabel.mas_right);
        make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    
    
    
    
    if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        priceLabel.text = @"盈亏数量";
        countLabel.text = @"成本价";
    } else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        priceLabel.hidden = YES;
        CGFloat showMenuButtonWidth = 26;
        [countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right);
            make.right.equalTo(self).with.offset(-2 * currentStandardLeftMargin - showMenuButtonWidth);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
    } else if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        priceLabel.hidden = YES;
        CGFloat showMenuButtonWidth = 26;
        countLabel.text = @"拼装数量";
        [countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right);
            make.right.equalTo(self).with.offset(-2 * currentStandardLeftMargin - showMenuButtonWidth);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
        priceLabel.hidden = YES;
        CGFloat showMenuButtonWidth = 26;
        countLabel.text = @"拆装数量";
        [countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right);
            make.right.equalTo(self).with.offset(-2 * currentStandardLeftMargin - showMenuButtonWidth);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
    } else if (manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
        priceLabel.text = @"损耗数量";
        countLabel.text = @"平均成本";
    }

    return;
}

@end
