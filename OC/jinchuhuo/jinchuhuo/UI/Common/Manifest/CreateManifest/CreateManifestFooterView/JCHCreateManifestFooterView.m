//
//  JCHCreateManifestFooterView.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestFooterView.h"
#import "JCHUISizeSettings.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "JCHTransactionUtility.h"
#import "Masonry.h"
#import "CommonHeader.h"

@implementation JCHCreateManifestFooterViewData

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
    [self.totalPrice release];
    [self.retain release];
    
    [super dealloc];
    return;
}

@end


@interface JCHCreateManifestFooterView ()
{
    JCHLabel *totalPriceLabel;
    //UILabel *totalDiscountLabel;
    UIButton *remarkButton;
    //JCHButton *discountButton;
    UIButton *saveOrderButton;
}
@end

@implementation JCHCreateManifestFooterView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    self.backgroundColor = JCHColorGlobalBackground;
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    UIFont *buttonTitleFont = [UIFont jchSystemFontOfSize:16.0f];
    CGFloat titleLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    
    CGFloat buttonHeight = 49.0f;
    CGFloat remarkButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:59.0f];
    CGFloat saveButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120.0f];
    
    {
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"合计:"
                                                   font:titleFont
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentRight];
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(titleLabelWidth);
            make.height.mas_equalTo(buttonHeight);
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
        }];
        
        totalPriceLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                              title:@"¥0.00"
                                               font:titleFont
                                          textColor:JCHColorHeaderBackground
                                             aligin:NSTextAlignmentLeft];
        totalPriceLabel.verticalAlignment = kVerticalAlignmentMiddle;
        [self addSubview:totalPriceLabel];
        
        [totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-saveButtonWidth - remarkButtonWidth);
            make.height.mas_equalTo(buttonHeight);
            make.left.equalTo(titleLabel.mas_right).with.offset(5);
            make.top.equalTo(self.mas_top);
        }];
    }

    
    {
        saveOrderButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handleSaveOrder:)
                                               title:@"结账"
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:nil];
        [saveOrderButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
        [saveOrderButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
        [saveOrderButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
        saveOrderButton.titleLabel.font = buttonTitleFont;
        saveOrderButton.layer.cornerRadius = 0;
        [self addSubview:saveOrderButton];
        
        [saveOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.height.mas_equalTo(buttonHeight);
            make.top.equalTo(self);
            //make.left.equalTo(remarkButton.mas_right);
            make.width.mas_equalTo(saveButtonWidth);
        }];
        
        remarkButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleRemarkEditing:)
                                            title:@"备注"
                                       titleColor:JCHColorMainBody
                                  backgroundColor:JCHColorGlobalBackground];
        
        remarkButton.titleLabel.font = buttonTitleFont;
        
        [self addSubview:remarkButton];
        [remarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(remarkButtonWidth);
            make.height.mas_equalTo(buttonHeight);
            make.top.equalTo(self);
            make.right.equalTo(saveOrderButton.mas_left);
        }];
        
        UIView *topLine = [[[UIView alloc] init] autorelease];
        topLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:topLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        {
            UIView *middleLine = [[[UIView alloc] init] autorelease];
            middleLine.backgroundColor = JCHColorSeparateLine;
            [self addSubview:middleLine];
            
            [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(kSeparateLineWidth);
                make.right.equalTo(remarkButton);
                make.top.equalTo(self);
                make.bottom.equalTo(self);
            }];
        }
        
        {
            UIView *middleLine = [[[UIView alloc] init] autorelease];
            middleLine.backgroundColor = JCHColorSeparateLine;
            [self addSubview:middleLine];
            
            [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(kSeparateLineWidth);
                make.right.equalTo(totalPriceLabel);
                make.top.equalTo(self);
                make.bottom.equalTo(self);
            }];
        }
    }
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestInventory || manifestStorage.currentManifestType == kJCHManifestMigrate || manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
        [saveOrderButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    
    return;
}

- (void)handleRemarkEditing:(UIButton *)sender
{
    if ([self.eventDelegate respondsToSelector:@selector(handleEditRemark)]) {
        [self.eventDelegate handleEditRemark];
    }
}

- (void)handleDiscountEditing:(UIButton *)sender
{
    if ([self.eventDelegate respondsToSelector:@selector(handleEditTotalDiscount)]) {
        [self.eventDelegate handleEditTotalDiscount];
    }
}

- (void)handleSaveOrder:(id)sender
{
    if ([self.eventDelegate respondsToSelector:@selector(handleClickSaveOrderList)]) {
        [self.eventDelegate performSelector:@selector(handleClickSaveOrderList)];
    }
    
    return;
}

- (void)setData:(JCHCreateManifestFooterViewData *)data
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        totalPriceLabel.text = [NSString stringWithFormat:@"¥%@", data.totalPrice];
    } else if (manifestStorage.currentManifestType == kJCHManifestInventory || manifestStorage.currentManifestType == kJCHManifestMigrate || manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting || manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
        totalPriceLabel.text = [NSString stringWithFormat:@"%ld个单品", data.productCount];
        totalPriceLabel.textColor = JCHColorMainBody;
    }
    if (data.productCount == 0) {
        saveOrderButton.enabled = NO;
    } else {
        saveOrderButton.enabled = YES;
    }
}

- (void)setSaveButtonTitle:(NSString *)title
{
    [saveOrderButton setTitle:title forState:UIControlStateNormal];
}

@end
