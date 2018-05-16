//
//  JCHAddProductMainAuxiliaryUnitSelectView.m
//  jinchuhuo
//
//  Created by huangxu on 16/9/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddProductMainAuxiliaryUnitSelectView.h"
#import "CommonHeader.h"

@implementation JCHAddProductMainAuxiliaryUnitSelectViewData

- (void)dealloc
{
    self.productMainUnit = nil;
    self.productAuxiliaryUnit = nil;
    self.productInventoryCount = nil;
    self.productPrice = nil;
    self.productCount = nil;
    self.unitUUID = nil;
    [super dealloc];
}
@end

@interface JCHAddProductMainAuxiliaryUnitSelectView ()
@property (retain, nonatomic, readwrite) NSString *currentUnitUUID;
@end

@implementation JCHAddProductMainAuxiliaryUnitSelectView
{
    UILabel *_unitLabel;
    UILabel *_inventoryLabel;
    UILabel *_productCountLabel;
    UILabel *_priceReferenceLabel;
    UILabel *_priceLabel;
    UIButton *_addButton;
    UIButton *_minusButton;
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
    self.currentUnitUUID = nil;
    [super dealloc];
}

- (void)createUI
{
    _unitLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:JCHFont(13.0)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self addSubview:_unitLabel];
    
    _inventoryLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(12.0)
                                      textColor:JCHColorAuxiliary
                                         aligin:NSTextAlignmentLeft];
    [self addSubview:_inventoryLabel];
    
    
    _addButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleShowKeyboard:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [_addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateNormal];
    [_addButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self addSubview:_addButton];
    
    _minusButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleDecreaseMainUnitDishCount:)
                                      title:nil
                                 titleColor:nil
                            backgroundColor:nil];
    [_minusButton setImage:[UIImage imageNamed:@"addgoods_btn_minus"] forState:UIControlStateNormal];
    [_minusButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self addSubview:_minusButton];
    _minusButton.hidden = YES;
    
    _priceReferenceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"参考"
                                               font:JCHFont(10.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    _priceReferenceLabel.layer.borderColor = JCHColorMainBody.CGColor;
    _priceReferenceLabel.layer.borderWidth = kSeparateLineWidth;
    _priceReferenceLabel.layer.cornerRadius = 4;
    _priceReferenceLabel.clipsToBounds = YES;
    [self addSubview:_priceReferenceLabel];
    
    _priceLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:JCHFont(12.0)
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentLeft];
    [self addSubview:_priceLabel];
    
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"0"
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentCenter];
    [self addSubview:_productCountLabel];
   
    [self addTarget:self action:@selector(handleShowKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    switch (manifestStorage.currentManifestType) {
        case kJCHOrderPurchases:
        {
            [self layoutPurchase];
        }
            break;
            
        case kJCHOrderShipment:
        {
            [self layoutShipment];
        }
            break;
            
        case kJCHRestaurntManifestOpenTable:
        {
            [self layoutShipment];
        }
            break;
            
        case kJCHManifestInventory:
        {
            [self layoutInventory];
        }
            break;
            
        case kJCHManifestMigrate:
        {
            [self layoutMigrate];
        }
            break;
            
        case kJCHManifestAssembling:
        {
            [self layoutAssembling];
        }
            break;
            
        case kJCHManifestDismounting:
        {
            [self layoutDismounting];
        }
            break;
            
        case kJCHManifestMaterialWastage:
        {
            [self layoutInventory];
        }
            break;
            
        default:
            break;
    }
}

- (void)handleShowKeyboard:(id)sender
{
#if MMR_RESTAURANT_VERSION
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        [self handleIncreaseMainUnitDishCount:sender];
    } else {
        if (self.addProductBlock) {
            self.addProductBlock();
        }
    }
#else
    if (self.addProductBlock) {
        self.addProductBlock();
    }
#endif
}

