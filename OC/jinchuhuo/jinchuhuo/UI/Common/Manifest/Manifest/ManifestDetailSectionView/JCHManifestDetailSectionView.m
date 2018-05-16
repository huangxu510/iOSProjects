//
//  JCHManifestDetailSectionVIew.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHManifestDetailSectionView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "CommonHeader.h"

@interface JCHManifestDetailSectionView ()

@property (nonatomic, assign) NSInteger manifestType;

@end

@implementation JCHManifestDetailSectionView

- (instancetype)initWithFrame:(CGRect)frame manifestType:(NSInteger)manifestType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.manifestType = manifestType;
        [self createUI];
    }
    return self;
}


- (void)createUI
{
    
    self.backgroundColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0f];
    UIColor *titleColor = JCHColorAuxiliary;
    
    CGFloat priceLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:78.0f];
    CGFloat currentStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    
    CGFloat nameLabelRightOffset = 0;
    if (self.manifestType == kJCHManifestInventory) {
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
        make.right.equalTo(self.mas_centerX).offset(-nameLabelRightOffset);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *additionalLabel = nil;
    if (self.manifestType == kJCHManifestInventory) {
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
    [self addSubview:countLabel];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceLabel.mas_right).with.offset([JCHSizeUtility calculateWidthWithSourceWidth:12.0f]);
        make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    UIImageView *bottomLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [self addSubview:bottomLine];
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin / 2);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin / 2);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.bottom.equalTo(self);
    }];
    
 
    
    if (self.manifestType == kJCHManifestInventory) {
        priceLabel.text = @"盈亏数量";
        countLabel.text = @"成本价";
    } else if (self.manifestType == kJCHManifestMigrate) {
        countLabel.text = @"移库数量";
        priceLabel.hidden = YES;
    } else if (self.manifestType == kJCHManifestAssembling) {
        countLabel.text = @"拼后数量";
        priceLabel.hidden = YES;
    } else if (self.manifestType == kJCHManifestDismounting) {
        countLabel.text = @"拆后数量";
        priceLabel.hidden = YES;
    }
    
    return;
}




@end
