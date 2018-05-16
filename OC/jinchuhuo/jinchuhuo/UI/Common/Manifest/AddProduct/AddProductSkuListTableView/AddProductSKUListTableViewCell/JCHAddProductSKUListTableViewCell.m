//
//  JCHAddProductSKUListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductSKUListTableViewCell.h"
#import "JCHAddProductSKUListView.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHTransactionUtility.h"
#import "NSString+JCHString.h"
#import "JCHBottomArrowButton.h"
#import "CommonHeader.h"
#import "Masonry.h"

@implementation JCHAddProductSKUListTableViewCellData

- (void)dealloc
{
    [self.skuTypeName release];
    [self.productPrice release];
    [self.productCount release];
    [self.productName release];
    [self.totalAmount release];
    [self.inventoryCount release];
    [self.productUnit release];
    
    [super dealloc];
}

@end

@interface JCHAddProductSKUListTableViewCell ()
{
    UILabel *_skuNameLabel;

    JCHBottomArrowButton *_productCountButton;
    JCHBottomArrowButton *_productPriceButton;
    JCHBottomArrowButton *_productTotalAmountButton;
    CGFloat _selectButtonWidth;
    enum JCHOrderType _currentManifestType;
    
    // 拆装单专用
    UIView *_mainAuxiliaryInfoContainerView;
    UIView *_auxiliaryButtonContainerView;
    UILabel *_inventoryLabel;
}
@property (nonatomic, retain) NSMutableArray *auxiliaryButtons;
@end

@implementation JCHAddProductSKUListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _currentManifestType = manifestType;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.selectButton = nil;
    self.auxiliaryButtons = nil;
    
    [super dealloc];
}


- (void)createUI
{
    if (_currentManifestType == kJCHManifestDismounting || _currentManifestType == kJCHManifestAssembling) {
        self.auxiliaryButtons = [NSMutableArray array];
    } else {
        UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
        UIFont *countLabelFont = [UIFont jchSystemFontOfSize:13.0f];
        self.selectButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(handleSelect:)
                                                 title:nil
                                            titleColor:nil
                                       backgroundColor:nil];
        [self.selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectButton];
        
        _skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:titleFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
        _skuNameLabel.numberOfLines = 0;
        _skuNameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_skuNameLabel];
        
        
        
        
        _productCountButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
        _productCountButton.tag = kJCHAddProductSKUListTableViewCellCountLableTag;
        _productCountButton.titleLabel.font = countLabelFont;
        _productCountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_productCountButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_productCountButton];
        
        
        _productPriceButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
        _productPriceButton.tag = kJCHAddProductSKUListTableViewCellPriceLableTag;
        _productPriceButton.titleLabel.font = countLabelFont;
        _productPriceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _productPriceButton.detailLabelHidden = YES;
        [_productPriceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_productPriceButton];
        
        _productTotalAmountButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
        _productTotalAmountButton.tag = kJCHAddProductSKUListTableViewCellTotalAmountLableTag;
        _productTotalAmountButton.titleLabel.font = countLabelFont;
        _productTotalAmountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _productTotalAmountButton.detailLabelHidden = YES;
        [_productTotalAmountButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_productTotalAmountButton];
        
        
        //进货单、出货单、移库单 需要库存信息
        if (_currentManifestType == kJCHOrderShipment || _currentManifestType == kJCHOrderPurchases || _currentManifestType == kJCHManifestMigrate) {
            _productCountButton.detailLabelHidden = NO;
            
            if (_currentManifestType == kJCHManifestMigrate) {
                _skuNameLabel.textAlignment = NSTextAlignmentCenter;
            }
        } else {
            _productCountButton.detailLabelHidden = YES;
        }
        
#if MMR_TAKEOUT_VERSION
        _productCountButton.detailLabelHidden = YES;
#endif
    }
}



- (void)handleSelect:(UIButton *)sender
{
    if ([self.cellDelegate respondsToSelector:@selector(handleSelectCell:button:)]) {
        sender.selected = !sender.selected;
        [self.cellDelegate handleSelectCell:self button:self.selectButton];
        
        //if (!sender.selected) {
            _productPriceButton.selected = NO;
            _productCountButton.selected = NO;
        //}
    }
}

