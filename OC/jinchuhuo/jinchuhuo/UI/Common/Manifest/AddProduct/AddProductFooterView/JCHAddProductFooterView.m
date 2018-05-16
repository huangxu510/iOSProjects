//
//  JCHAddProductFooterView.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAddProductFooterView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "Masonry.h"
#import "JCHManifestMemoryStorage.h"
#import "CommonHeader.h"
#import <JSBadgeView.h>



@implementation JCHAddProductFooterViewData

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
    [self.productAmount release];
    [self.remark release];
    
    [super dealloc];
    return;
}

@end


@interface JCHAddProductFooterView ()
{
    JSBadgeView *shoppingCartView;
    UIImageView *shoppingCartImageView;
    UILabel *productAmountLabel;
    UIButton *addToManifestButton;
    UIButton *remarkButton;
    UIView *topLine;
    
    UILabel *_productCountLabel;
    UIButton *_saveButton;
}
@end

@implementation JCHAddProductFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderShipment || kJCHRestaurntManifestOpenTable == manifestStorage.currentManifestType) {
            [self createDefaultUI];
        } else if (manifestStorage.currentManifestType == kJCHManifestInventory || manifestStorage.currentManifestType == kJCHManifestMigrate || manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting || manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
            [self createInventoryCheckUI];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self.shoppingCartButton release];
    
    [super dealloc];
    return;
}

- (void)createInventoryCheckUI
{
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120.0f];
    _saveButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleClickSaveOrderList)
                                       title:@"确定"
                                  titleColor:[UIColor whiteColor]
                             backgroundColor:JCHColorHeaderBackground];
    [_saveButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
    [_saveButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
    _saveButton.titleLabel.font = JCHFont(15.0f);
    _saveButton.layer.cornerRadius = 0;
    [self addSubview:_saveButton];
    
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@""
                                              font:JCHFont(14.0)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:_productCountLabel];
    
    [_productCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(_saveButton.mas_left);
        make.top.bottom.equalTo(_saveButton);
    }];
    
    [self addSeparateLineWithMasonryTop:YES bottom:NO];
}

- (void)createDefaultUI
{
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0];
    
    self.backgroundColor = JCHColorGlobalBackground;
    UIFont *textFont = [UIFont jchSystemFontOfSize:15.0f];
    
    //购物车
    {
        shoppingCartImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_ic_shoppingtrolley"]] autorelease];
        shoppingCartImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:shoppingCartImageView];
        
        [shoppingCartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(10);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(25);
            make.centerY.equalTo(self);
        }];
        
        
        self.shoppingCartButton = [JCHUIFactory createButton:CGRectZero
                                                      target:self
                                                      action:@selector(handleShowTransactionList:)
                                                       title:nil
                                                  titleColor:[UIColor clearColor]
                                             backgroundColor:nil];
        [self addSubview:self.shoppingCartButton];
        
        [self.shoppingCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(shoppingCartImageView).with.offset(20);
            make.height.equalTo(self );
            make.centerY.equalTo(self);
        }];
        
        shoppingCartView = [[[JSBadgeView alloc] initWithParentView:shoppingCartImageView alignment:JSBadgeViewAlignmentTopRight] autorelease];
        shoppingCartView.badgeBackgroundColor = JCHColorHeaderBackground;
        shoppingCartView.badgeTextFont = [UIFont systemFontOfSize:12.0f];
        shoppingCartView.badgeTextColor = [UIColor whiteColor];
        shoppingCartView.hidden = YES;
    }
    
    // 添加到订单
    {
#if MMR_RESTAURANT_VERSION
        NSString *buttonTitle = @"下单";
#else
        NSString *buttonTitle = @"结账";
#endif
        
        const CGFloat addBtnWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120.0f];
        addToManifestButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(handleClickSaveOrderList)
                                                   title:buttonTitle
                                              titleColor:[UIColor whiteColor]
                                         backgroundColor:nil];
        addToManifestButton.titleLabel.font = textFont;
        [addToManifestButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
        [addToManifestButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
        [addToManifestButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
        addToManifestButton.adjustsImageWhenHighlighted = NO;
        [self addSubview:addToManifestButton];
        
        [addToManifestButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addBtnWidth);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    
#if !MMR_RESTAURANT_VERSION
    // 备注
    {
        CGFloat buttonHeight = 49.0f;
        CGFloat remarkButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:59.0f];
        
        remarkButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleRemarkEditing:)
                                            title:@"备注"
                                       titleColor:JCHColorMainBody
                                  backgroundColor:JCHColorGlobalBackground];
        //remarkButton.labelVerticalOffset = -2;
        
        
        //[remarkButton setImage:[UIImage imageNamed:@"addgoods_btn_normal_submit"] forState:0];
        remarkButton.titleLabel.font = textFont;
        
        [self addSubview:remarkButton];
        [remarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(remarkButtonWidth);
            make.height.mas_equalTo(buttonHeight);
            make.top.equalTo(self);
            make.right.equalTo(addToManifestButton.mas_left);
        }];
    }
