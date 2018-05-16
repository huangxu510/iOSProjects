//
//  JCHAddProductTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAddProductTableViewCell.h"
#import "JCHAddProductSKUSelectView.h"
#import "JCHAddProductMainAuxiliaryUnitSelectView.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "CommonHeader.h"
#import "Masonry.h"

@implementation JCHAddProductTableViewCellData

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
    [self.productLogoImage release];
    [self.productName release];
    [self.productUnit release];
    [self.productInventoryCount release];
    [self.productPrice release];
    [self.productCount release];
    [self.productCategory release];
    [self.auxiliaryUnitList release];
    [self.productProperty release];
    
    [super dealloc];
    return;
}

@end

@implementation JCHAddProductTableViewCellBottomContainerView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end


@interface JCHAddProductTableViewCell ()
{
    UIImageView *productLogoImageView;
    UILabel *productNameLabel;
    UILabel *priceReferenceLabel;
    UILabel *productPriceLabel;
    UILabel *productInventoryCountLabel;
    UILabel *productCountLabel;
    UIView *middleLine;
    JCHAddProductTableViewCellBottomContainerView *bottomContainerView;
    UIImageView *skuDetailBackgroundImageView;
    UIButton *selectInventorySKUButton;
    UIButton *addButton;
    CGFloat skuSelectContainerViewHeight;
    CGFloat mainAuxiliaryUnitSelectViewHeight;
    
    
    UIView *mainAuxiliaryUnitContainerView;
}

@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) GoodsSKURecord4Cocoa *goodsSKURecord;
@property (retain, nonatomic, readwrite) NSArray *auxiliaryUnitList;
@property (retain, nonatomic, readwrite) NSString *productUnit;

@end


@implementation JCHAddProductTableViewCell

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
    [self.pullDownButton release];
    [self.goodsSKURecord release];
    [self.auxiliaryUnitList release];
    [self.productUnit release];
    [super dealloc];
    return;
}

- (void)createUI
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
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
    
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
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
    }
    
    if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@""
                                                 font:JCHFont(12.0)
                                            textColor:JCHColorHeaderBackground
                                               aligin:NSTextAlignmentRight];
        [self.contentView addSubview:productCountLabel];
    }
    productInventoryCountLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(12.0)
                                       textColor:JCHColorHeaderBackground
                                          aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:productInventoryCountLabel];
    
    middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:middleLine];
    
    self.pullDownButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handlePullDown:)
                                          title:nil
                                     titleColor:nil
                                backgroundColor:nil];

    [self.pullDownButton setImage:[UIImage imageNamed:@"addgoods_list_btn_open"] forState:UIControlStateNormal];
    [self.pullDownButton setImage:[UIImage imageNamed:@"addgoods_list_btn_close"] forState:UIControlStateSelected];

    
    [self.contentView addSubview:self.pullDownButton];
    
    [self.pullDownButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    
    bottomContainerView = [[[JCHAddProductTableViewCellBottomContainerView alloc] init] autorelease];
    bottomContainerView.clipsToBounds = YES;
    bottomContainerView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    [self.contentView addSubview:bottomContainerView];
    
    UIImage *originalImage = [UIImage imageNamed:@"addgoods_bg_01"];
    UIImage *stretchImage = [originalImage stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    skuDetailBackgroundImageView = [[[UIImageView alloc] initWithImage:stretchImage] autorelease];
    skuDetailBackgroundImageView.userInteractionEnabled = YES;
    skuDetailBackgroundImageView.clipsToBounds = YES;
    skuDetailBackgroundImageView.backgroundColor = JCHColorGlobalBackground;
    [bottomContainerView addSubview:skuDetailBackgroundImageView];
    
    selectInventorySKUButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(selectInventorySKU:)
                                                    title:@"选择有货规格"
                                               titleColor:JCHColorMainBody
                                          backgroundColor:nil];
    [selectInventorySKUButton setTitle:@"取消选择" forState:UIControlStateSelected];
    selectInventorySKUButton.titleLabel.font = [UIFont jchSystemFontOfSize:13.0f];
    [selectInventorySKUButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateNormal];
    selectInventorySKUButton.layer.borderColor = JCHColorHeaderBackground.CGColor;
    selectInventorySKUButton.layer.borderWidth = kSeparateLineWidth;
    selectInventorySKUButton.layer.cornerRadius = 3;
    selectInventorySKUButton.clipsToBounds = YES;
    [skuDetailBackgroundImageView addSubview:selectInventorySKUButton];
    
    addButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleShowKeyboard:)
                                     title:nil
                                titleColor:nil
                           backgroundColor:nil];
    [addButton setImage:[UIImage imageNamed:@"addgoods_btn_add"] forState:UIControlStateNormal];
    [addButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [skuDetailBackgroundImageView addSubview:addButton];
    
    
    //UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kJCHAddProductTableViewCellNormalHeight)] autorelease];
    //selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    //self.selectedBackgroundView = selectedBackgroundView;
    mainAuxiliaryUnitContainerView = [[[UIView alloc] init] autorelease];
    mainAuxiliaryUnitContainerView.backgroundColor = [UIColor whiteColor];
    mainAuxiliaryUnitContainerView.hidden = YES;
    [self.contentView addSubview:mainAuxiliaryUnitContainerView];

    return;
}