- (void)setViewData:(JCHAddProductMainAuxiliaryUnitSelectViewData *)data
{
    self.currentUnitUUID = data.unitUUID;
    NSString *productUnit = nil;;
    if (data.isMainUint) {
        _unitLabel.text = [NSString stringWithFormat:@"1%@", data.productMainUnit];
        _inventoryLabel.text = [NSString stringWithFormat:@"库存%@%@", data.productInventoryCount, data.productMainUnit];
        productUnit = data.productMainUnit;
    } else {
        _unitLabel.text = [NSString stringWithFormat:@"1%@/%g%@", data.productAuxiliaryUnit, data.scale, data.productMainUnit];
        _inventoryLabel.text = [NSString stringWithFormat:@"库存%@%@", data.productInventoryCount, data.productAuxiliaryUnit];
        productUnit = data.productAuxiliaryUnit;
    }
    
    //NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        
        // 移库单显示的是当前移库的数量
        _productCountLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, productUnit];

        if (data.productCount.doubleValue == 0) {
            _productCountLabel.hidden = YES;
        }
    } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        
        if (data.afterManifestInventoryChecked) {
            _inventoryLabel.text = [NSString stringWithFormat:@"盘后%@%@  成本价%@", data.productCount, productUnit, data.productPrice];//盘后*** 成本价
            _inventoryLabel.textColor = JCHColorHeaderBackground;
        }
    } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        
        _priceLabel.text = [NSString stringWithFormat:@"¥%@", data.productPrice];
    } else if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        
        _priceLabel.text = [NSString stringWithFormat:@"¥%@", data.productPrice];
    } else if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
        // 拼装单显示的是拼后库存的数量
        _productCountLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, productUnit];
        
        if (data.productCount.doubleValue == 0) {
            _productCountLabel.hidden = YES;
        }
        
        if (data.productCount.doubleValue == 0) {
            _inventoryLabel.text = [NSString stringWithFormat:@"库存%@%@", data.productInventoryCount, data.productMainUnit];
        } else {
            _inventoryLabel.text = [NSString stringWithFormat:@"拼后库存%@%@", data.productInventoryCount, data.productMainUnit];
        }
    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
        // 拆装单显示的是拆后的库存的数量
        _productCountLabel.text = [NSString stringWithFormat:@"%@%@", data.productCount, productUnit];
        
        if (data.productCount.doubleValue == 0) {
            _productCountLabel.hidden = YES;
        }
        
        if (data.productCount.doubleValue == 0) {
            _inventoryLabel.text = [NSString stringWithFormat:@"库存%@%@", data.productInventoryCount, data.productAuxiliaryUnit];
        } else {
            _inventoryLabel.text = [NSString stringWithFormat:@"拆后库存%@%@", data.productInventoryCount, data.productAuxiliaryUnit];
        }
    } else if (manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        _priceLabel.text = [NSString stringWithFormat:@"¥%@", data.productPrice];
    }
    
    
    CGSize fitSize = [_unitLabel sizeThatFits:CGSizeZero];
    [_unitLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(fitSize.width);
    }];
    
#if MMR_RESTAURANT_VERSION
    if (0 != data.productCount.integerValue) {
        _minusButton.hidden = NO;
    } else {
        _minusButton.hidden = YES;
    }
    
    _productCountLabel.hidden = NO;
    _productCountLabel.text = data.productCount;
    
#endif
}

- (void)layoutShipment
{
    CGFloat addButtonWidth = 25;
    CGFloat labelHeight = 25;
    CGFloat currentStandardLeftMargin = 8;
    CGFloat productCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f];
    
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == 0) {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            //make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(self).offset(-productCountLabelWidth - addButtonWidth - 2 * currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        [_productCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(32.0);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(_addButton.mas_left);
        }];
        
        [_minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(_productCountLabel.mas_left);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(-currentStandardLeftMargin).priorityHigh();
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
            make.centerY.equalTo(self);
        }];
        
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_left).offset(4);
            make.top.bottom.equalTo(_unitLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
    } else {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(self).offset(-addButtonWidth - 2 * currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        [_productCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(32.0);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(_addButton.mas_left);
        }];
        
        [_minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48.0);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(_productCountLabel.mas_left);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel).priorityHigh();
            make.top.equalTo(_unitLabel.mas_bottom);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_left).offset(4).priorityLow();
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
    }

    _priceReferenceLabel.hidden = YES;
    
