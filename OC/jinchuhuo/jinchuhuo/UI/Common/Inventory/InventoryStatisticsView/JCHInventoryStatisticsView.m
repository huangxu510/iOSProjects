//
//  JCHInventoryStatisticsView.m
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHInventoryStatisticsView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"

@implementation JCHInventoryStatisticsViewData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.inventoryCount release];
    [self.shipmentCount release];
    [self.purchasesCount release];
    
    [super dealloc];
    return;
}

@end

@interface JCHInventoryStatisticsView ()
{
    UILabel *inventoryCountLabel;
    UILabel *shipmentCountLabel;
    UILabel *purchasesCountLabel;
}
@end

@implementation JCHInventoryStatisticsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    self.backgroundColor = JCHColorGlobalBackground;
    
    const CGFloat labelWidth = self.frame.size.width / 3;
    const CGFloat labelHeight = self.frame.size.height/ 2;
    const CGFloat heightOffset = 18.0f;
    UIFont *labelFont = [UIFont systemFontOfSize:13.0f];
    UIFont *valueFont = [UIFont boldSystemFontOfSize:17.0f];
    UIColor *titleColor = JCHColorMainBody;
    
    UILabel *purchasesTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"本月进货"
                                                        font:labelFont
                                                   textColor:titleColor
                                                      aligin:NSTextAlignmentCenter];
    [self addSubview:purchasesTitleLabel];
    [purchasesTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).with.offset(heightOffset / 4);
    }];
    
    purchasesCountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"00.00"
                                               font:valueFont
                                          textColor:JCHColorHeaderBackground
                                             aligin:NSTextAlignmentCenter];
    [self addSubview:purchasesCountLabel];
    [purchasesCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(purchasesTitleLabel.mas_bottom).with.offset(-heightOffset / 2);
    }];
    
    UILabel *inventoryTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"我的库存"
                                                        font:labelFont
                                                   textColor:titleColor
                                                      aligin:NSTextAlignmentCenter];
    [self addSubview:inventoryTitleLabel];
    [inventoryTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(purchasesTitleLabel.mas_right);
        make.top.equalTo(self.mas_top).with.offset(heightOffset / 4);
    }];
    
    
    inventoryCountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"00.00"
                                               font:valueFont
                                          textColor:JCHColorHeaderBackground
                                             aligin:NSTextAlignmentCenter];
    [self addSubview:inventoryCountLabel];
    [inventoryCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(inventoryTitleLabel.mas_left);
        make.top.equalTo(inventoryTitleLabel.mas_bottom).with.offset(-heightOffset / 2);
    }];
    
    

    UILabel *shipmentTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"本月出货"
                                                        font:labelFont
                                                    textColor:titleColor
                                                        aligin:NSTextAlignmentCenter];
    [self addSubview:shipmentTitleLabel];
    [shipmentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(inventoryTitleLabel.mas_right);
        make.top.equalTo(inventoryTitleLabel.mas_top);
    }];
    
    shipmentCountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"00.00"
                                              font:valueFont
                                         textColor:JCHColorHeaderBackground
                                            aligin:NSTextAlignmentCenter];
    [self addSubview:shipmentCountLabel];
    [shipmentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(labelHeight);
        make.left.equalTo(shipmentTitleLabel.mas_left);
        make.top.equalTo(inventoryCountLabel.mas_top);
    }];
    
    CGFloat separateLineHeight = 42.0f;
    
    {
        UIView *verticalSeperatorView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
        [self addSubview:verticalSeperatorView];
        [verticalSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(purchasesTitleLabel.mas_right);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.height.mas_equalTo(separateLineHeight);
        }];
    }
    
    {
        UIView *verticalSeperatorView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
        [self addSubview:verticalSeperatorView];
        [verticalSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(inventoryTitleLabel.mas_right);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.height.mas_equalTo(separateLineHeight);
        }];
    }

    
    UIView *horizonSeperatorView = [JCHUIFactory createSeperatorLine:1.0f];
    [self addSubview:horizonSeperatorView];
    [horizonSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    
    
    return;
}

- (void)setViewData:(JCHInventoryStatisticsViewData *)viewData
{
    UIFont *symbolFont = [UIFont boldSystemFontOfSize:13.0f];
    UIFont *valueFont = [UIFont boldSystemFontOfSize:17.0f];
    
    NSAttributedString *symbol = [[[NSAttributedString alloc] initWithString:@"¥ " attributes:@{NSFontAttributeName : symbolFont}] autorelease];
   
    NSMutableAttributedString *inventoryConut = [[[NSMutableAttributedString alloc] initWithString:viewData.inventoryCount attributes:@{NSFontAttributeName : valueFont}] autorelease];
    NSMutableAttributedString *shipmentConut = [[[NSMutableAttributedString alloc] initWithString:viewData.shipmentCount attributes:@{NSFontAttributeName : valueFont}] autorelease];
    NSMutableAttributedString *purchasesConut = [[[NSMutableAttributedString alloc] initWithString:viewData.purchasesCount attributes:@{NSFontAttributeName : valueFont}] autorelease];
    
    [inventoryConut insertAttributedString:symbol atIndex:0];
    [shipmentConut insertAttributedString:symbol atIndex:0];
    [purchasesConut insertAttributedString:symbol atIndex:0];
    
    inventoryCountLabel.attributedText = inventoryConut;
    shipmentCountLabel.attributedText = shipmentConut;
    purchasesCountLabel.attributedText = purchasesConut;
    
    return;
}

@end
