//
//  JCHRestaurantSKUItemView.m
//  jinchuhuo
//
//  Created by apple on 2017/1/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantSKUItemView.h"
#import "JCHRestaurantSKUItemCollectionCell.h"
#import "JCHRestaurantAddProductSKUSelectView.h"
#import "CommonHeader.h"

#define kMinHeight 180
#define kMaxHeight 250
#define kTopLabelHeight 24
#define kBottomContainerViewHeight 44

@interface JCHRestaurantSKUItemView ()<JCHRestaurantAddProductSKUSelectViewDelegate>
{
    UILabel *topItemNameLabel;
    UILabel *itemTitleTipsLabel;
    UILabel *amountLabel;
    UIButton *addButton;
    UIButton *minusButton;
    UIButton *closeButton;
    UILabel *countLabel;
    UIView *bottomContentView;
    UIScrollView *contentScrollView;
    NSInteger currentSelectedCellIndex;
    CGFloat skuSelectContainerViewHeight;
}

@property (retain, nonatomic, readwrite) GoodsSKURecord4Cocoa *goodsSKURecord;
@property (retain, nonatomic, readwrite) ProductRecord4Cocoa *goodsRecord;
@property (retain, nonatomic, readwrite) NSArray *skuSelectViewArray;
@property (retain, nonatomic, readwrite) NSArray *propertySelectSKUViewArray;

@end

@implementation JCHRestaurantSKUItemView

- (id)initWithFrame:(CGRect)frame
        goodsRecord:(ProductRecord4Cocoa *)goodsRecord
     goodsSKURecord:(GoodsSKURecord4Cocoa *)goodsSKURecord
{
    self = [super initWithFrame:frame];
    if (self) {
        currentSelectedCellIndex = 0;
        self.goodsSKURecord = goodsSKURecord;
        self.goodsRecord = goodsRecord;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.goodsSKURecord = nil;
    self.goodsRecord = nil;
    self.skuSelectViewArray = nil;
    self.propertySelectSKUViewArray = nil;
    
    [super dealloc];
    return;
}

- (void)createUI
{
    topItemNameLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:self.goodsRecord.goods_name
                                            font:JCHFont(16.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    [self addSubview:topItemNameLabel];
    
    itemTitleTipsLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"规格"
                                              font:JCHFont(13.0)
                                         textColor:[UIColor lightGrayColor]
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:itemTitleTipsLabel];
    itemTitleTipsLabel.hidden = YES;
    
    bottomContentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:bottomContentView];
    bottomContentView.backgroundColor = UIColorFromRGB(0XF3F3F3);
    
    amountLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"0.00"
                                       font:JCHFont(14.0)
                                  textColor:JCHColorHeaderBackground
                                     aligin:NSTextAlignmentLeft];
    [bottomContentView addSubview:amountLabel];
    
    countLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"0"
                                      font:JCHFont(14.0)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentCenter];
    [bottomContentView addSubview:countLabel];
    
    addButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleIncreaseProductCount:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [bottomContentView addSubview:addButton];
    [addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"]
               forState:UIControlStateNormal];
    
    minusButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleDecreaseProductCount:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [bottomContentView addSubview:minusButton];
    [minusButton setImage:[UIImage imageNamed:@"addgoods_btn_minus"]
               forState:UIControlStateNormal];
    
    closeButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleClose:)
                                       title:nil
                                  titleColor:nil
                             backgroundColor:nil];
    [self addSubview:closeButton];
    [closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose@2x"]
                 forState:UIControlStateNormal];
    
    contentScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:contentScrollView];
    [self createSKUSelectedViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat tipsLabelHeight = 22.0;
    CGFloat bottomAmountLabelHeight = 36;
    
    [bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kBottomContainerViewHeight);
    }];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(kTopLabelHeight);
        make.width.mas_equalTo(kTopLabelHeight);
    }];
    
    [topItemNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(kStandardTopMargin);
        make.left.equalTo(self).with.offset(kStandardLeftMargin + 10);
        make.right.equalTo(closeButton.mas_left);
        make.height.mas_equalTo(kTopLabelHeight);
    }];
    
    [itemTitleTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topItemNameLabel.mas_bottom);
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(tipsLabelHeight);
    }];
    
    [contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(itemTitleTipsLabel.mas_top);
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.mas_right).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(amountLabel.mas_top);
    }];
    
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin + 10);
        make.height.mas_equalTo(kBottomContainerViewHeight);
        make.centerY.equalTo(bottomContentView);
        make.width.mas_equalTo(120.0);
    }];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-kStandardRightMargin);
        make.height.mas_equalTo(64.0);
        make.centerY.equalTo(bottomContentView);
        make.width.mas_equalTo(bottomAmountLabelHeight);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addButton.mas_left);
        make.height.mas_equalTo(64.0);
        make.centerY.equalTo(bottomContentView);
        make.width.mas_equalTo(48.0);
    }];
    
    [minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(countLabel.mas_left);
        make.height.mas_equalTo(64.0);
        make.centerY.equalTo(bottomContentView);
        make.width.mas_equalTo(bottomAmountLabelHeight);
    }];
    
    return;
}