#if MMR_RESTAURANT_VERSION
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        _inventoryLabel.hidden = YES;
        
        if (addProductListStyle == 0) {
            [_priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_unitLabel.mas_right).with.offset(kStandardLeftMargin);
            }];
        } else {
            [_priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
            }];
        }
    }
#endif
}

- (void)layoutPurchase
{
    CGFloat addButtonWidth = 25;
    CGFloat labelHeight = 25;
    CGFloat currentStandardLeftMargin = 8;
    CGFloat productCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f];
    
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == 0) {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            //make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(self).offset(-productCountLabelWidth - addButtonWidth - 2 * currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(currentStandardLeftMargin);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
            make.centerY.equalTo(self);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4);
            make.top.bottom.equalTo(_unitLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
    } else {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(self).offset(-addButtonWidth - 2 * currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel);
            make.top.equalTo(_unitLabel.mas_bottom);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4).priorityLow();
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
    }
}

- (void)layoutInventory
{
    CGFloat addButtonWidth = 25;
    CGFloat labelHeight = 25;
    CGFloat currentStandardLeftMargin = 8;
    
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == 0) {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            //make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(_addButton.mas_left).offset(currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
            make.height.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(currentStandardLeftMargin);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
            make.centerY.equalTo(self);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4);
            make.top.bottom.equalTo(_unitLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
    } else {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel);
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel);
            make.top.equalTo(_unitLabel.mas_bottom);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4).priorityLow();
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
    }
    
    _priceReferenceLabel.hidden = YES;
    _priceLabel.hidden = YES;
}

- (void)layoutMigrate
{
    CGFloat addButtonWidth = 25;
    CGFloat labelHeight = 25;
    CGFloat currentStandardLeftMargin = 8;
    CGFloat productCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f];
    
    NSInteger addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    if (addProductListStyle == 0) {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            //make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel.mas_right).offset(currentStandardLeftMargin);
            make.right.equalTo(self).offset(-productCountLabelWidth - addButtonWidth - 2 * currentStandardLeftMargin);
            make.top.bottom.equalTo(_unitLabel);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(currentStandardLeftMargin);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
            make.centerY.equalTo(self);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4);
            make.top.bottom.equalTo(_unitLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
    } else {
        
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(labelHeight);
        }];
        
        [_inventoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel);
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
        
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(addButtonWidth);
            make.height.mas_equalTo(addButtonWidth);
            make.centerY.equalTo(self);
            make.right.equalTo(self).with.offset(-currentStandardLeftMargin);
        }];
        
        CGSize fitSize = [_priceReferenceLabel sizeThatFits:CGSizeZero];
        [_priceReferenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_unitLabel);
            make.top.equalTo(_unitLabel.mas_bottom);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height + 2);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceReferenceLabel.mas_right).offset(4).priorityLow();
            make.height.equalTo(_unitLabel);
            make.centerY.equalTo(_priceReferenceLabel);
            make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        }];
    }
    
    
    _priceReferenceLabel.hidden = YES;
    _priceLabel.hidden = YES;
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@""
                                              font:JCHFont(12.0)
                                         textColor:JCHColorHeaderBackground
                                            aligin:NSTextAlignmentRight];
    [self addSubview:_productCountLabel];
    
    [_productCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX);
        make.right.equalTo(_addButton.mas_left).offset(-currentStandardLeftMargin);
        make.height.mas_equalTo(labelHeight);
        make.centerY.equalTo(self);
    }];
}

- (void)layoutAssembling
{
    [self layoutMigrate];
}

- (void)layoutDismounting
{
    [self layoutMigrate];
}

#pragma mark -
- (void)handleDecreaseMainUnitDishCount:(id)sender
{
    if (self.decreaseProductCountBlock != nil) {
        self.decreaseProductCountBlock(self.currentUnitUUID);
    }
}

- (void)handleIncreaseMainUnitDishCount:(id)sender
{
    if (self.increaseProductCountBlock != nil) {
        self.increaseProductCountBlock(self.currentUnitUUID);
    }
}

@end