- (void)tapAction
{
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}


- (void)handlePullDown:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handlePullDownSKUDetailView:button:)]) {
        [self.delegate handlePullDownSKUDetailView:self button:sender];
    }
}

- (void)handleShowKeyboard:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleShowKeyboard:unitUUID:)]) {
        [self.delegate handleShowKeyboard:self unitUUID:nil];
    }
}


- (void)setCellData:(JCHAddProductTableViewCellData *)cellData
{
    if (self.addProductListStyle == 0) {
        self.normalCellHeight = kJCHAddProductTableViewCellNormalHeight;
    } else {
        self.normalCellHeight = kJCHAddproductTableViewCellLeftMenuCellHeight;
    }
    
    [self removeSKUSelectedViews];
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
    
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

    //进货单或出货单
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        if ([cellData.productPrice isEqualToString:@"无参考价"]) {
            productPriceLabel.text = @"";
            productPriceLabel.hidden = YES;
            priceReferenceLabel.hidden = YES;
        } else {
            productPriceLabel.text = [NSString stringWithFormat:@"¥%@",  cellData.productPrice];
            priceReferenceLabel.hidden = NO;
        }
        
        NSString *inventoryConut = cellData.productInventoryCount;
        
        if (inventoryConut.doubleValue < 10) {
            //productCountLabel.text = [NSString stringWithFormat:@"%@%@%@",countPrefix, inventoryConut, cellData.productUnit];
            //productCountLabel.textColor = JCHColorHeaderBackground;
            NSMutableAttributedString *prefixString = [[[NSMutableAttributedString alloc] initWithString:@"库存" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorAuxiliary}] autorelease];
            NSAttributedString *countString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", inventoryConut, cellData.productUnit] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorHeaderBackground}] autorelease];
            [prefixString appendAttributedString:countString];
            productInventoryCountLabel.attributedText = prefixString;
        } else {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"库存%@%@", inventoryConut, cellData.productUnit];
            productInventoryCountLabel.textColor = JCHColorAuxiliary;
        }
    }
    //盘点单
    else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
        if (cellData.afterManifestInventoryChecked) {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"盘后%@%@  成本价 ¥%@", cellData.productInventoryCount, cellData.productUnit, cellData.productPrice];
            productInventoryCountLabel.textColor = JCHColorHeaderBackground;
        } else {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"库存%@%@", cellData.productInventoryCount, cellData.productUnit];
            productInventoryCountLabel.textColor = JCHColorAuxiliary;
        }
    }
    //移库单
    else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
        
        if (cellData.productCount.doubleValue == 0) {
            productCountLabel.hidden = YES;
        } else {
            productCountLabel.hidden = NO;
            productCountLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productCount, cellData.productUnit];
        }
        
        NSString *inventoryConut = cellData.productInventoryCount;
        if (inventoryConut.doubleValue < 10) {
            NSMutableAttributedString *prefixString = [[[NSMutableAttributedString alloc] initWithString:@"库存" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorAuxiliary}] autorelease];
            NSAttributedString *countString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", inventoryConut, cellData.productUnit] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorHeaderBackground}] autorelease];
            [prefixString appendAttributedString:countString];
            productInventoryCountLabel.attributedText = prefixString;
        } else {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"库存%@%@", inventoryConut, cellData.productUnit];
            productInventoryCountLabel.textColor = JCHColorAuxiliary;
        }
    }
    // 餐饮版--原料损耗
    else if (manifestStorage.currentManifestType == kJCHManifestMaterialWastage) {
        if (cellData.afterManifestInventoryChecked) {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"盘后%@%@  成本价 ¥%@", cellData.productInventoryCount, cellData.productUnit, cellData.productPrice];
            productInventoryCountLabel.textColor = JCHColorHeaderBackground;
        } else {
            productInventoryCountLabel.text = [NSString stringWithFormat:@"库存%@%@", cellData.productInventoryCount, cellData.productUnit];
            productInventoryCountLabel.textColor = JCHColorAuxiliary;
        }
    }
    return;
}