#endif
    
    // 金额
    {
#if MMR_RESTAURANT_VERSION
        NSString *buttonTitle = @"合计: ¥00.00";
#else
        NSString *buttonTitle = @"¥00.00";
#endif
        
        productAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:buttonTitle
                                                  font:textFont
                                             textColor:JCHColorHeaderBackground
                                                aligin:NSTextAlignmentRight];
        productAmountLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:productAmountLabel];
        
        [productAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shoppingCartButton.mas_right).with.offset(currentkStandardLeftMargin);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
#if MMR_RESTAURANT_VERSION
            make.right.equalTo(addToManifestButton.mas_left).with.offset(-currentkStandardLeftMargin);
#else
            make.right.equalTo(remarkButton.mas_left).with.offset(-currentkStandardLeftMargin);
#endif
        }];
    }
    
    //顶部水平线
    topLine = [[[UIView alloc] init] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
    
#if !MMR_RESTAURANT_VERSION
    UIView *middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:middleLine];
    
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kSeparateLineWidth);
        make.left.equalTo(remarkButton);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
#endif
}

- (void)handleShowTransactionList:(id)sender
{
    NSArray *transactionList = [[JCHManifestMemoryStorage sharedInstance] getAllManifestRecord];
    if ((transactionList.count == 0) || transactionList == nil) {
        return;
    }
    if (YES == [self.delegate respondsToSelector:@selector(handleShowTransactionList)]) {
        [self.delegate performSelector:@selector(handleShowTransactionList)];
    }
    
    return;
}

- (void)setViewData:(JCHAddProductFooterViewData *)viewData animation:(BOOL)animation
{
    if (viewData.transactionCount == 0) {
        shoppingCartView.hidden = YES;
        addToManifestButton.enabled = NO;
        _saveButton.enabled = NO;
    }
    else
    {
        shoppingCartView.hidden = NO;
        addToManifestButton.enabled = YES;
        _saveButton.enabled = YES;
    }
    
    [self bringSubviewToFront:shoppingCartImageView];
    
    //usingSpringWithDamping的范围为0.0f到1.0f，数值越小「弹簧」的振动效果越明显
    //initialSpringVelocity则表示初始的速度，数值越大一开始移动越快。
     shoppingCartView.transform = CGAffineTransformMakeTranslation(0, -100);
    
    [UIView animateWithDuration:animation ? 0.5 : 0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:0 animations:^{
           
           shoppingCartView.transform = CGAffineTransformIdentity;
       } completion:^(BOOL finished) {
           
           [self sendSubviewToBack:shoppingCartImageView];
#if MMR_RESTAURANT_VERSION
           productAmountLabel.text = [NSString stringWithFormat:@"合计: ¥%@", viewData.productAmount];
#else
           productAmountLabel.text = [NSString stringWithFormat:@"¥%@", viewData.productAmount];
#endif
           
           shoppingCartView.badgeText = [NSString stringWithFormat:@"%ld", viewData.transactionCount];
           }];

    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        _productCountLabel.text = [NSString stringWithFormat:@"已拼%ld个单品", viewData.transactionCount];
    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
        _productCountLabel.text = [NSString stringWithFormat:@"已拆%ld个单品", viewData.transactionCount];
    } else {
        _productCountLabel.text = [NSString stringWithFormat:@"已选择%ld个单品", viewData.transactionCount];
    }
}

- (void)enableSaveButton
{
    _saveButton.enabled = YES;
}

#pragma mark - SaveRecord 结账
- (void)handleClickSaveOrderList
{
    if ([self.delegate respondsToSelector:@selector(handleClickSaveOrderList)]) {
        [self.delegate performSelector:@selector(handleClickSaveOrderList)];
    }
}

#pragma mark -
#pragma mark 编辑备注
- (void)handleRemarkEditing:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleEditRemark)]) {
        [self.delegate handleEditRemark];
    }
}

@end