- (void)buttonClick:(JCHBottomArrowButton *)sender
{
    BOOL selected = sender.selected;
    [self deselectAllButton];
    
    if ([self.cellDelegate respondsToSelector:@selector(handleLabelTaped:editLabel:)]) {
        
        if (_currentManifestType == kJCHManifestAssembling || _currentManifestType == kJCHManifestDismounting) {
            self.tag = sender.tag;
            [self.cellDelegate handleLabelTaped:self editLabel:sender.titleLabel];
            sender.selected = YES;
        } else {
            sender.selected = !selected;
            if (sender.tag == kJCHAddProductSKUListTableViewCellCountLableTag) {
                [self.cellDelegate handleLabelTaped:self editLabel:_productCountButton.titleLabel];
            } else if (sender.tag == kJCHAddProductSKUListTableViewCellPriceLableTag) {
                [self.cellDelegate handleLabelTaped:self editLabel:_productPriceButton.titleLabel];
            } else if (sender.tag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag) {
                [self.cellDelegate handleLabelTaped:self editLabel:_productTotalAmountButton.titleLabel];
            }
        }
    }
}

//设置默认焦点
- (void)setDefaultFocus
{
    if (_currentManifestType == kJCHOrderShipment || _currentManifestType == kJCHOrderPurchases || _currentManifestType == kJCHManifestMigrate || _currentManifestType == kJCHRestaurntManifestOpenTable) {
        [self buttonClick:_productCountButton];
    } else if (_currentManifestType == kJCHManifestInventory) {
        [self buttonClick:_productPriceButton];
    } else if (_currentManifestType == kJCHManifestMaterialWastage) {
        [self buttonClick:_productCountButton];
    } else if (_currentManifestType == kJCHManifestAssembling || _currentManifestType == kJCHManifestDismounting) {
        JCHBottomArrowButton *auxiliaryButton = [self.auxiliaryButtons firstObject];
        [self buttonClick:auxiliaryButton];
    }
}

- (void)setData:(JCHAddProductSKUListTableViewCellData *)data
{
    if (_currentManifestType == kJCHOrderShipment || _currentManifestType == kJCHOrderPurchases || _currentManifestType == kJCHRestaurntManifestOpenTable) {
        if (data.sku_hidden_flag) {
            self.selectButton.hidden = YES;
            _selectButtonWidth = kStandardLeftMargin;
            _skuNameLabel.text = data.productName;
        } else {
            self.selectButton.hidden = NO;
            _selectButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:51.0f];
            _skuNameLabel.text = data.skuTypeName ? data.skuTypeName : @"无规格";
        }
        _productCountButton.detailLabel.text = [NSString stringWithFormat:@"库存 %@", data.inventoryCount];
        
        NSString *productCount = nil;
        if (data.productCount.doubleValue == 0) {
            productCount = [NSString stringFromCount:[data.productCount doubleValue] unitDigital:data.productUnit_digits];
        } else {
            productCount = data.productCount;
        }
        _productCountButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", productCount, data.productUnit];
        _productPriceButton.titleLabel.text = data.productPrice;
        self.selectButton.selected = data.buttonSelected;
        
        //NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[data.discount doubleValue]];
        _productTotalAmountButton.titleLabel.text = data.totalAmount;
        
        _productTotalAmountButton.enabled = !data.disabledTotalAmoutButton;
        
    } else if (_currentManifestType == kJCHManifestInventory) {
        self.selectButton.hidden = YES;
        _selectButtonWidth = kStandardLeftMargin;
        
        if (data.sku_hidden_flag) {
            //_skuNameLabel.text = data.productName ? data.productName : @"无规格";
            if (data.skuTypeName == nil) {
                _skuNameLabel.text = @"无规格";
            } else if (![data.skuTypeName isEmptyString]) {
                _skuNameLabel.text = data.skuTypeName;
            } else {
                _skuNameLabel.text = data.productName ? data.productName : @"无规格";
            }
        } else {
            _skuNameLabel.text = data.skuTypeName ? data.skuTypeName : @"无规格";
        }
        
        _productTotalAmountButton.enabled = !data.disabledPriceButton;
        _productCountButton.enabled = NO;
        
        _productCountButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", data.inventoryCount, data.productUnit];
        _productPriceButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, data.productUnit];
        _productTotalAmountButton.titleLabel.text = data.productPrice;
    } else if (_currentManifestType == kJCHManifestMaterialWastage) {
        self.selectButton.hidden = YES;
        _selectButtonWidth = kStandardLeftMargin;
        
        if (data.sku_hidden_flag) {
            //_skuNameLabel.text = data.productName ? data.productName : @"无规格";
            if (data.skuTypeName == nil) {
                _skuNameLabel.text = @"无规格";
            } else if (![data.skuTypeName isEmptyString]) {
                _skuNameLabel.text = data.skuTypeName;
            } else {
                _skuNameLabel.text = data.productName ? data.productName : @"无规格";
            }
        } else {
            _skuNameLabel.text = data.skuTypeName ? data.skuTypeName : @"无规格";
        }
        
        _productTotalAmountButton.enabled = NO;
        _productCountButton.enabled = YES;
        _productPriceButton.enabled = YES;
        
        _productCountButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, data.productUnit];
        _productPriceButton.titleLabel.text = data.productPrice;
        _productTotalAmountButton.titleLabel.text = [NSString stringWithFormat:@"%.2f", data.productPrice.doubleValue * data.productCount.doubleValue];
    } else if (_currentManifestType == kJCHManifestMigrate) {
        self.selectButton.hidden = YES;
        _selectButtonWidth = kStandardLeftMargin;
        
        if (data.sku_hidden_flag) {
            _skuNameLabel.text = data.productName;
        } else {
            _skuNameLabel.text = data.skuTypeName ? data.skuTypeName : @"无规格";
        }
        NSString *productCount = nil;
        if (data.productCount.doubleValue == 0) {
            productCount = [NSString stringFromCount:[data.productCount doubleValue] unitDigital:data.productUnit_digits];
        } else {
            productCount = data.productCount;
        }
        _productCountButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", productCount, data.productUnit];
        _productCountButton.detailLabel.text = [NSString stringWithFormat:@"库存 %@", data.inventoryCount];
    }
}