- (void)createSKUSelectedViews
{
    //skuArray : @[@{skuTypeName : @[skuValueRecord, ...]}, ...];
    NSArray *skuArray = self.goodsSKURecord.skuArray;
    skuSelectContainerViewHeight = 0;
    NSMutableArray *viewArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSInteger i = 0; i < skuArray.count; i++) {
        CGRect viewFrame = CGRectMake(0, skuSelectContainerViewHeight, kWidth - 16, 0);
        JCHRestaurantAddProductSKUSelectView *skuSelectView = [[[JCHRestaurantAddProductSKUSelectView alloc] initWithFrame:viewFrame] autorelease];
        skuSelectView.delegate = self;
        skuSelectView.autoSelectIfOneSKUValue = YES;
        [skuSelectView setButtonSKUData:skuArray[i]];
        [skuSelectView setBrokenLineViewHidden:YES];
        viewFrame.size.height = skuSelectView.viewHeight;
        skuSelectView.frame = viewFrame;
        skuSelectContainerViewHeight += skuSelectView.viewHeight;
        [contentScrollView addSubview:skuSelectView];
        [viewArray addObject:skuSelectView];
    }
    self.skuSelectViewArray = viewArray;
    
    viewArray = [[[NSMutableArray alloc] init] autorelease];
    NSArray *property = [self.goodsRecord.cuisineProperty jsonStringToArrayOrDictionary];
    for (NSDictionary *dict in property) {
        NSLog(@"%@", dict);
        CGRect viewFrame = CGRectMake(0, skuSelectContainerViewHeight, kWidth - 16, 0);
        JCHRestaurantAddProductSKUSelectView *skuSelectView = [[[JCHRestaurantAddProductSKUSelectView alloc] initWithFrame:viewFrame] autorelease];
        skuSelectView.delegate = self;
        skuSelectView.autoSelectIfOneSKUValue = YES;
        [skuSelectView setButtonPropertyData:dict];
        [skuSelectView setBrokenLineViewHidden:YES];
        viewFrame.size.height = skuSelectView.viewHeight;
        skuSelectView.frame = viewFrame;
        skuSelectContainerViewHeight += skuSelectView.viewHeight;
        [contentScrollView addSubview:skuSelectView];
        [viewArray addObject:skuSelectView];
    }
    self.propertySelectSKUViewArray = viewArray;
//    if (skuArray.count > 0) {
//        skuSelectContainerViewHeight += 59;
//    }
    
    
    contentScrollView.contentSize = CGSizeMake(self.frame.size.width - 2 * kStandardLeftMargin, skuSelectContainerViewHeight);
    
    CGRect frame = self.frame;
    CGFloat realHeight = contentScrollView.contentSize.height + kTopLabelHeight + kStandardLeftMargin + kBottomContainerViewHeight;
    realHeight = MIN(realHeight, kMaxHeight);
    realHeight = MAX(realHeight, kMinHeight);
    frame.size.height = realHeight;
    self.frame = frame;}

- (void)handleIncreaseProductCount:(id)sender
{
    BOOL hasSelectAll = YES;
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        if (nil == selectSKUArray || selectSKUArray.count == 0) {
            hasSelectAll = NO;
            break;
        }
    }
    
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *selectProperty = itemView.selectedPropertyData;
        if (nil == selectProperty || [selectProperty isEmptyString]) {
            hasSelectAll = NO;
            break;
        }
    }
    
    if (NO == hasSelectAll) {
        return;
    }
    
    NSMutableArray *finalSelectedSKUArray = [[[NSMutableArray alloc] init] autorelease];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        [finalSelectedSKUArray addObject:selectSKUArray];
    }
    
    NSMutableString *finalProperty = [NSMutableString stringWithString:@""];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *property = itemView.selectedPropertyData;
        if ([self.propertySelectSKUViewArray indexOfObject:itemView] == 0) {
            [finalProperty appendString:property];
        } else {
            [finalProperty appendString:[NSString stringWithFormat:@",%@", property]];
        }
    }
    
    NSInteger totalCount = countLabel.text.integerValue;
    totalCount += 1;
    
    countLabel.text = [NSString stringWithFormat:@"%d", (int)totalCount];
    
    if ([self.delegate respondsToSelector:@selector(handleRestaurantIncreaseSKUDishCount:goodsRecord:property:)]) {
        [self.delegate handleRestaurantIncreaseSKUDishCount:finalSelectedSKUArray goodsRecord:self.goodsRecord property:finalProperty];
    }
    
    [self updateTotalAmount];
    
    return;
}

