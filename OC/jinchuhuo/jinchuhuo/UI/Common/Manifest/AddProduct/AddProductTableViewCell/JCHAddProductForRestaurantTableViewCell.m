//
//  JCHAddProductForRestaurantTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2017/2/21.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHAddProductForRestaurantTableViewCell.h"
#import "JCHAddProductMainAuxiliaryUnitSelectView.h"
#import "JCHAddProductSKUSelectView.h"
#import "CommonHeader.h"

@interface JCHAddProductForRestaurantTableViewCell ()
{
    UIImageView *productLogoImageView;
    UILabel *productNameLabel;
    UILabel *priceReferenceLabel;
    UILabel *productPriceLabel;
    UILabel *productInventoryCountLabel;
    UILabel *productCountLabel;
    UIView *middleLine;
    
    UIButton *minusButton;
    CGFloat skuSelectContainerViewHeight;
    CGFloat mainAuxiliaryUnitSelectViewHeight;
    
    
    UIView *mainAuxiliaryUnitContainerView;
}

@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) GoodsSKURecord4Cocoa *goodsSKURecord;
@property (retain, nonatomic, readwrite) NSArray *auxiliaryUnitList;
@property (retain, nonatomic, readwrite) NSString *productUnit;
@property (retain, nonatomic, readwrite) UIButton *addButton;
@end

@implementation JCHAddProductForRestaurantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        skuSelectContainerViewHeight = 0;
        mainAuxiliaryUnitSelectViewHeight = 0;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [self.productCategory release];
    [self.productName release];
    [self.addButton release];
    [self.goodsSKURecord release];
    [self.auxiliaryUnitList release];
    [self.productUnit release];
    [super dealloc];
    return;
}

- (void)createUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    productLogoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    productLogoImageView.layer.cornerRadius = 3.0f;
    productLogoImageView.clipsToBounds = YES;
    productLogoImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:productLogoImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [productLogoImageView addGestureRecognizer:tap];
    
    productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(13.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    productNameLabel.numberOfLines = 1;
    [self.contentView addSubview:productNameLabel];
    
    
    priceReferenceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"参考"
                                               font:JCHFont(10.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    priceReferenceLabel.layer.borderColor = JCHColorMainBody.CGColor;
    priceReferenceLabel.layer.borderWidth = kSeparateLineWidth;
    priceReferenceLabel.layer.cornerRadius = 4;
    priceReferenceLabel.clipsToBounds = YES;
    priceReferenceLabel.hidden = YES;
    [self.contentView addSubview:priceReferenceLabel];
    
    
    productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:JCHFont(12.0)
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:productPriceLabel];
    
    

    productInventoryCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@""
                                                      font:JCHFont(12.0)
                                                 textColor:JCHColorHeaderBackground
                                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:productInventoryCountLabel];
    
    middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:middleLine];
    
    productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"0"
                                             font:JCHFont(14.0)
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:productCountLabel];
    
    self.addButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handlePullDown:)
                                               title:nil
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:nil];
    self.addButton.titleLabel.font = JCHFont(12);
    
    
    [self.addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateSelected];
    
    
    [self.contentView addSubview:self.addButton];
    
    [self.addButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    

    
    minusButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleDecreaseDishCount:)
                                       title:nil
                                  titleColor:nil
                             backgroundColor:nil];
    [minusButton setImage:[UIImage imageNamed:@"addgoods_btn_minus"] forState:UIControlStateNormal];
    [minusButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self.contentView addSubview:minusButton];
    minusButton.hidden = YES;
    

    mainAuxiliaryUnitContainerView = [[[UIView alloc] init] autorelease];
    mainAuxiliaryUnitContainerView.backgroundColor = [UIColor whiteColor];
    mainAuxiliaryUnitContainerView.hidden = YES;
    [self.contentView addSubview:mainAuxiliaryUnitContainerView];
    
    return;
}

- (void)tapAction
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        // pass
    } else {
        if (self.tapBlock) {
            self.tapBlock(self);
        }
    }
}


- (void)handlePullDown:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleRestaurantAddSKUDish:)]) {
        [self.delegate handleRestaurantAddSKUDish:self];
    }
}

- (void)handleShowKeyboard:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleRestaurantIncreaseDishCount:unitUUID:)]) {
        [self.delegate handleRestaurantIncreaseDishCount:self unitUUID:nil];
    }
}

- (void)handleDecreaseDishCount:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleRestaurantDecreaseDishCount:unitUUID:)]) {
        [self.delegate handleRestaurantDecreaseDishCount:self unitUUID:nil];
    }
}