- (void)setAssemblingAndDismoutingData:(NSArray *)cellData
{
    if (_currentManifestType == kJCHManifestAssembling) {
        // 拼装单
        
        if (_mainAuxiliaryInfoContainerView == nil) {
            
            _mainAuxiliaryInfoContainerView = [[[UIView alloc] init] autorelease];
            [self.contentView addSubview:_mainAuxiliaryInfoContainerView];
            
            _auxiliaryButtonContainerView = [[[UIView alloc] init] autorelease];
            [self.contentView addSubview:_auxiliaryButtonContainerView];
            
            [_auxiliaryButtonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_centerX);
                make.top.height.right.equalTo(self.contentView);
            }];
            
            CGFloat inventoryLabelHeight = 20;
            CGFloat inventoryLabelWidth = kScreenWidth / 2 - kStandardLeftMargin;
            CGFloat ratioInfoLabelHeight = 14;
            CGFloat containerViewHeight = 0;
            JCHAddProductSKUListTableViewCellData *mainUnitData = nil;
            
            UILabel *mainUnitInventoryLabel = [JCHUIFactory createLabel:CGRectZero
                                                                  title:@""
                                                                   font:JCHFont(14.0)
                                                              textColor:JCHColorMainBody
                                                                 aligin:NSTextAlignmentCenter];
            [_mainAuxiliaryInfoContainerView addSubview:mainUnitInventoryLabel];
            
            mainUnitInventoryLabel.frame = CGRectMake(kStandardLeftMargin / 2, 0, inventoryLabelWidth, inventoryLabelHeight);
            containerViewHeight += inventoryLabelHeight;
            
            for (JCHAddProductSKUListTableViewCellData *data in cellData) {
                if (data.isMainUnit) {
                    mainUnitInventoryLabel.text = [NSString stringWithFormat:@"%@%@", data.inventoryCount, data.productUnit];
                    mainUnitData = data;
                    break;
                }
            }
            
            CGFloat auxiliaryButtonY = 0;
            for (NSInteger i = 0; i < cellData.count; i++) {
                JCHAddProductSKUListTableViewCellData *data = cellData[i];
                if (!data.isMainUnit) {
                    UILabel *mainAuxiliaryRatioInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                                                               title:@""
                                                                                font:JCHFont(10.0)
                                                                           textColor:JCHColorAuxiliary
                                                                              aligin:NSTextAlignmentCenter];
                    [_mainAuxiliaryInfoContainerView addSubview:mainAuxiliaryRatioInfoLabel];
                    
                    mainAuxiliaryRatioInfoLabel.frame = CGRectMake(kStandardLeftMargin / 2, containerViewHeight, inventoryLabelWidth, ratioInfoLabelHeight);
                    containerViewHeight += ratioInfoLabelHeight;
                    
                    NSString *perAuxiliaryUnit = [NSString stringFromCount:1 unitDigital:data.productUnit_digits];
                    NSString *auxiliaryRatio = [NSString stringFromCount:data.unitRatio unitDigital:data.productUnit_digits];
                    CGFloat assemblingCountOfAuxiliary = floor(mainUnitData.inventoryCount.doubleValue / data.unitRatio);
                    NSString *assemblingCountOfAuxiliaryString = [NSString stringFromCount:assemblingCountOfAuxiliary unitDigital:data.productUnit_digits];
                    mainAuxiliaryRatioInfoLabel.text = [NSString stringWithFormat:@"%@%@ = %@%@(可拼%@%@)", perAuxiliaryUnit, data.productUnit, auxiliaryRatio, mainUnitData.productUnit, assemblingCountOfAuxiliaryString, data.productUnit];
                    
                    
                    JCHBottomArrowButton *auxiliaryButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectZero] autorelease];
                    auxiliaryButton.tag = i;
                    auxiliaryButton.titleLabel.font = JCHFont(13);
                    auxiliaryButton.titleLabel.tag = kJCHAddProductSKUListTableViewCellCountLableTag;
                    auxiliaryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    [auxiliaryButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [_auxiliaryButtonContainerView addSubview:auxiliaryButton];
                    [auxiliaryButton addSeparateLineWithFrameTop:YES bottom:YES];
                    auxiliaryButton.frame = CGRectMake(0, auxiliaryButtonY, kScreenWidth / 2, kSKUListRowHeight);
                    auxiliaryButtonY += kSKUListRowHeight;
                    auxiliaryButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, data.productUnit];
                    CGFloat assemblingCountOfMain = data.productCount.doubleValue * data.unitRatio;
                    NSString *assemblingCountOfMainString = [NSString stringFromCount:assemblingCountOfMain unitDigital:data.productUnit_digits];
                    auxiliaryButton.detailLabel.text = [NSString stringWithFormat:@"%@%@", assemblingCountOfMainString, mainUnitData.productUnit];
                    
                    [self.auxiliaryButtons addObject:auxiliaryButton];
                }
            }
            [_auxiliaryButtonContainerView addSeparateLineWithMasonryLeft:YES right:NO];
            
            [_mainAuxiliaryInfoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_centerX);
                make.height.mas_equalTo(containerViewHeight);
                make.centerY.equalTo(self.contentView);
            }];
        } else {
            
            JCHAddProductSKUListTableViewCellData *mainUnitData = nil;
            for (JCHAddProductSKUListTableViewCellData *data in cellData) {
                if (data.isMainUnit) {
                    mainUnitData = data;
                    break;
                }
            }
            
            for (JCHBottomArrowButton *auxiliaryButton in self.auxiliaryButtons) {
                JCHAddProductSKUListTableViewCellData *data = cellData[auxiliaryButton.tag];
                
                auxiliaryButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, data.productUnit];
                CGFloat assemblingCountOfMain = data.productCount.doubleValue * data.unitRatio;
                NSString *assemblingCountOfMainString = [NSString stringFromCount:assemblingCountOfMain unitDigital:data.productUnit_digits];
                auxiliaryButton.detailLabel.text = [NSString stringWithFormat:@"%@%@", assemblingCountOfMainString, mainUnitData.productUnit];
            }
        }
    } else if (_currentManifestType == kJCHManifestDismounting) {
        if (_mainAuxiliaryInfoContainerView == nil) {
            _mainAuxiliaryInfoContainerView = [[[UIView alloc] init] autorelease];
            [self.contentView addSubview:_mainAuxiliaryInfoContainerView];
           
            JCHBottomArrowButton *leftButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 2, kSKUListRowHeight)] autorelease];
            leftButton.titleLabel.font = JCHFont(13);
            leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            leftButton.enabled = NO;
            [_mainAuxiliaryInfoContainerView addSubview:leftButton];
            
            JCHBottomArrowButton *rightButton = [[[JCHBottomArrowButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2, kSKUListRowHeight)] autorelease];
            rightButton.titleLabel.font = JCHFont(13);
            rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            rightButton.tag = 1;
            [rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton addSeparateLineWithMasonryLeft:YES right:NO];
            [_mainAuxiliaryInfoContainerView addSubview:rightButton];
            
            [self.auxiliaryButtons addObject:rightButton];

            JCHAddProductSKUListTableViewCellData *mainUnitData = nil;
            JCHAddProductSKUListTableViewCellData *auxiliaryData = nil;
            for (NSInteger i = 0; i < cellData.count; i++) {
                JCHAddProductSKUListTableViewCellData *data = cellData[i];
                
                if (data.isMainUnit) {
                    mainUnitData = data;
                } else {
                    auxiliaryData = data;
                    rightButton.titleLabel.tag = kJCHAddProductSKUListTableViewCellCountLableTag;
                }
            }
            
            leftButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", auxiliaryData.inventoryCount, auxiliaryData.productUnit];
            
            NSString *perAuxiliaryUnit = [NSString stringFromCount:1 unitDigital:auxiliaryData.productUnit_digits];
            NSString *auxiliaryRatio = [NSString stringFromCount:auxiliaryData.unitRatio unitDigital:auxiliaryData.productUnit_digits];
            CGFloat dismoutingCountOfMainUnit = auxiliaryData.inventoryCount.doubleValue * auxiliaryData.unitRatio;
            NSString *dismoutingCountOfMainUnitString = [NSString stringFromCount:dismoutingCountOfMainUnit unitDigital:mainUnitData.productUnit_digits];
            leftButton.detailLabel.text = [NSString stringWithFormat:@"%@%@ = %@%@(可拆%@%@)", perAuxiliaryUnit, auxiliaryData.productUnit, auxiliaryRatio, mainUnitData.productUnit, dismoutingCountOfMainUnitString, mainUnitData.productUnit];
            
            CGFloat rightButtonDetailTextFloat = auxiliaryData.productCount.doubleValue *auxiliaryData.unitRatio;
            NSString *rightButtonDetailText = [NSString stringFromCount:rightButtonDetailTextFloat unitDigital:mainUnitData.productUnit_digits];
            rightButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", auxiliaryData.productCount, auxiliaryData.productUnit];
            rightButton.detailLabel.text = [NSString stringWithFormat:@"%@%@", rightButtonDetailText, mainUnitData.productUnit];
        } else {
            
            JCHBottomArrowButton *rightButton = [self.auxiliaryButtons firstObject];
            
            JCHAddProductSKUListTableViewCellData *mainUnitData = nil;
            JCHAddProductSKUListTableViewCellData *auxiliaryData = nil;

            for (NSInteger i = 0; i < cellData.count; i++) {
                JCHAddProductSKUListTableViewCellData *data = cellData[i];
                
                if (data.isMainUnit) {
                    mainUnitData = data;
                } else {
                    auxiliaryData = data;
                }
            }
            CGFloat rightButtonDetailTextFloat = auxiliaryData.productCount.doubleValue *auxiliaryData.unitRatio;
            NSString *rightButtonDetailText = [NSString stringFromCount:rightButtonDetailTextFloat unitDigital:mainUnitData.productUnit_digits];
            rightButton.titleLabel.text = [NSString stringWithFormat:@"%@%@", auxiliaryData.productCount, auxiliaryData.productUnit];
            rightButton.detailLabel.text = [NSString stringWithFormat:@"%@%@", rightButtonDetailText, mainUnitData.productUnit];
        }
    }
}