- (void)createSKUAndMainAuxiliaryUnitSelectedViews:(JCHAddProductTableViewCellData *)cellData
{
    if (cellData.is_multi_unit_enable) {
        self.pullDownButton.hidden = YES;
        productCountLabel.hidden = YES;
        mainAuxiliaryUnitContainerView.hidden = NO;
        productInventoryCountLabel.hidden = YES;
        productPriceLabel.hidden = YES;
        
        self.auxiliaryUnitList = cellData.auxiliaryUnitList;
        self.productUnit = cellData.productUnit;
        [self createMainAuxiliaryUnitSelectView];
    } else {
        self.pullDownButton.hidden = NO;
        mainAuxiliaryUnitContainerView.hidden = YES;
        productInventoryCountLabel.hidden = NO;
        productPriceLabel.hidden = NO;
        
        self.auxiliaryUnitList = nil;
        self.goodsSKURecord = cellData.goodsSKURecord;
        if (cellData.sku_hidden_flag || (!cellData.sku_hidden_flag && self.goodsSKURecord.skuArray.count == 0)) {
            [self setPullDownButtonToAddButton:YES];
        } else {
            [self setPullDownButtonToAddButton:NO];
            if (cellData.isArrowButtonStatusPullDown) {
                self.pullDownButton.selected = YES;
            } else {
                self.pullDownButton.selected = NO;
            }
        }
        
        if (!cellData.sku_hidden_flag && self.goodsSKURecord.skuArray.count != 0) {
            [self createSKUSelectedViews:cellData];
        }
    }
}

- (void)createSKUSelectedViews:(JCHAddProductTableViewCellData *)cellData
{
    //skuArray : @[@{skuTypeName : @[skuValueRecord, ...]}, ...];
    NSArray *skuArray = self.goodsSKURecord.skuArray;
    skuSelectContainerViewHeight = 0;
    for (NSInteger i = 0; i < skuArray.count; i++) {
        CGRect viewFrame = CGRectMake(0, skuSelectContainerViewHeight, kScreenWidth - 16, 0);
        JCHAddProductSKUSelectView *skuSelectView = [[[JCHAddProductSKUSelectView alloc] initWithFrame:viewFrame] autorelease];
        skuSelectView.autoSelectIfOneSKUValue = YES;
        [skuSelectView setButtonData:skuArray[i]];
        viewFrame.size.height = skuSelectView.viewHeight;
        skuSelectView.frame = viewFrame;
        skuSelectContainerViewHeight += skuSelectView.viewHeight;
        [skuDetailBackgroundImageView addSubview:skuSelectView];
    }
    
#if 0
    NSArray *foodProperty = [cellData.productProperty jsonStringToArrayOrDictionary];
 
    for (NSDictionary *property in foodProperty) {
        CGRect viewFrame = CGRectMake(0, skuSelectContainerViewHeight, kWidth - 16, 0);
        JCHAddProductSKUSelectView *skuSelectView = [[[JCHAddProductSKUSelectView alloc] initWithFrame:viewFrame] autorelease];
        skuSelectView.autoSelectIfOneSKUValue = YES;
//        [skuSelectView setButtonData:skuArray[i]];
        viewFrame.size.height = skuSelectView.viewHeight;
        skuSelectView.frame = viewFrame;
        skuSelectContainerViewHeight += skuSelectView.viewHeight;
        [skuDetailBackgroundImageView addSubview:skuSelectView];
    }
#endif
    
    if (skuArray.count > 0) {
        skuSelectContainerViewHeight += 59;
    }
    self.pullDownCellHeight = self.normalCellHeight + skuSelectContainerViewHeight;
    [skuDetailBackgroundImageView bringSubviewToFront:selectInventorySKUButton];
}