- (void)setCellData:(JCHAddProductTableViewCellData *)cellData
{
    if (self.addProductListStyle == 0) {
        self.normalCellHeight = kJCHAddProductTableViewCellNormalHeight;
    } else {
        self.normalCellHeight = kJCHAddproductTableViewCellLeftMenuCellHeight;
    }
    
    [self removeMainAuxiliaryUnitSelectViews];
    
    
    [self createSKUAndMainAuxiliaryUnitSelectedViews:cellData];
    
    
    productLogoImageView.image = [UIImage jchProductImageNamed:cellData.productLogoImage];
    productNameLabel.text = cellData.productName;
    
    self.productCategory = cellData.productCategory;
    self.productName = cellData.productName;
    
    NSUInteger length = [cellData.productName length];
    
    if (length < 17) {
        productNameLabel.font = [UIFont systemFontOfSize:15.0f];
    } else {
        productNameLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    if ([cellData.productPrice isEqualToString:@"无参考价"]) {
        productPriceLabel.text = @"";
        productPriceLabel.hidden = YES;
        priceReferenceLabel.hidden = YES;
    } else {
        productPriceLabel.text = [NSString stringWithFormat:@"¥%@",  cellData.productPrice];
        priceReferenceLabel.hidden = NO;
    }
    

    productCountLabel.text = cellData.productCount;
    for (JCHAddProductMainAuxiliaryUnitSelectViewData *data in self.auxiliaryUnitList)
    {
        data.productCount = cellData.productCount;
    }
    
    NSArray *property = [cellData.productProperty jsonStringToArrayOrDictionary];
    
    [self convertAddButton:(cellData.sku_hidden_flag && property.count == 0)];
    
    
    if (!cellData.sku_hidden_flag) {
        minusButton.hidden = YES;
    } else {
        if (cellData.productCount.integerValue > 0) {
            minusButton.hidden = NO;
        } else {
            minusButton.hidden = YES;
        }
    }
    
    
    
    if (cellData.productCount.integerValue > 0) {
        productCountLabel.hidden = NO;
    } else {
        productCountLabel.hidden = YES;
    }
    
    
    productInventoryCountLabel.text = [NSString stringWithFormat:@"1%@", cellData.productUnit];
    productInventoryCountLabel.textColor = JCHColorAuxiliary;
}

- (void)convertAddButton:(BOOL)addButton
{
    if (addButton) {
        [self.addButton removeTarget:self action:@selector(handlePullDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton addTarget:self action:@selector(handleShowKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateSelected];
        [self.addButton setTitle:@"" forState:UIControlStateNormal];
        self.addButton.backgroundColor = [UIColor whiteColor];
    } else {
        [self.addButton removeTarget:self action:@selector(handleShowKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton addTarget:self action:@selector(handlePullDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton setImage:nil forState:UIControlStateNormal];
        [self.addButton setImage:nil forState:UIControlStateSelected];
        [self.addButton setTitle:@"选规格" forState:UIControlStateNormal];
        self.addButton.backgroundColor = JCHColorHeaderBackground;
    }
}

- (void)createSKUAndMainAuxiliaryUnitSelectedViews:(JCHAddProductTableViewCellData *)cellData
{
    if (cellData.is_multi_unit_enable) {
        self.addButton.hidden = YES;
        minusButton.hidden = YES;
        productCountLabel.hidden = YES;
        mainAuxiliaryUnitContainerView.hidden = NO;
        productInventoryCountLabel.hidden = YES;
        productPriceLabel.hidden = YES;
        
        self.auxiliaryUnitList = cellData.auxiliaryUnitList;
        self.productUnit = cellData.productUnit;
        [self createMainAuxiliaryUnitSelectView];
    } else {
        self.addButton.hidden = NO;
        mainAuxiliaryUnitContainerView.hidden = YES;
        productInventoryCountLabel.hidden = NO;
        productPriceLabel.hidden = NO;
        
        if (cellData.sku_hidden_flag == YES) {
            minusButton.hidden = YES;
            productCountLabel.hidden = NO;
        } else {
            minusButton.hidden = YES;
            productCountLabel.hidden = NO;
        }

        
        self.auxiliaryUnitList = nil;
        self.goodsSKURecord = cellData.goodsSKURecord;
    }
}



- (void)createMainAuxiliaryUnitSelectView
{
    mainAuxiliaryUnitSelectViewHeight = 0;
    CGFloat viewHeight;
    
    if (self.addProductListStyle == 0) {
        viewHeight = 35;
    } else {
        viewHeight = 45;
    }
    CGFloat bottomHeight = 5;
    
    JCHAddProductMainAuxiliaryUnitSelectView *lastView = nil;
    for (NSInteger i = 0; i < self.auxiliaryUnitList.count; i++) {
        JCHAddProductMainAuxiliaryUnitSelectView *view = [[[JCHAddProductMainAuxiliaryUnitSelectView alloc] initWithFrame:CGRectZero] autorelease];
        WeakSelf;
        
        [mainAuxiliaryUnitContainerView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView ? lastView.mas_bottom : mainAuxiliaryUnitContainerView.mas_top);
            make.left.right.equalTo(mainAuxiliaryUnitContainerView);
            make.height.mas_equalTo(viewHeight);
        }];
        
        lastView = view;
        
        JCHAddProductMainAuxiliaryUnitSelectViewData *data = self.auxiliaryUnitList[i];
        [view setViewData:data];
        
        [view setAddProductBlock:^{
            if ([weakSelf.delegate respondsToSelector:@selector(handleShowKeyboard:unitUUID:)]) {
                [weakSelf.delegate handleRestaurantIncreaseDishCount:weakSelf unitUUID:data.unitUUID];
            }
        }];
        

        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        if (manifestStorage.currentManifestType == kJCHOrderShipment) {
            view.increaseProductCountBlock = ^(NSString *unitUUID) {
                [self.delegate handleRestaurantMainUnitIncreaseDishCount:weakSelf unitUUID:unitUUID];
            };
            
            view.decreaseProductCountBlock = ^(NSString *unitUUID) {
                [self.delegate handleRestaurantMainUnitDecreaseDishCount:weakSelf unitUUID:unitUUID];
            };
        }
        mainAuxiliaryUnitSelectViewHeight += viewHeight;
    }
    
    [mainAuxiliaryUnitContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
    }];
    
    self.pullDownCellHeight = self.normalCellHeight + mainAuxiliaryUnitSelectViewHeight - viewHeight + bottomHeight;
}

- (void)removeMainAuxiliaryUnitSelectViews
{
    for (UIView *subView in mainAuxiliaryUnitContainerView.subviews) {
        if ([subView isKindOfClass:[JCHAddProductMainAuxiliaryUnitSelectView class]]) {
            [subView removeFromSuperview];
        }
    }
    mainAuxiliaryUnitSelectViewHeight = 0;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.addProductListStyle == 0) {
        [self layoutDefaultUI];
    } else {
        [self layoutLeftMenuUI];
    }
}


- (void)layoutDefaultUI
{
    [self layoutShipmentDefaultUI];
}

- (void)layoutShipmentDefaultUI
{
    const CGFloat imageViewWidth = 50;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 22.0f;
    const CGFloat productCountLabelHeight = imageViewWidth - productNameLabelHeight;

    
    CGFloat pullDownButtonWidth = 25.0f;
    CGFloat pullDownButtonHeight = pullDownButtonWidth;
    CGFloat inventoryCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:90];
    
    if (self.addButton.currentTitle && ![self.addButton.currentTitle isEmptyString]) {
        CGSize fitSize = [self.addButton.titleLabel sizeThatFits:CGSizeZero];
        pullDownButtonWidth = fitSize.width + 10;
        pullDownButtonHeight = fitSize.height + 10;
    }
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageViewWidth);
        make.height.mas_equalTo(imageViewHeight);
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(8);
    }];
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-currentkStandardLeftMargin * 2 - pullDownButtonWidth);
        make.top.equalTo(productLogoImageView.mas_top).with.offset(currentkStandardLeftMargin / 4);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    
    
    [productInventoryCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_left);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.width.mas_equalTo(inventoryCountLabelWidth);
        make.height.mas_equalTo(productCountLabelHeight);
    }];
    
    productInventoryCountLabel.hidden = YES;
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_left);
        make.top.equalTo(productInventoryCountLabel);
        make.right.equalTo(productNameLabel);
        make.height.mas_equalTo(productCountLabelHeight);
    }];
    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.addButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.addButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonHeight);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addButton.mas_left);
        make.centerY.equalTo(self.addButton.mas_centerY);
        make.height.mas_equalTo(32.0);
        make.width.mas_equalTo(48.0);
    }];
    
    [minusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(self.addButton);
        make.right.equalTo(productCountLabel.mas_left);
    }];
}

