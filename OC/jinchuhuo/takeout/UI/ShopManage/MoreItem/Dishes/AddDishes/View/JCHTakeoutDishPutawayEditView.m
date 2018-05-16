//
//  JCHTakeoutDishPutawayEditView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutDishPutawayEditView.h"
#import "CommonHeader.h"

@implementation JCHTakeoutDishPutawayEditViewData

- (void)dealloc
{
    self.skuName = nil;
    self.inventory = nil;
    self.price = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutDishPutawayEditView
{
    UISwitch *_infiniteInventorySwitch;
    UIButton *_closeButton;
    UILabel *_skuCombineLabel;
    JCHBottomArrowButton *_inventoryCountButton;
    JCHBottomArrowButton *_priceButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.selectedButton = nil;
    self.closeViewBlock = nil;
    self.editLabelChangeBlock = nil;
    [self.price release];
    [self.price release];
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat titleHeight = 50;
    CGFloat middleHeight = 35;
    CGFloat bottomHeight = 50;
    CGFloat rightLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100];
    self.backgroundColor = JCHColorGlobalBackground;
    
    UILabel *switchTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"无限库存"
                                                     font:JCHFont(14.0)
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self addSubview:switchTitleLabel];
    
    CGSize fitSize = [switchTitleLabel sizeThatFits:CGSizeZero];
    [switchTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.top.equalTo(self);
        make.width.mas_equalTo(fitSize.width + 10);
        make.height.mas_equalTo(titleHeight);
    }];
    
    _infiniteInventorySwitch = [[[UISwitch alloc] init] autorelease];
    _infiniteInventorySwitch.onTintColor = JCHColorHeaderBackground;
    [_infiniteInventorySwitch addTarget:self action:@selector(handleInfiniteInventorySwitch:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_infiniteInventorySwitch];
    
    [_infiniteInventorySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(switchTitleLabel.mas_right).offset(kStandardLeftMargin);
        make.centerY.equalTo(switchTitleLabel);
    }];
    
    _closeButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleCloseView)
                                        title:nil
                                   titleColor:nil
                              backgroundColor:nil];
    [_closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
    [self addSubview:_closeButton];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(titleHeight);
        make.width.mas_equalTo(60);
    }];
    
    UIView *middleContainerView = [[[UIView alloc] init] autorelease];
    middleContainerView.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:middleContainerView];
    [middleContainerView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [middleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(switchTitleLabel.mas_bottom);
        make.height.mas_equalTo(middleHeight);
        make.left.right.equalTo(self);
    }];
    
    UILabel *rightTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"单价"
                                                    font:JCHFont(12.0)
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentCenter];
    [middleContainerView addSubview:rightTitleLabel];
    
    [rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.bottom.equalTo(middleContainerView);
        make.width.mas_equalTo(rightLabelWidth);
    }];
    
    UILabel *middleTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"库存"
                                                     font:JCHFont(12.0)
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentCenter];
    [middleContainerView addSubview:middleTitleLabel];
    
    [middleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightTitleLabel.mas_left);
        make.top.bottom.equalTo(middleContainerView);
        make.width.mas_equalTo(rightLabelWidth);
    }];
    
    UILabel *leftTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"单品"
                                                   font:JCHFont(12.0)
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentLeft];
    [middleContainerView addSubview:leftTitleLabel];
    
    [leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(middleContainerView).offset(kStandardLeftMargin);
        make.right.equalTo(middleTitleLabel.mas_left);
        make.top.bottom.equalTo(middleContainerView);
    }];
    
    
    
    UIView *bottomComtainerView = [[[UIView alloc] init] autorelease];
    bottomComtainerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomComtainerView];
    
    [bottomComtainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleContainerView.mas_bottom);
        make.bottom.left.right.equalTo(self);
    }];
    
    _skuCombineLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"skuName"
                                            font:JCHFont(14.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    [bottomComtainerView addSubview:_skuCombineLabel];
    
    [_skuCombineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(leftTitleLabel);
        make.top.bottom.equalTo(bottomComtainerView);
    }];
    
    _inventoryCountButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
    _inventoryCountButton.tag = kJCHTakeoutPutawayButtonTagInventory;
    _inventoryCountButton.titleLabel.font = JCHFont(13);
    _inventoryCountButton.titleLabel.text = @"0";
    _inventoryCountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _inventoryCountButton.detailLabelHidden = YES;
    [_inventoryCountButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomComtainerView addSubview:_inventoryCountButton];
    
    [_inventoryCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(middleTitleLabel);
        make.top.bottom.equalTo(bottomComtainerView);
    }];
    
    _priceButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
    _priceButton.tag = kJCHTakeoutPutawayButtonTagPrice;
    _priceButton.selected = YES;
    self.selectedButton = _priceButton;
    _priceButton.titleLabel.text = @"0.00";
    _priceButton.titleLabel.font = JCHFont(13);
    _priceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _priceButton.detailLabelHidden = YES;
    [_priceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomComtainerView addSubview:_priceButton];
    
    [_priceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightTitleLabel);
        make.top.bottom.equalTo(bottomComtainerView);
    }];

    
    self.viewHeight = titleHeight + middleHeight + bottomHeight;
}

- (void)buttonClick:(JCHBottomArrowButton *)sender
{
    if (sender == self.selectedButton) {
        return;
    }
    sender.selected = YES;
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    
    if (self.editLabelChangeBlock) {
        self.editLabelChangeBlock(sender);
    }
}

- (void)handleInfiniteInventorySwitch:(UISwitch *)sender
{
    if (sender.on) {
        [self buttonClick:_priceButton];
        _inventoryCountButton.enabled = NO;
        _inventoryCountButton.titleLabel.text = @"*";
    } else {
        _inventoryCountButton.enabled = YES;
        _inventoryCountButton.titleLabel.text = @"0";
    }
}

- (void)handleCloseView
{
    if (self.closeViewBlock) {
        self.closeViewBlock();
    }
}

- (NSString *)inventory
{
    return [_inventoryCountButton.titleLabel.text retain];
}

- (NSString *)price
{
    NSString *price = [_priceButton.titleLabel.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    return price;
}

- (void)setViewData:(JCHTakeoutDishPutawayEditViewData *)data
{
    _skuCombineLabel.text = data.skuName;
    _inventoryCountButton.titleLabel.text = data.inventory;
    _priceButton.titleLabel.text = [NSString stringWithFormat:@"¥%.2f", data.price.doubleValue];
    
    if ([data.inventory isEqualToString:@"*"]) {
        _infiniteInventorySwitch.on = YES;
        _inventoryCountButton.enabled = NO;
    }
}


@end