- (void)removeSKUSelectedViews
{
    for (UIView *subView in skuDetailBackgroundImageView.subviews) {
        if ([subView isKindOfClass:[JCHAddProductSKUSelectView class]]) {
            [subView removeFromSuperview];
        }
    }
    skuSelectContainerViewHeight = 0;
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

                [weakSelf.delegate handleShowKeyboard:weakSelf unitUUID:data.unitUUID];
            }
        }];
        
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


- (NSArray *)getSKUData
{
    NSMutableArray *skuData = [NSMutableArray array];
    for (UIView *subView in skuDetailBackgroundImageView.subviews) {
        if ([subView isKindOfClass:[JCHAddProductSKUSelectView class]]) {
            JCHAddProductSKUSelectView *view = (JCHAddProductSKUSelectView *)subView;
            if (view.selectedData.count > 0) {
                 [skuData addObject:view.selectedData];
            }
        }
    }
    return skuData;
}

//根据skuValue数组选中对应的button
- (void)selectButtons:(NSArray *)skuValueUUIDs
{
    for (UIView *subView in skuDetailBackgroundImageView.subviews) {
        if ([subView isKindOfClass:[JCHAddProductSKUSelectView class]]) {
            JCHAddProductSKUSelectView *view = (JCHAddProductSKUSelectView *)subView;
            [view selectButtons:skuValueUUIDs];
        }
    }
}

- (void)deselectAllButtons
{
    for (UIView *subView in skuDetailBackgroundImageView.subviews) {
        if ([subView isKindOfClass:[JCHAddProductSKUSelectView class]]) {
            JCHAddProductSKUSelectView *view = (JCHAddProductSKUSelectView *)subView;
            [view deselectAllButtons];
        }
    }
}