- (void)handleDecreaseProductCount:(id)sender
{
    BOOL hasSelectAll = YES;
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        if (nil == selectSKUArray || selectSKUArray.count == 0) {
            hasSelectAll = NO;
            break;
        }
    }
    
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *selectProperty = itemView.selectedPropertyData;
        if (nil == selectProperty || [selectProperty isEmptyString]) {
            hasSelectAll = NO;
            break;
        }
    }
    
    
    if (NO == hasSelectAll) {
        return;
    }
    
    NSMutableArray *finalSelectedSKUArray = [[[NSMutableArray alloc] init] autorelease];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        [finalSelectedSKUArray addObject:selectSKUArray];
    }
    
    NSMutableString *finalProperty = [NSMutableString stringWithString:@""];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *property = itemView.selectedPropertyData;
        if ([self.propertySelectSKUViewArray indexOfObject:itemView] == 0) {
            [finalProperty appendString:property];
        } else {
            [finalProperty appendString:[NSString stringWithFormat:@",%@", property]];
        }
    }
    
    NSInteger totalCount = countLabel.text.integerValue;
    totalCount -= 1;
    if (totalCount <= 0) {
        totalCount = 0;
    }
    
    countLabel.text = [NSString stringWithFormat:@"%d", (int)totalCount];
    
    if ([self.delegate respondsToSelector:@selector(handleRestaurantDecreaseSKUDishCount:goodsRecord:property:)]) {
        [self.delegate handleRestaurantDecreaseSKUDishCount:finalSelectedSKUArray goodsRecord:self.goodsRecord property:finalProperty];
    }
    
    [self updateTotalAmount];
    
    return;
}

#pragma mark -
#pragma mark JCHRestaurantAddProductSKUSelectViewDelegate
- (void)clickSKUItemButton:(id)sender
{
    BOOL hasSelectAll = YES;
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        if (nil == selectSKUArray || selectSKUArray.count == 0) {
            hasSelectAll = NO;
            break;
        }
    }
    
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *selectProperty = itemView.selectedPropertyData;
        if (nil == selectProperty || [selectProperty isEmptyString]) {
            hasSelectAll = NO;
            break;
        }
    }
    
    if (NO == hasSelectAll) {
        return;
    }
    
    [self updateTotalAmount];
}

- (void)viewEndEditing:(JCHRestaurantAddProductSKUSelectView *)view
{
    
}

- (void)handleClose:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleCloseView)]) {
        [self.delegate handleCloseView];
    }
}

- (void)updateTotalAmount
{
    NSMutableArray *finalSelectedSKUArray = [[[NSMutableArray alloc] init] autorelease];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.skuSelectViewArray) {
        NSArray *selectSKUArray = itemView.selectedSKUData;
        [finalSelectedSKUArray addObject:selectSKUArray];
    }
    
    NSMutableString *finalProperty = [NSMutableString stringWithString:@""];
    for (JCHRestaurantAddProductSKUSelectView *itemView in self.propertySelectSKUViewArray) {
        NSString *property = itemView.selectedPropertyData;
        if ([self.propertySelectSKUViewArray indexOfObject:itemView] == 0) {
            [finalProperty appendString:property];
        } else {
            [finalProperty appendString:[NSString stringWithFormat:@",%@", property]];
        }
    }
    
    NSInteger dishCount = 0;
    if ([self.delegate respondsToSelector:@selector(getRestaurantSKUDishCount:goodsRecord:property:)]) {
        dishCount = [self.delegate getRestaurantSKUDishCount:finalSelectedSKUArray goodsRecord:self.goodsRecord property:finalProperty];
    }
    
    CGFloat dishPrice = 0;
    if ([self.delegate respondsToSelector:@selector(getRestaurantSKUDishPrice:goodsRecord:property:)]) {
        dishPrice = [self.delegate getRestaurantSKUDishPrice:finalSelectedSKUArray goodsRecord:self.goodsRecord property:finalProperty];
    }
    
    CGFloat totalAmount = dishCount * dishPrice;
    if (totalAmount < 0) {
        totalAmount = 0;
    }
    
    countLabel.text = [NSString stringWithFormat:@"%d", (int)dishCount];
    amountLabel.text = [NSString stringWithFormat:@"%.2f", totalAmount];
}

@end