- (void)layoutLeftMenuUI
{
    [self layoutShipmentLeftMenuUI];
}

- (void)layoutShipmentLeftMenuUI
{
    const CGFloat imageViewWidth = 64;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 28.0f;
    const CGFloat inventoryLabelHeight = 16.0f;
    CGFloat pullDownButtonWidth = 25.0f;
    CGFloat pullDownButtonHeight = pullDownButtonWidth;
    
    if (self.addButton.currentTitle && ![self.addButton.currentTitle isEmptyString]) {
        CGSize fitSize = [self.addButton.titleLabel sizeThatFits:CGSizeZero];
        pullDownButtonWidth = fitSize.width + 10;
        pullDownButtonHeight = fitSize.height + 10;
    }
    
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageViewWidth);
        make.height.mas_equalTo(imageViewHeight);
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(8);
    }];
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-currentkStandardLeftMargin * 2 - pullDownButtonWidth);
        make.top.equalTo(productLogoImageView.mas_top);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    [productInventoryCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_left);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.width.equalTo(productNameLabel);
        make.height.mas_equalTo(inventoryLabelHeight);
    }];
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productInventoryCountLabel);
        make.top.equalTo(productInventoryCountLabel.mas_bottom).offset(5);
        make.right.equalTo(productNameLabel);
        make.height.mas_equalTo(inventoryLabelHeight);
    }];
    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.addButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.addButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonHeight);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];


    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
    

    CGFloat buttonLabelOffset = 0;
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addButton.mas_left).with.offset(-buttonLabelOffset);
        make.centerY.equalTo(self.addButton.mas_centerY);
        make.height.mas_equalTo(32.0);
        make.width.mas_equalTo(48.0);
    }];
    
    [minusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(self.addButton);
        make.right.equalTo(productCountLabel.mas_left).with.offset(-buttonLabelOffset);
    }];
}



@end