- (void)setPullDownButtonToAddButton:(BOOL)addBtn
{
    if (addBtn) {
        UIImage *image = [UIImage imageNamed:@"addgoods_btn_add"];
        [self.pullDownButton setImage:image forState:UIControlStateNormal];
        [self.pullDownButton setImage:image forState:UIControlStateSelected];
        
        [self.pullDownButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.pullDownButton addTarget:self action:@selector(handleShowKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"addgoods_list_btn_open"];
        UIImage *selectedImage = [UIImage imageNamed:@"addgoods_list_btn_close"];

        [self.pullDownButton setImage:image forState:UIControlStateNormal];
        [self.pullDownButton setImage:selectedImage forState:UIControlStateSelected];
        
        [self.pullDownButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.pullDownButton addTarget:self action:@selector(handlePullDown:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)selectInventorySKU:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        if ([self.delegate respondsToSelector:@selector(handleSelectInventorySKU:)]) {
            [self.delegate handleSelectInventorySKU:self];
        }
    } else {
        [self deselectAllButtons];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    selectInventorySKUButton.selected = NO;
    if (self.addProductListStyle == 0) {
        [self layoutDefaultUI];
    } else {
        [self layoutLeftMenuUI];
    }
    
    return;
}


- (void)layoutDefaultUI
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    switch (manifestStorage.currentManifestType) {
        case kJCHOrderPurchases:
        {
            [self layoutPurchasesDefaultUI];
        }
            break;
            
        case kJCHOrderShipment:
        {
            [self layoutShipmentDefaultUI];
        }
            break;
            
        case kJCHManifestInventory:
        {
            [self layoutInventoryDefaultUI];
        }
            break;
            
        case kJCHManifestMigrate:
        {
            [self layoutMigrateDefaultUI];
        }
            break;
            
        case kJCHManifestAssembling:
        {
            [self layoutAssemblingDefaultUI];
        }
            break;
            
        case kJCHManifestDismounting:
        {
            [self layoutDismountingDefaultUI];
        }
            break;
            
        case kJCHManifestMaterialWastage:
        {
            [self layoutInventoryDefaultUI];
        }
            break;
            
        case kJCHRestaurntManifestOpenTable:
        {
            [self layoutShipmentDefaultUI];
        }
            break;
            
        default:
            break;
    }
}

- (void)layoutPurchasesDefaultUI
{
    const CGFloat imageViewWidth = 50;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 22.0f;
    const CGFloat productCountLabelHeight = imageViewWidth - productNameLabelHeight;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    CGFloat inventoryCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:90];
    
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
    
 
    CGSize fitSize = [priceReferenceLabel sizeThatFits:CGSizeZero];
    
    [priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productInventoryCountLabel.mas_right).offset(currentkStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 5);
        make.height.mas_equalTo(fitSize.height + 2);
        make.centerY.equalTo(productInventoryCountLabel);
    }];
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceReferenceLabel.mas_right).offset(4);
        make.top.equalTo(productInventoryCountLabel);
        make.right.equalTo(productNameLabel);
        make.height.mas_equalTo(productCountLabelHeight);
    }];
    

    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];

    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}
- (void)layoutShipmentDefaultUI
{
    const CGFloat imageViewWidth = 50;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 22.0f;
    const CGFloat productCountLabelHeight = imageViewWidth - productNameLabelHeight;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    CGFloat inventoryCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:90];
    
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
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productInventoryCountLabel.mas_right).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(productInventoryCountLabel);
        make.right.equalTo(productNameLabel);
        make.height.mas_equalTo(productCountLabelHeight);
    }];

    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];

    
    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    CGSize fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}
- (void)layoutMigrateDefaultUI
{
    const CGFloat imageViewWidth = 50;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 22.0f;
    const CGFloat productCountLabelHeight = imageViewWidth - productNameLabelHeight;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    
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
    
    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];
    
    [productInventoryCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_left);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.right.equalTo(self.pullDownButton.mas_left).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(productCountLabelHeight);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pullDownButton.mas_left).with.offset(-currentkStandardLeftMargin);
        make.height.mas_equalTo(productNameLabelHeight);
        make.centerY.equalTo(productLogoImageView);
        make.width.mas_equalTo(100);
    }];
    
    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    CGSize fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}

- (void)layoutInventoryDefaultUI
{
    [self layoutMigrateDefaultUI];
}

- (void)layoutAssemblingDefaultUI
{
    [self layoutMigrateDefaultUI];
}
- (void)layoutDismountingDefaultUI
{
    [self layoutMigrateDefaultUI];
}

- (void)layoutLeftMenuUI
{
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    switch (manifestStorage.currentManifestType) {
        case kJCHOrderPurchases:
        {
            [self layoutPurchasesLeftMenuUI];
        }
            break;
            
        case kJCHOrderShipment:
        {
            [self layoutShipmentLeftMenuUI];
        }
            break;
            
        case kJCHManifestInventory:
        {
            [self layoutInventoryLeftMenuUI];
        }
            break;
            
        case kJCHManifestMigrate:
        {
            [self layoutMigrateLeftMenuUI];
        }
            break;
            
        case kJCHManifestAssembling:
        {
            [self layoutAssemblingLeftMenuUI];
        }
            break;
            
        case kJCHManifestDismounting:
        {
            [self layoutDismountingLeftMenuUI];
        }
            break;
            
        case kJCHManifestMaterialWastage:
        {
            [self layoutInventoryLeftMenuUI];
        }
            break;
            
        case kJCHRestaurntManifestOpenTable:
        {
            [self layoutShipmentLeftMenuUI];
        }
            break;
            
        default:
            break;
    }
}