- (void)setLabelSelected:(JCHAddProductSKUListTableViewCellLableTag)labelTag
{
    if (labelTag == kJCHAddProductSKUListTableViewCellCountLableTag) {
        [self deselectAllButton];
        _productCountButton.selected = YES;
    }
    else if (labelTag == kJCHAddProductSKUListTableViewCellPriceLableTag)
    {
        [self deselectAllButton];
        _productPriceButton.selected = YES;
    }
    else if (labelTag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag)
    {
        [self deselectAllButton];
        _productTotalAmountButton.selected = YES;
    }
    else
    {
        [self deselectAllButton];
    }
}

- (void)deselectAllButton
{
    if (_currentManifestType == kJCHManifestAssembling) {
        for (JCHBottomArrowButton *auxiliaryButton in self.auxiliaryButtons) {
            auxiliaryButton.selected = NO;
        }
    } else {
        _productCountButton.selected = NO;
        _productPriceButton.selected = NO;
        _productTotalAmountButton.selected = NO;
    }
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_currentManifestType == kJCHOrderShipment) {
        [self layoutShipmentSubviews];
    } else if (_currentManifestType == kJCHOrderPurchases) {
        [self layoutPurchaseSubviews];
    } else if (_currentManifestType == kJCHManifestInventory) {
        [self layoutInventorySubviews];
    } else if (_currentManifestType == kJCHManifestMaterialWastage) {
        [self layoutShipmentSubviews];
    } else if (_currentManifestType == kJCHManifestMigrate) {
        [self layoutMigrageSubviews];
    } else if (_currentManifestType == kJCHRestaurntManifestOpenTable) {
        [self layoutShipmentSubviews];
    }
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)layoutShipmentSubviews
{
    CGFloat labelWidth = (kScreenWidth / 2) / 2;
    
    CGFloat selectButtonHeight = 44.0f;
    CGFloat skuNameLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat countLabbelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    CGFloat skuNameLabelHeight = kHeight;
    
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.width.mas_equalTo(_selectButtonWidth);
        make.height.mas_equalTo(selectButtonHeight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_skuNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_selectButtonWidth == kStandardLeftMargin) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(self.selectButton.mas_right);
        }
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-kStandardLeftMargin - skuNameLabelWidthOffset);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(skuNameLabelHeight); // * 2 / 3
    }];
    
    [_productCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_productPriceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productCountButton.mas_right).priorityHigh();
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];

    [_productTotalAmountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productPriceButton.mas_right);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)layoutPurchaseSubviews
{
    CGFloat labelWidth = ((kScreenWidth / 2) + kStandardLeftMargin) / 2;
    
    CGFloat selectButtonHeight = 44.0f;
    CGFloat skuNameLabelHeight = kHeight;

    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.width.mas_equalTo(_selectButtonWidth);
        make.height.mas_equalTo(selectButtonHeight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_skuNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_selectButtonWidth == kStandardLeftMargin) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(self.selectButton.mas_right);
        }
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(skuNameLabelHeight); // * 2 / 3
    }];
    
    [_productCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_productPriceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productCountButton.mas_right).priorityHigh();
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)layoutInventorySubviews
{
    CGFloat labelWidth = (kScreenWidth / 2) / 2;
    
    CGFloat selectButtonHeight = 44.0f;
    CGFloat skuNameLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat countLabbelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    CGFloat skuNameLabelHeight = kHeight;
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.width.mas_equalTo(_selectButtonWidth);
        make.height.mas_equalTo(selectButtonHeight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_skuNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_selectButtonWidth == kStandardLeftMargin) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(self.selectButton.mas_right);
        }
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-kStandardLeftMargin - skuNameLabelWidthOffset);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(skuNameLabelHeight); // * 2 / 3
    }];
    

    [_productCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_productPriceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productCountButton.mas_right).priorityHigh();
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_productTotalAmountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productPriceButton.mas_right);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)layoutMigrageSubviews
{
    CGFloat selectButtonHeight = 44.0f;
    CGFloat skuNameLabelHeight = kHeight;
    
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.width.mas_equalTo(_selectButtonWidth);
        make.height.mas_equalTo(selectButtonHeight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_skuNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_selectButtonWidth == kStandardLeftMargin) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(self.selectButton.mas_right);
        }
        make.right.equalTo(self.contentView.mas_centerX).offset(-kStandardTopMargin);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(skuNameLabelHeight); // * 2 / 3
    }];
    
    [_productCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuNameLabel.mas_right);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    _productPriceButton.hidden = YES;
    _productTotalAmountButton.hidden = YES;
}

@end