- (void)layoutPurchasesLeftMenuUI
{
    const CGFloat imageViewWidth = 64;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 28.0f;
    const CGFloat inventoryLabelHeight = 16.0f;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    
    
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
    
    CGSize fitSize = [priceReferenceLabel sizeThatFits:CGSizeZero];
    
    [priceReferenceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productInventoryCountLabel);
        make.width.mas_equalTo(fitSize.width + 5);
        make.height.mas_equalTo(fitSize.height + 2);
        make.top.equalTo(productInventoryCountLabel.mas_bottom).offset(5);
    }];
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceReferenceLabel.mas_right).offset(4);
        make.centerY.equalTo(priceReferenceLabel);
        make.right.equalTo(productNameLabel);
        make.height.equalTo(priceReferenceLabel);
    }];
    
    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];
    
    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}
- (void)layoutShipmentLeftMenuUI
{
    const CGFloat imageViewWidth = 64;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 28.0f;
    const CGFloat inventoryLabelHeight = 16.0f;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    
    
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
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];
    
    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    CGSize fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}

- (void)layoutMigrateLeftMenuUI
{
    const CGFloat imageViewWidth = 64;
    const CGFloat imageViewHeight = imageViewWidth;
    
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat productNameLabelHeight = 28.0f;
    const CGFloat productCountLabelHeight = imageViewWidth - productNameLabelHeight;
    const CGFloat backgroundImageViewBottomOffset = 8.0f;
    
    const CGFloat pullDownButtonWidth = 25.0f;
    
    
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
    
    if (self.auxiliaryUnitList) {
        [self.contentView bringSubviewToFront:middleLine];
        
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    } else {
        [middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(self.pullDownButton.selected ? -currentkStandardLeftMargin : 0);
            make.bottom.equalTo(productLogoImageView.mas_bottom).with.offset(8);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    CGFloat pullDownButtonRightOffset = currentkStandardLeftMargin;
    
    [self.pullDownButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(productLogoImageView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-pullDownButtonRightOffset);
    }];
    
    [productInventoryCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_left);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.right.equalTo(self.pullDownButton.mas_left).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(productCountLabelHeight);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pullDownButton.mas_left).with.offset(-currentkStandardLeftMargin);
        make.height.mas_equalTo(productNameLabelHeight);
        make.centerY.equalTo(productLogoImageView);
        make.width.mas_equalTo(100);
    }];
    
    [bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleLine.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(skuSelectContainerViewHeight);
    }];
    
    [skuDetailBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(bottomContainerView).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(bottomContainerView);
        make.height.mas_equalTo((skuSelectContainerViewHeight == 0) ? 0 : skuSelectContainerViewHeight - backgroundImageViewBottomOffset);
    }];
    
    CGSize fitSize = [selectInventorySKUButton.titleLabel sizeThatFits:CGSizeZero];
    [selectInventorySKUButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView.mas_bottom).with.offset(-15);
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(currentkStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 10);
        make.width.mas_equalTo(fitSize.width + 8);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(pullDownButtonWidth);
        make.height.mas_equalTo(pullDownButtonWidth);
        make.centerY.equalTo(selectInventorySKUButton);
        make.right.equalTo(skuDetailBackgroundImageView).with.offset(-currentkStandardLeftMargin);
    }];
    
    [mainAuxiliaryUnitContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.top.equalTo(productNameLabel.mas_bottom);
        make.height.mas_equalTo(mainAuxiliaryUnitSelectViewHeight);
        make.right.equalTo(self.contentView);
    }];
}
- (void)layoutInventoryLeftMenuUI
{
    [self layoutMigrateDefaultUI];
}
- (void)layoutAssemblingLeftMenuUI
{
    [self layoutMigrateDefaultUI];
}
- (void)layoutDismountingLeftMenuUI
{
    [self layoutMigrateDefaultUI];
}
@end
