//
//  JCHAddDishesViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHTakeoutAddDishesViewController.h"
#import "JCHTakeoutDishesCharacterViewController.h"
#import "JCHTakeoutInfoSetView.h"
#import "JCHAddDishesTakeoutInfoViewController.h"
#import "JCHBeginInventoryForSKUView.h"
#import "JCHAddSKUValueFooterView.h"
#import "JCHSKUSelectViewController.h"
#import "JCHSKUInfoView.h"
#import "JCHRestaurantCategoryViewController.h"
#import "JCHCategoryListViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHInitialInventoryViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHProductBarCodeViewController.h"
#import "JCHProductSalePriceViewController.h"
#import "JCHSetInitialInventoryViewController.h"
#import "JCHAddMainAuxiliaryUnitViewController.h"
#import "JCHSwitchLabelView.h"
#import "JCHArrowTapView.h"
#import "JCHTextView.h"
#import "JCHUIFactory.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHImageUtility.h"
#import "UIImage+JCHImage.h"
#import "Masonry.h"
#import "JCHMenuView.h"
#import "JCHKeyboardHelper.h"
#import "JCHSyncStatusManager.h"
#import "ImageFileSynchronizer.h"
#import "CommonHeader.h"
#import "LCActionSheet.h"

enum ProductUnitSKUMode
{
    kProductWithoutSKU,     // 无规格菜品
    kProductWithSKU,        // 多规格菜品
    kProductMainUnit,       // 主辅单位
};

enum ActionSheetType
{
    kActionSheetTypeTakePhoto = 1,
    kActionSheetTypeChooseProductMode = 2,
};

@interface JCHTakeoutAddDishesViewController () <UITextViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
LCActionSheetDelegate,
UITextFieldDelegate,
JCHAddSKUValueFooterViewDelegate,
UIAlertViewDelegate>
{
    UILabel *nameTitleLabel;
    UITextField *nameTextView;
    
    UIButton *cameraButtonArray[5];
    NSInteger currentCameraButtonIndex;
    
    JCHArrowTapView *unitArrowTapView;
    JCHArrowTapView *categoryArrowTapView;
    JCHArrowTapView *skuModeProductLabel;
    
    UILabel *traderCodeTitleLabel;
    JCHLengthLimitTextField *traderCodeTextField;
    JCHSwitchLabelView *productStatusView;
    
    UIView *takeoutContainerView;
    JCHArrowTapView *productCharacterTapView;
    JCHArrowTapView *takeoutInfoTapView;
    
    JCHTextView *remarkTextView;
    UILabel *skuUnitTipLabel;
    
    UIView *withSKUContainerView;
    JCHArrowTapView *withSKUSpecificationView;
    JCHArrowTapView *withSKUPriceView;
    JCHArrowTapView *withSKUInventoryView;
    JCHArrowTapView *withSKUBarCodeView;
    
    UIView *withoutSKUContainerView;
    JCHTitleTextField *withoutSKUPriceView;
    JCHArrowTapView *withoutSKUInventoryView;
    JCHTitleTextField *withoutSKUBarCodeView;
    
    UIView *mainUnitContainerView;
    JCHArrowTapView *mainUnitUnitView;
    JCHArrowTapView *mainUnitPriceView;
    JCHArrowTapView *mainUnitInventoryView;
    JCHArrowTapView *mainUnitBarCodeView;
    
    enum ProductUnitSKUMode currentProductMode;
    enum ProductUnitSKUMode selectedProductMode;
    
    BOOL hasCreateUI;
}
@property (nonatomic, retain) ProductRecord4Cocoa *productRecord;
@property (retain, nonatomic, readwrite) NSArray *allUnitList;
@property (retain, nonatomic, readwrite) NSArray *allCategoryList;
@property (retain, nonatomic, readwrite) NSArray *skuData;
@property (retain, nonatomic, readwrite) NSString *currentGoodsSKUUUID;
@property (retain, nonatomic, readwrite) UIImage *defaultCameraImage;
@property (retain, nonatomic, readwrite) UIImage *defaultPlaceholderImage;
@property (retain, nonatomic, readwrite) NSMutableArray<NSString *> *productImagesArray;

@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *currentUnitRecord;
@property (retain, nonatomic, readwrite) CategoryRecord4Cocoa *currentCategoryRecord;

@property (retain, nonatomic, readwrite) NSMutableArray *currentBeginInventoryForSKUViews;
@property (retain, nonatomic, readwrite) NSArray<NSString *> *productModeTitles;

@property (retain, nonatomic, readwrite) NSArray<JCHBeginInventoryForSKUViewData *> *skuInventoryArray;
@property (retain, nonatomic, readwrite) NSArray<JCHBeginInventoryForSKUViewData *> *unitInventoryArray;
@property (retain, nonatomic, readwrite) NSArray<JCHBeginInventoryForSKUViewData *> *noskuInventoryArray;

@property (retain, nonatomic, readwrite) NSArray<ProductSalePriceRecord *> *skuSalePriceArray;
@property (retain, nonatomic, readwrite) NSArray<ProductBarCodeRecord *> *skuBarCodeArray;

@property (retain, nonatomic, readwrite) NSMutableArray<ProductUnitRecord *> *unitRecordArray;
@property (retain, nonatomic, readwrite) NSMutableArray<ProductSalePriceRecord *> *unitSalePriceArray;
@property (retain, nonatomic, readwrite) NSMutableArray<ProductBarCodeRecord *> *unitBarCodeArray;

@property (retain, nonatomic, readwrite) NSMutableArray<JCHTakeoutInfoSetViewData *> *takeoutInfoRecordArray;

@property (retain, nonatomic, readwrite) NSString *productCharactersJSONString;

@end

@implementation JCHTakeoutAddDishesViewController

- (id)initWithProductRecord:(ProductRecord4Cocoa *)productRecord
{
    self = [super init];
    if (self) {
        if (productRecord) {
            self.productRecord = productRecord;
        }
        
        if (kJCHAddDishesTypeAddProduct == self.productType) {
            self.title = @"添加菜品";
        } else if (kJCHAddDishesTypeModifyProduct == self.productType) {
            self.title = @"修改菜品";
        }
        
        hasCreateUI = NO;
        currentProductMode = kProductWithoutSKU;
        selectedProductMode = kProductWithoutSKU;
        currentCameraButtonIndex = 0;
        memset(&cameraButtonArray[0], 0, sizeof(cameraButtonArray));
        self.productModeTitles = @[@"无规格", @"多规格"];
        self.currentBeginInventoryForSKUViews = [NSMutableArray array];
        self.defaultCameraImage = [UIImage imageNamed:kDefaultCameraButtonImageName];
        self.defaultPlaceholderImage = [UIImage jchProductImageNamed:nil];
        self.productImagesArray = [[[NSMutableArray alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    [nameTextView removeObserver:self forKeyPath:@"contentSize"];
    
    self.allCategoryList = nil;
    self.allUnitList = nil;
    self.skuData = nil;
    self.currentGoodsSKUUUID = nil;
    self.currentUnitRecord = nil;
    self.currentCategoryRecord = nil;
    self.currentBeginInventoryForSKUViews = nil;
    self.productModeTitles = nil;
    self.skuInventoryArray = nil;
    self.unitInventoryArray = nil;
    self.noskuInventoryArray = nil;
    self.skuSalePriceArray = nil;
    self.skuBarCodeArray = nil;
    self.unitRecordArray = nil;
    self.unitSalePriceArray = nil;
    self.unitBarCodeArray = nil;
    self.defaultCameraImage = nil;
    self.defaultPlaceholderImage = nil;
    self.productImagesArray = nil;
    self.productRecord = nil;
    self.currentSKURecord = nil;
    self.takeoutInfoRecordArray = nil;
    self.productCharactersJSONString = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MBProgressHUD showHUDWithTitle:@""
                             detail:@"加载中..."
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
        [self createUI];
        [self restoreUIStatus];
        [self handleViewWillAppear];
        hasCreateUI = YES;
        [MBProgressHUD hideAllHudsForWindow];
    });
    
    
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (hasCreateUI) {
        [self handleViewWillAppear];
    }
}


- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveRecord:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIFont *textFont = [UIFont jchSystemFontOfSize:16.0f];
    UIColor *textColor = JCHColorMainBody;
    const CGFloat titleLabelWidth = 80;
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    
    self.backgroundScrollView.backgroundColor = [UIColor whiteColor];
    
    // 名称
    {
        const CGFloat seperatorViewHeight = 240.0;
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:seperatorViewHeight];
        [self.backgroundScrollView addSubview:seperatorView];
        seperatorView.backgroundColor = JCHColorGlobalBackground;
        
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundScrollView).with.offset(-seperatorViewHeight + kStandardTopMargin);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(seperatorViewHeight);
        }];
        
        UIView *seperatorLine = [JCHUIFactory createSeperatorLine:0];
        [self.backgroundScrollView addSubview:seperatorLine];
        [self.backgroundScrollView bringSubviewToFront:seperatorLine];
        [seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperatorView.mas_bottom);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        nameTitleLabel = [JCHUIFactory createLabel:CGRectZero title:@"名称"
                                              font:textFont
                                         textColor:textColor
                                            aligin:NSTextAlignmentLeft];
        [self.backgroundScrollView addSubview:nameTitleLabel];
        
        [nameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
            make.top.equalTo(seperatorView.mas_bottom);
            make.width.mas_equalTo(titleLabelWidth);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        nameTextView = [[[UITextField alloc] init] autorelease];
        nameTextView.font = textFont;
        nameTextView.placeholder = @"请输入菜品名称";
        nameTextView.textAlignment = NSTextAlignmentRight;
        nameTextView.textColor = JCHColorMainBody;
        nameTextView.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
        [nameTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        
        [self.backgroundScrollView addSubview:nameTextView];
        
        [nameTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameTitleLabel.mas_right).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth - titleLabelWidth - 2 * kStandardLeftMargin);
            make.bottom.equalTo(nameTitleLabel);
            make.top.equalTo(nameTitleLabel);
        }];
        
        UIView *seperatorLineView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorLineView];
        
        [seperatorLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameTextView.mas_bottom);
            make.left.equalTo(nameTitleLabel.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    //图片
    const CGFloat cameraButtonHeight = (kScreenWidth - 6 * kStandardLeftMargin) / 5;
    {
        for (size_t i = 0; i < sizeof(cameraButtonArray) / sizeof(cameraButtonArray[0]); ++i) {
            UIButton *theButton = [JCHUIFactory createButton:CGRectZero
                                                      target:self
                                                      action:@selector(handleActionSheetShow:)
                                                       title:nil
                                                  titleColor:nil
                                             backgroundColor:nil];
            theButton.layer.cornerRadius = 3;
            theButton.clipsToBounds = YES;
            theButton.tag = i;
            theButton.hidden = YES;
            [theButton setImage:self.defaultCameraImage forState:UIControlStateNormal];
            [self.backgroundScrollView addSubview:theButton];
            
            __block UIButton *leftButton = nil;
            if (0 != i) {
                leftButton = cameraButtonArray[i - 1];
            }
            
            [theButton mas_makeConstraints:^(MASConstraintMaker *make) {
                if (nil == leftButton) {
                    make.left.equalTo(nameTitleLabel.mas_left);
                } else {
                    make.left.equalTo(leftButton.mas_right).with.offset(kStandardLeftMargin);
                }
                
                make.top.equalTo(nameTitleLabel.mas_bottom).with.offset(kStandardTopMargin / 3);
                make.height.mas_equalTo(cameraButtonHeight);
                make.width.mas_equalTo(cameraButtonHeight);
            }];
            
            cameraButtonArray[i] = theButton;
        }
        
        cameraButtonArray[0].hidden = NO;
        
        UIView *seperatorLineView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorLineView];
        
        [seperatorLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cameraButtonArray[0].mas_bottom).with.offset(kStandardTopMargin / 3);
            make.left.equalTo(nameTitleLabel.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    // 类型
    {
        categoryArrowTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        categoryArrowTapView.titleLabel.text = @"类型";
        categoryArrowTapView.bottomLine.hidden = NO;
        [categoryArrowTapView.button addTarget:self action:@selector(selecetCategory) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.backgroundScrollView addSubview:categoryArrowTapView];
    
    [categoryArrowTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(cameraButtonArray[0].mas_bottom).with.offset(kStandardTopMargin / 3 + 1.0);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    // 单位
    {
        unitArrowTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        unitArrowTapView.titleLabel.text = @"单位";
        unitArrowTapView.titleLabel.font = [UIFont systemFontOfSize:15.0];
        unitArrowTapView.bottomLine.hidden = YES;
        [unitArrowTapView.button addTarget:self action:@selector(selectUnit) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundScrollView addSubview:unitArrowTapView];
        
        [unitArrowTapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(categoryArrowTapView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    //商家简称
    if (false)
    {
        traderCodeTitleLabel = [JCHUIFactory createLabel:CGRectZero title:@"商家简称"
                                                    font:textFont
                                               textColor:textColor
                                                  aligin:NSTextAlignmentLeft];
        [self.backgroundScrollView addSubview:traderCodeTitleLabel];
        
        [traderCodeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
            make.width.mas_equalTo(titleLabelWidth);
            make.top.equalTo(unitArrowTapView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        traderCodeTextField = [JCHUIFactory createLengthLimitTextField:CGRectZero placeHolder:nil
                                                             textColor:textColor
                                                                aligin:NSTextAlignmentLeft];
        traderCodeTextField.font = textFont;
        traderCodeTextField.decimalPointOnly = NO;
        traderCodeTextField.maxStringLength = kMaxSaveStringLength;
        NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:@"请输入商家简称" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFont}] autorelease];
        traderCodeTextField.attributedPlaceholder = placeHolder;
        traderCodeTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
        traderCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        traderCodeTextField.textAlignment = NSTextAlignmentRight;
        [self.backgroundScrollView addSubview:traderCodeTextField];
        
        [traderCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(traderCodeTitleLabel.mas_right);
            make.right.equalTo(unitArrowTapView.mas_right).with.offset(-kStandardLeftMargin);
            make.top.equalTo(traderCodeTitleLabel.mas_top);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 提示信息
    {
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorView];
        seperatorView.backgroundColor = JCHColorGlobalBackground;
        seperatorView.clipsToBounds = NO;
        
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(unitArrowTapView.mas_bottom);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(40.0);
        }];
        
        skuUnitTipLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"菜品属性包含无规格、多规格、主辅单位三种"
                                               font:[UIFont systemFontOfSize:13.0]
                                          textColor:UIColorFromRGB(0XA4A4A4)
                                             aligin:NSTextAlignmentLeft];
        [self.backgroundScrollView addSubview:skuUnitTipLabel];
        skuUnitTipLabel.backgroundColor = [UIColor clearColor];
        
        [skuUnitTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(seperatorView.mas_centerY);
            make.left.equalTo(self.backgroundScrollView.mas_left).with.offset(kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(40.0);
        }];
        
        UIView *topSeperateLine = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame)];
        [seperatorView addSubview:topSeperateLine];
        [topSeperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(seperatorView.mas_top);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        UIView *bottomSeperateLine = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame)];
        [seperatorView addSubview:bottomSeperateLine];
        [bottomSeperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(seperatorView.mas_bottom).with.offset(-0);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    // 菜品模式选择
    {
        skuModeProductLabel = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [self.backgroundScrollView addSubview:skuModeProductLabel];
        skuModeProductLabel.titleLabel.font = textFont;
        skuModeProductLabel.titleLabel.textColor = textColor;
        skuModeProductLabel.titleLabel.text = @"菜品属性";
        skuModeProductLabel.detailLabel.text = self.productModeTitles[currentProductMode];
        [skuModeProductLabel.button addTarget:self
                                       action:@selector(handleChooseProductMode:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        [skuModeProductLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(skuUnitTipLabel.mas_bottom);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 有规格菜品容器
    {
        withSKUContainerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        withSKUContainerView.clipsToBounds = YES;
        [self.backgroundScrollView addSubview:withSKUContainerView];
        
        CGFloat containerViewHeight = 0.0;
        if (currentProductMode == kProductWithSKU) {
            containerViewHeight = 3 * kStandardItemHeight;
        }
        
        [withSKUContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(skuModeProductLabel.mas_bottom);
            make.height.mas_equalTo(containerViewHeight);
        }];
        
        
        withSKUSpecificationView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [withSKUContainerView addSubview:withSKUSpecificationView];
        withSKUSpecificationView.titleLabel.text = @"•  规格";
        withSKUSpecificationView.titleLabel.font = textFont;
        withSKUSpecificationView.titleLabel.textColor = textColor;
        withSKUSpecificationView.detailLabel.adjustsFontSizeToFitWidth = NO;
        withSKUSpecificationView.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [withSKUSpecificationView.button addTarget:self
                                            action:@selector(handleSetProductSKU:)
                                  forControlEvents:UIControlEventTouchUpInside];
        [withSKUSpecificationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(withSKUContainerView);
            make.top.equalTo(withSKUContainerView.mas_top);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        withSKUPriceView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [withSKUContainerView addSubview:withSKUPriceView];
        withSKUPriceView.titleLabel.text = @"•  单品售价";
        withSKUPriceView.titleLabel.font = textFont;
        withSKUPriceView.titleLabel.textColor = textColor;
        [withSKUPriceView.button addTarget:self
                                    action:@selector(handleSetSKUSalePrice:)
                          forControlEvents:UIControlEventTouchUpInside];
        [withSKUPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(withSKUContainerView);
            make.top.equalTo(withSKUSpecificationView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        withSKUBarCodeView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [withSKUContainerView addSubview:withSKUBarCodeView];
        withSKUBarCodeView.titleLabel.text = @"•  单品条码";
        withSKUBarCodeView.titleLabel.font = textFont;
        withSKUBarCodeView.titleLabel.textColor = textColor;
        [withSKUBarCodeView.button addTarget:self
                                      action:@selector(handleSetSKUBarCode:)
                            forControlEvents:UIControlEventTouchUpInside];
        [withSKUBarCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(withSKUContainerView);
            make.top.equalTo(withSKUPriceView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 主辅助单位容器
    {
        mainUnitContainerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        mainUnitContainerView.clipsToBounds = YES;
        [self.backgroundScrollView addSubview:mainUnitContainerView];
        
        CGFloat containerViewHeight = 0.0;
        if (currentProductMode == kProductMainUnit) {
            containerViewHeight = 3 * kStandardItemHeight;
        }
        
        [mainUnitContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(withSKUContainerView.mas_bottom);
            make.height.mas_equalTo(containerViewHeight);
        }];
        
        mainUnitUnitView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [mainUnitContainerView addSubview:mainUnitUnitView];
        mainUnitUnitView.titleLabel.text = @"•  辅助单位";
        mainUnitUnitView.titleLabel.font = textFont;
        mainUnitUnitView.titleLabel.textColor = textColor;
        [mainUnitUnitView.button addTarget:self
                                    action:@selector(handleAddMainUnit:)
                          forControlEvents:UIControlEventTouchUpInside];
        [mainUnitUnitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(mainUnitContainerView);
            make.top.equalTo(mainUnitContainerView.mas_top);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        mainUnitPriceView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [mainUnitContainerView addSubview:mainUnitPriceView];
        mainUnitPriceView.titleLabel.text = @"•  主辅菜品售价";
        mainUnitPriceView.titleLabel.font = textFont;
        mainUnitPriceView.titleLabel.textColor = textColor;
        [mainUnitPriceView.button addTarget:self
                                     action:@selector(handleSetUnitSalePrice:)
                           forControlEvents:UIControlEventTouchUpInside];
        [mainUnitPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(mainUnitContainerView);
            make.top.equalTo(mainUnitUnitView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        mainUnitBarCodeView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        [mainUnitContainerView addSubview:mainUnitBarCodeView];
        mainUnitBarCodeView.titleLabel.text = @"•  主辅菜品条码";
        mainUnitBarCodeView.titleLabel.font = textFont;
        mainUnitBarCodeView.titleLabel.textColor = textColor;
        [mainUnitBarCodeView.button addTarget:self
                                       action:@selector(handleSetUnitBarCode:)
                             forControlEvents:UIControlEventTouchUpInside];
        [mainUnitBarCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(mainUnitContainerView);
            make.top.equalTo(mainUnitPriceView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 无规格菜品容器
    {
        withoutSKUContainerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        withoutSKUContainerView.clipsToBounds = YES;
        [self.backgroundScrollView addSubview:withoutSKUContainerView];
        
        CGFloat containerViewHeight = 0.0;
        if (currentProductMode == kProductWithoutSKU) {
            containerViewHeight = 2 * kStandardItemHeight;
        }
        
        [withoutSKUContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(mainUnitContainerView.mas_bottom);
            make.height.mas_equalTo(containerViewHeight);
        }];
        
        withoutSKUPriceView = [[[JCHTitleTextField alloc] initWithTitle:@"•  菜品售价"
                                                                   font:textFont
                                                            placeholder:@"0.00"
                                                              textColor:textColor
                                                 isLengthLimitTextField:YES] autorelease];
        [withoutSKUContainerView addSubview:withoutSKUPriceView];
        withoutSKUPriceView.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        withoutSKUPriceView.textField.keyboardType = UIKeyboardTypeDecimalPad;
        withoutSKUPriceView.textField.delegate = self;
        [withoutSKUPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(withoutSKUContainerView);
            make.top.equalTo(withoutSKUContainerView.mas_top);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        CGRect textfieldRightFrame = CGRectMake(0, 0, 32, 20);
        UIView *textfieldRightView = [[[UIView alloc] initWithFrame:textfieldRightFrame] autorelease];
        withoutSKUBarCodeView = [[[JCHTitleTextField alloc] initWithTitle:@"•  菜品条码"
                                                                     font:textFont
                                                              placeholder:@"请输入或扫描条码"
                                                                textColor:textColor
                                                   isLengthLimitTextField:YES] autorelease];
        JCHLengthLimitTextField *barCodeTextField = (JCHLengthLimitTextField *)withoutSKUBarCodeView.textField;
        barCodeTextField.decimalPointOnly = NO;
        barCodeTextField.maxStringLength = kMaxSaveStringLength;
        UIButton *barCodeButton = [JCHUIFactory createButton:CGRectMake(12, 0, 20, 20)
                                                      target:self
                                                      action:@selector(handleBarCodeScanner)
                                                       title:nil
                                                  titleColor:[UIColor blueColor]
                                             backgroundColor:nil];
        [barCodeButton setImage:[UIImage imageNamed:@"btn_setting_goods_scan"] forState:UIControlStateNormal];
        [textfieldRightView addSubview:barCodeButton];
        withoutSKUBarCodeView.textField.rightView = textfieldRightView;
        withoutSKUBarCodeView.textField.rightViewMode = UITextFieldViewModeAlways;
        
        [withoutSKUContainerView addSubview:withoutSKUBarCodeView];
        [withoutSKUBarCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(withoutSKUContainerView);
            make.top.equalTo(withoutSKUPriceView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
#if MMR_TAKEOUT_VERSION
    // 外卖信息相关
    {
        [withoutSKUContainerView addSeparateLineWithMasonryTop:NO bottom:YES];
        [withSKUContainerView addSeparateLineWithMasonryTop:NO bottom:YES];
        [mainUnitContainerView addSeparateLineWithMasonryTop:NO bottom:YES];
        takeoutContainerView = [[[UIView alloc] init] autorelease];
        takeoutContainerView.backgroundColor = JCHColorGlobalBackground;
        takeoutContainerView.clipsToBounds = YES;
        [self.backgroundScrollView addSubview:takeoutContainerView];
        
        [takeoutContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(withoutSKUContainerView.mas_bottom);
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kStandardItemHeight * 2 + kStandardSeparateViewHeight * 2);
        }];
        
        productCharacterTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        productCharacterTapView.titleLabel.text = @"菜品特性";
        productCharacterTapView.bottomLine.hidden = YES;
        [productCharacterTapView addSeparateLineWithMasonryTop:YES bottom:YES];
        [productCharacterTapView.button addTarget:self action:@selector(handleSetProductCharacter) forControlEvents:UIControlEventTouchUpInside];
        [takeoutContainerView addSubview:productCharacterTapView];
        
        [productCharacterTapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(takeoutContainerView).offset(kStandardSeparateViewHeight);
            make.left.width.equalTo(takeoutContainerView);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        takeoutInfoTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        takeoutInfoTapView.titleLabel.text = @"外卖信息";
        [takeoutInfoTapView addSeparateLineWithMasonryTop:YES bottom:NO];
        [takeoutInfoTapView.button addTarget:self action:@selector(handleSetTakeoutInfo) forControlEvents:UIControlEventTouchUpInside];
        [takeoutContainerView addSubview:takeoutInfoTapView];
        
        [takeoutInfoTapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(productCharacterTapView.mas_bottom).offset(kStandardSeparateViewHeight);
            make.left.width.equalTo(takeoutContainerView);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
#endif
    //菜品启用
    {
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorView];
        seperatorView.backgroundColor = JCHColorGlobalBackground;
        seperatorView.clipsToBounds = NO;
        
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
#if MMR_TAKEOUT_VERSION
            make.top.equalTo(takeoutContainerView.mas_bottom);
#else
            make.top.equalTo(withoutSKUContainerView.mas_bottom);
#endif
            
            make.left.equalTo(self.view.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kStandardTopMargin);
        }];
        
        UIView *topSeperatorLine = [JCHUIFactory createSeperatorLine:0];
        [seperatorView addSubview:topSeperatorLine];
        [topSeperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperatorView.mas_top).with.offset(-kSeparateLineWidth);
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        UIView *bottomSeperatorLine = [JCHUIFactory createSeperatorLine:0];
        [seperatorView addSubview:bottomSeperatorLine];
        [bottomSeperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(seperatorView.mas_bottom);
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        productStatusView = [[[JCHSwitchLabelView alloc] initWithFrame:CGRectZero] autorelease];
        productStatusView.titleLabel.text = @"菜品启用";
        [productStatusView setBottomLineHidden:YES];
        [self.backgroundScrollView addSubview:productStatusView];
        
        if (self.productType == kJCHProductTypeAddProduct) {
            productStatusView.switchButton.on = YES;
        } else if (self.productType == kJCHProductTypeModifyProduct) {
            productStatusView.switchButton.on = !self.productRecord.goods_hiden_flag;
        } else {
            // pass
        }
        
        [productStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(seperatorView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 备注
    {
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorView];
        seperatorView.backgroundColor = JCHColorGlobalBackground;
        seperatorView.clipsToBounds = NO;
        
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(productStatusView.mas_bottom);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kStandardTopMargin);
        }];
        
        UIView *topSeperatorLine = [JCHUIFactory createSeperatorLine:0];
        [seperatorView addSubview:topSeperatorLine];
        [topSeperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperatorView.mas_top).with.offset(-kSeparateLineWidth);
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        UIView *bottomSeperatorLine = [JCHUIFactory createSeperatorLine:0];
        [seperatorView addSubview:bottomSeperatorLine];
        [bottomSeperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(seperatorView.mas_bottom);
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        CGFloat remarkTextViewHeight = 40.0f;
        remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, remarkTextViewHeight)] autorelease];
        [self.backgroundScrollView addSubview:remarkTextView];
        
        remarkTextView.delegate = self;
        remarkTextView.textColor = JCHColorMainBody;
        remarkTextView.font = textFont;
        remarkTextView.placeholder = @"添加备注信息";
        remarkTextView.placeholderColor = UIColorFromRGB(0xd5d5d5);
        remarkTextView.isAutoHeight = YES;
        remarkTextView.minHeight = remarkTextViewHeight;
        
        [remarkTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(remarkTextViewHeight);
            make.top.equalTo(seperatorView.mas_bottom);
        }];
    }
    
    {
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:CGRectGetWidth(self.backgroundScrollView.frame) - kStandardLeftMargin];
        [self.backgroundScrollView addSubview:seperatorView];
        seperatorView.backgroundColor = JCHColorGlobalBackground;
        
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(remarkTextView.mas_bottom);
            make.left.equalTo(self.backgroundScrollView.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(32.0);
        }];
        
        UIView *topSeperatorLine = [JCHUIFactory createSeperatorLine:0];
        [seperatorView addSubview:topSeperatorLine];
        [topSeperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperatorView.mas_top).with.offset(-kSeparateLineWidth);
            make.left.equalTo(self.view.mas_left).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        UIView *bottomGrayPlaceholderView = [JCHUIFactory createSeperatorLine:0];
        [self.backgroundScrollView addSubview:bottomGrayPlaceholderView];
        bottomGrayPlaceholderView.backgroundColor = JCHColorGlobalBackground;
        
        [bottomGrayPlaceholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(seperatorView.mas_bottom);
            make.height.mas_equalTo(180);
        }];
        
        [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(seperatorView);
        }];
    }
    
    
    
    return;
}

- (void)restoreUIStatus
{
    if (currentProductMode == kProductWithSKU) {
        categoryArrowTapView.detailLabel.text = self.currentCategoryRecord.categoryName;
        nameTextView.text = self.productRecord.goods_name;
        unitArrowTapView.detailLabel.text = self.currentUnitRecord.unitName;
        
        remarkTextView.text = self.productRecord.goods_memo;
        traderCodeTextField.text = self.productRecord.goods_merchant_code;
    } else if (currentProductMode == kProductWithoutSKU) {
        categoryArrowTapView.detailLabel.text = self.currentCategoryRecord.categoryName;
        nameTextView.text = self.productRecord.goods_name;
        unitArrowTapView.detailLabel.text = self.currentUnitRecord.unitName;
        
        remarkTextView.text = self.productRecord.goods_memo;
        traderCodeTextField.text = self.productRecord.goods_merchant_code;
        
        withoutSKUBarCodeView.textField.text = self.productRecord.goods_bar_code;
        withoutSKUPriceView.textField.text = [NSString stringWithFormat:@"%.2f", self.productRecord.goods_sell_price];
    } else if (currentProductMode == kProductMainUnit) {
        categoryArrowTapView.detailLabel.text = self.currentCategoryRecord.categoryName;
        nameTextView.text = self.productRecord.goods_name;
        unitArrowTapView.detailLabel.text = self.currentUnitRecord.unitName;
        
        remarkTextView.text = self.productRecord.goods_memo;
        traderCodeTextField.text = self.productRecord.goods_merchant_code;
    } else {
        // pass
    }
    
    for (size_t i = 0; i < sizeof(cameraButtonArray) / sizeof(cameraButtonArray[0]); ++i) {
        NSString *imageName = self.productImagesArray[i];
        if (nil != imageName &&
            (NO == [imageName isEqualToString:@""]) &&
            (NO == [imageName isEqualToString:kDefaultCameraButtonImageName])) {
            UIButton *cameraButton = cameraButtonArray[i];
            UIImage *buttonImage = [UIImage imageNamed:[JCHImageUtility getImagePath:imageName]];
            if (nil == buttonImage) {
                buttonImage = self.defaultPlaceholderImage;
            }
            
            [cameraButton setImage:buttonImage forState:UIControlStateNormal];
            cameraButton.hidden = NO;
        }else {
            UIButton *cameraButton = cameraButtonArray[i];
            [cameraButton setImage:self.defaultCameraImage forState:UIControlStateNormal];
            cameraButton.hidden = YES;
        }
    }
    
    for (size_t i = 0; i < sizeof(cameraButtonArray) / sizeof(cameraButtonArray[0]); ++i) {
        NSString *imageName = self.productImagesArray[i];
        if ([imageName isEqualToString:kDefaultCameraButtonImageName]) {
            cameraButtonArray[i].hidden = NO;
            break;
        }
    }
}

//通过观察textView的contentSize的变化来改变其contentOffset使文字垂直居中
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == nameTextView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            UITextView *tv = object;
            CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
            topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
            tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
        }
    }
}

#pragma mark - LoadData
- (void)loadData
{
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    self.allUnitList = [unitService queryAllUnit];
    
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    self.allCategoryList = [categoryService queryAllCategory];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    
    //新建菜品
    if (self.productType == kJCHProductTypeAddProduct)
    {
        self.currentGoodsSKUUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        [skuService queryGoodsSKU:self.currentGoodsSKUUUID skuArray:&record];
        
        if (self.allUnitList.count > 0) {
            self.currentUnitRecord = self.allUnitList[0];
        }
        
        if (self.allCategoryList.count > 0) {
            self.currentCategoryRecord = self.allCategoryList[0];
        }
        
        //如果是添加新菜品，switch的状态都是默认状态
        productStatusView.switchButton.on = YES;
        
        for (size_t i = 0; i < sizeof(cameraButtonArray)/sizeof(cameraButtonArray[0]); ++i) {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
    }
    else //修改菜品
    {
        [skuService queryGoodsSKU:self.productRecord.goods_sku_uuid skuArray:&record];
        self.currentGoodsSKUUUID = self.productRecord.goods_sku_uuid;
        
        for (UnitRecord4Cocoa *unitRecord in self.allUnitList) {
            if ([unitRecord.unitName isEqualToString:self.productRecord.goods_unit]) {
                self.currentUnitRecord = unitRecord;
                break;
            }
        }
        
        for (CategoryRecord4Cocoa *categoryRecord in self.allCategoryList) {
            if ([categoryRecord.categoryName isEqualToString:self.productRecord.goods_type]) {
                self.currentCategoryRecord = categoryRecord;
                break;
            }
        }
        
        // 判断当前菜品模式
        if (YES == self.productRecord.is_multi_unit_enable) {
            currentProductMode = kProductMainUnit;
            selectedProductMode = kProductMainUnit;
        } else {
            if (YES == self.productRecord.sku_hiden_flag) {
                currentProductMode = kProductWithoutSKU;
                selectedProductMode = kProductWithoutSKU;
            } else {
                currentProductMode = kProductWithSKU;
                selectedProductMode = kProductWithSKU;
            }
        }
        
        //如果是修改菜品，switch的状态对应productRecord的记录
        productStatusView.switchButton.on = !self.productRecord.goods_hiden_flag;
        
        // 查询菜品图片
        if (nil != self.productRecord.goods_image_name && (NO == [self.productRecord.goods_image_name isEqualToString:@""])) {
            [self.productImagesArray addObject:self.productRecord.goods_image_name];
        } else {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
        
        if (nil != self.productRecord.goods_image_name2 && (NO == [self.productRecord.goods_image_name2 isEqualToString:@""])) {
            [self.productImagesArray addObject:self.productRecord.goods_image_name2];
        } else {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
        
        if (nil != self.productRecord.goods_image_name3 && (NO == [self.productRecord.goods_image_name3 isEqualToString:@""])) {
            [self.productImagesArray addObject:self.productRecord.goods_image_name3];
        } else {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
        
        if (nil != self.productRecord.goods_image_name4 && (NO == [self.productRecord.goods_image_name4 isEqualToString:@""])) {
            [self.productImagesArray addObject:self.productRecord.goods_image_name4];
        } else {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
        
        if (nil != self.productRecord.goods_image_name5 && (NO == [self.productRecord.goods_image_name5 isEqualToString:@""])) {
            [self.productImagesArray addObject:self.productRecord.goods_image_name5];
        } else {
            [self.productImagesArray addObject:kDefaultCameraButtonImageName];
        }
    }
    
    self.currentSKURecord = record;
    self.skuData = record.skuArray;
    
    //! @todo 处理新建菜品逻辑
    NSString *productUUID = self.productRecord.goods_uuid;
    if (nil == productUUID) {
        productUUID = @"";
    }
    
    // 加载无规格库存
    {
        self.noskuInventoryArray = [self loadNoSKUInventoryData];
    }
    
    // 加载多规格库存
    {
        self.skuInventoryArray = [self loadSKUInventoryData];
        // 对于多规格的情况，需要将查询出的"无规格"记录删除
        NSMutableArray *tempSkuInventoryArray = [[[NSMutableArray alloc] init] autorelease];
        for (JCHBeginInventoryForSKUViewData *record in self.skuInventoryArray) {
            if ([record.skuCombine isEqualToString:@"无规格"]) {
                continue;
            } else {
                [tempSkuInventoryArray addObject:record];
            }
        }
        
        self.skuInventoryArray = tempSkuInventoryArray;
    }
    
    // 加载主辅单位库存
    {
        // 加载unit列表
        self.unitRecordArray = [self loadUnitRecordData:productUUID];
        
        self.unitInventoryArray = [self loadUnitInventoryData];
    }
    
    // 加载SKU售价
    self.skuSalePriceArray = [self loadSKUSalePriceData:productUUID];
    
    // 加载SKU条码
    self.skuBarCodeArray = [self loadSKUBarCodeData:productUUID];
    
    // 加载unit库存
    
    // 加载unit售价
    self.unitSalePriceArray = [self loadUnitSalePriceData:productUUID];
    
    // 加载unit条码
    self.unitBarCodeArray = [self loadUnitBarCodeData:productUUID];
    
    self.productCharactersJSONString = self.productRecord.cuisineProperty;
}

#pragma mark - Save Record
- (void)handleSaveRecord:(id)sender
{
    [self.view endEditing:YES];
    
    if (nameTextView.text == nil ||
        [nameTextView.text isEqualToString:@""]) {
        [self showAlertView:@"请输入您添加的菜品名称"];
        return;
    }
    
    if (unitArrowTapView.detailLabel.text == nil ||
        [unitArrowTapView.detailLabel.text isEqualToString:@""]) {
        [self showAlertView:@"请选择菜品单位"];
        return;
    }
    
    if (categoryArrowTapView.detailLabel.text == nil ||
        [categoryArrowTapView.detailLabel.text isEqualToString:@""]) {
        [self showAlertView:@"请选择菜品分类"];
        return;
    }
    
    {
        if (self.productType == kJCHProductTypeAddProduct) {
            id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
            NSArray *allDishes = [productService queryAllCuisine:YES];
            for (ProductRecord4Cocoa *dish in allDishes) {
                if ([dish.goods_name isEqualToString:nameTextView.text] && [dish.goods_type isEqualToString:categoryArrowTapView.detailLabel.text]) {
                    [self showAlertView:@"该菜品已存在"];
                    return;
                }
            }
        }
    }
    
    if (self.skuData.count == 0 && currentProductMode == kProductWithSKU) {
        [self showAlertView:@"规格启用后请至少添加一种规格"];
        return;
    }
    if (currentProductMode == kProductWithoutSKU &&
        ([withoutSKUPriceView.textField.text isEmptyString] ||
         withoutSKUPriceView.textField.text.doubleValue <= 0.001)) {
            [self showAlertView:@"填写销售价格，出货时更方便"];
            return;
        }
    
    if (currentProductMode == kProductWithSKU) {
        BOOL showAlertFlag = YES;
        for (ProductSalePriceRecord *record in self.skuSalePriceArray) {
            if ([record.productName isEqualToString:@"统一出售价"]) {
                if (record.productPrice.doubleValue >= 0.001) {
                    showAlertFlag = NO;
                    break;
                }
            }
        }
        
        if (YES == showAlertFlag) {
            for (ProductSalePriceRecord *record in self.skuSalePriceArray) {
                if (NO == [record.productName isEqualToString:@"统一出售价"]) {
                    if (record.productPrice.doubleValue <= 0.001) {
                        showAlertFlag = YES;
                        break;
                    } else {
                        showAlertFlag = NO;
                    }
                }
            }
        }
        
        if (YES == showAlertFlag) {
            [self showAlertView:@"填写多规格菜品的单品销售价格，出货时更方便"];
            return;
        }
    }
    
    if (currentProductMode == kProductMainUnit) {
        BOOL showAlertFlag = YES;
        if (YES == showAlertFlag) {
            for (ProductSalePriceRecord *record in self.unitSalePriceArray) {
                if (NO == [record.productName isEqualToString:@"统一出售价"]) {
                    if (record.productPrice.doubleValue <= 0.001) {
                        showAlertFlag = YES;
                        break;
                    } else {
                        showAlertFlag = NO;
                    }
                }
            }
        }
        
        if (YES == showAlertFlag) {
            [self showAlertView:@"填写菜品的主辅单位销售价格，出货时更方便"];
            return;
        }
        
        if (0 == self.unitRecordArray.count) {
            [self showAlertView:@"请设置菜品的辅单位"];
            return;
        }
    }
    
    [MBProgressHUD showHUDWithTitle:@""
                             detail:@"保存中..."
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 保存图片
        [self saveProductImages];
        
        {
            id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
            id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
            NSArray *allProductList = [productService queryAllProduct];
            
            ProductRecord4Cocoa *productRecord = nil;
            if (nil == self.productRecord) {
                productRecord = [[[ProductRecord4Cocoa alloc] init] autorelease];
            } else {
                productRecord = self.productRecord;
            }
            
            productRecord.goods_domain = @"";
            productRecord.goods_name = nameTextView.text ? nameTextView.text : @"?";
            productRecord.goods_type = self.currentCategoryRecord.categoryName;
            if (remarkTextView.text.length > kMaxSaveStringLength) {
                remarkTextView.text = [remarkTextView.text substringWithRange:NSMakeRange(0, kMaxSaveStringLength)];
            }
            productRecord.goods_memo = remarkTextView.text ? remarkTextView.text : @"";
            productRecord.goods_property = @"";
            productRecord.goods_unit = self.currentUnitRecord.unitName;
            productRecord.goods_code = @"";
            productRecord.goods_category_path = @"";
            productRecord.cuisineProperty = self.productCharactersJSONString;
            
            if (currentProductMode == kProductWithoutSKU) {
                productRecord.goods_sell_price = withoutSKUPriceView.textField.text.doubleValue;
            } else if (currentProductMode == kProductWithSKU) {
                for (ProductSalePriceRecord *record in self.skuSalePriceArray) {
                    if ([record.productName isEqualToString:@"统一出售价"]) {
                        productRecord.goods_sell_price = record.productPrice.doubleValue;
                        break;
                    }
                }
            } else if (currentProductMode == kProductMainUnit) {
                for (ProductSalePriceRecord *record in self.unitSalePriceArray) {
                    if ([record.productName isEqualToString:self.currentUnitRecord.unitName]) {
                        productRecord.goods_sell_price = record.productPrice.doubleValue;
                        break;
                    }
                }
            } else {
                
            }
            
            productRecord.goods_currency = @"人民币";
            productRecord.goods_hiden_flag = !productStatusView.switchButton.on;
            
            if (nil != self.productImagesArray[0] &&
                NO == [self.productImagesArray[0] isEqualToString:@""] &&
                NO == [self.productImagesArray[0] isEqualToString:kDefaultCameraButtonImageName]) {
                productRecord.goods_image_name = self.productImagesArray[0];
            }
            
            if (nil != self.productImagesArray[1] &&
                NO == [self.productImagesArray[1] isEqualToString:@""] &&
                NO == [self.productImagesArray[1] isEqualToString:kDefaultCameraButtonImageName]) {
                productRecord.goods_image_name2 = self.productImagesArray[1];
            }
            
            if (nil != self.productImagesArray[2] &&
                NO == [self.productImagesArray[2] isEqualToString:@""] &&
                NO == [self.productImagesArray[2] isEqualToString:kDefaultCameraButtonImageName]) {
                productRecord.goods_image_name3 = self.productImagesArray[2];
            }
            
            if (nil != self.productImagesArray[3] &&
                NO == [self.productImagesArray[3] isEqualToString:@""] &&
                NO == [self.productImagesArray[3] isEqualToString:kDefaultCameraButtonImageName]) {
                productRecord.goods_image_name4 = self.productImagesArray[3];
            }
            
            if (nil != self.productImagesArray[4] &&
                NO == [self.productImagesArray[4] isEqualToString:@""] &&
                NO == [self.productImagesArray[4] isEqualToString:kDefaultCameraButtonImageName]) {
                productRecord.goods_image_name5 = self.productImagesArray[4];
            }
            
            if (currentProductMode == kProductWithoutSKU) {
                productRecord.goods_bar_code = withoutSKUBarCodeView.textField.text ? withoutSKUBarCodeView.textField.text : @"";
            } else if (currentProductMode == kProductWithSKU) {
                for (ProductBarCodeRecord *record in self.skuBarCodeArray) {
                    if ([record.productName isEqualToString:@"主条码"]) {
                        productRecord.goods_bar_code = record.productBarCode;
                        break;
                    }
                }
            } else if (currentProductMode == kProductMainUnit) {
                for (ProductBarCodeRecord *record in self.unitBarCodeArray) {
                    if ([record.productName isEqualToString:self.currentUnitRecord.unitName]) {
                        productRecord.goods_bar_code = record.productBarCode;
                        break;
                    }
                }
            } else {
                
            }
            
            productRecord.goods_merchant_code = traderCodeTextField.text;
            productRecord.goods_sku_uuid = self.currentGoodsSKUUUID;
            
            if (kProductWithSKU == currentProductMode) {
                productRecord.sku_hiden_flag = NO;
                productRecord.is_multi_unit_enable = NO;
            } else if (kProductWithoutSKU == currentProductMode) {
                productRecord.sku_hiden_flag = YES;
                productRecord.is_multi_unit_enable = NO;
            } else if (kProductMainUnit == currentProductMode) {
                productRecord.sku_hiden_flag = YES;
                productRecord.is_multi_unit_enable = YES;
            } else {
                // pass
            }
            
            //更新sku
            id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
            GoodsSKURecord4Cocoa *skuRecord = nil;
            [skuService queryGoodsSKU:self.currentGoodsSKUUUID skuArray:&skuRecord];
            
            //删除该菜品之前的所有skuValue
            for (NSInteger i = 0; i < skuRecord.skuArray.count; i++) {
                NSArray *originalSKUData = [skuRecord.skuArray[i] allValues][0];
                for (SKUValueRecord4Cocoa *skuValueRecord in originalSKUData) {
                    [skuService deleteGoodsSKU:self.currentGoodsSKUUUID skuUUID:skuValueRecord.skuValueUUID];
                }
            }
            
            //增加当前选择的skuValue
            for (NSInteger i = 0; i < self.skuData.count; i++) {
                NSArray *currentSKUData = [self.skuData[i] allValues][0];
                for (SKUValueRecord4Cocoa *skuValueRecord in currentSKUData) {
                    [skuService addGoodsSKU:self.currentGoodsSKUUUID skuUUID:skuValueRecord.skuValueUUID];
                }
            }
            
            
            NSString *productUUID = nil;
            if (self.productType == kJCHProductTypeModifyProduct) {
                productUUID = self.productRecord.goods_uuid;
            } else {
                productUUID = [utilityService generateUUID];
            }
            // 单品成本价
            NSMutableArray *newProductItemList = [NSMutableArray array];
            if (currentProductMode == kProductWithSKU) {
                

                for (ProductSalePriceRecord *productSalePriceRecord in self.skuSalePriceArray) {
                    if ([productSalePriceRecord.productName isEqualToString:@"统一出售价"]) {
                        continue;
                    }
                    
                    ProductItemRecord4Cocoa *price = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
                    
                    NSArray<ProductItemRecord4Cocoa *> *productItemList = self.productRecord.productItemList;
                    for (ProductItemRecord4Cocoa *productItemRecord in productItemList) {
                        if ([JCHTransactionUtility skuUUIDs:productItemRecord.skuUUIDVector isEqualToArray:productSalePriceRecord.recordUUID]) {
                            price = productItemRecord;
                            break;
                        }
                    }
                    
                    price.goodsUUID = productUUID;
                    price.goodsSkuUUID = @"";
                    price.goodsUnitUUID = @"";
                    price.skuUUIDVector = productSalePriceRecord.recordUUID;
                    price.imageName1 = productRecord.goods_image_name;
                    price.imageName2 = productRecord.goods_image_name2;
                    price.imageName3 = productRecord.goods_image_name3;
                    price.imageName4 = productRecord.goods_image_name4;
                    price.imageName5 = productRecord.goods_image_name5;
                    price.itemPrice = productSalePriceRecord.productPrice.doubleValue;
                    
                    for (JCHTakeoutInfoSetViewData *data in self.takeoutInfoRecordArray) {
                        if ([JCHTransactionUtility skuUUIDs:price.skuUUIDVector isEqualToArray:data.skuUUIDVector]) {
                            
                            if (price.takoutRecord) {
                                price.takoutRecord.boxPrice = data.boxPrice;
                                price.takoutRecord.boxNum = data.boxCount;
                            } else {
                                TakeoutProductRecord4Cocoa *takeoutRecord = [[[TakeoutProductRecord4Cocoa alloc] init] autorelease];
                                takeoutRecord.boxPrice = data.boxPrice;
                                takeoutRecord.boxNum = data.boxCount;
                                price.takoutRecord = takeoutRecord;
                            }
                        }
                    }
                    
//                    [productService addOrUpdateProductItem:price];
                    [newProductItemList addObject:price];
                }
                productRecord.productItemList = newProductItemList;
            } else {
                JCHTakeoutInfoSetViewData *data = [self.takeoutInfoRecordArray firstObject];
                if (productRecord.takoutRecord) {
                    productRecord.takoutRecord.boxNum = data.boxCount;
                    productRecord.takoutRecord.boxPrice = data.boxPrice;
                } else {
                    TakeoutProductRecord4Cocoa *takeoutRecord = [[[TakeoutProductRecord4Cocoa alloc] init] autorelease];
                    takeoutRecord.boxPrice = data.boxPrice;
                    takeoutRecord.boxNum = data.boxCount;
                    productRecord.takoutRecord = takeoutRecord;
                }
            }
            
            // 更新菜品
            if (self.productType == kJCHProductTypeModifyProduct)
            {
                productRecord.goods_uuid = self.productRecord.goods_uuid;
                productRecord.goods_category_uuid = self.currentCategoryRecord.categoryUUID;
                productRecord.goods_unit_uuid = self.currentUnitRecord.unitUUID;
                
                // 如果修改了菜品名称，分类，检查修改后的名称与分类是否已存在于数据库中
                if (NO == [self.productRecord.goods_name isEqualToString:productRecord.goods_name] ||
                    NO == [self.productRecord.goods_type isEqualToString:productRecord.goods_type]) {
                    for (ProductRecord4Cocoa *product in allProductList) {
                        if ([product.goods_name isEqualToString:productRecord.goods_name] &&
                            [product.goods_type isEqualToString:productRecord.goods_type]) {
                            [self showDuplicateProductAlert];
                            return;
                        }
                    }
                }
                
                if ([productService updateCuisine:productRecord])
                {
                    [MBProgressHUD hideAllHudsForWindow];
                    [self showAlertView:@"修改菜品失败"];
                } else {
                    [MBProgressHUD hideAllHudsForWindow];
                }
            }
            else
            {
                // 添加新菜品
                // 判断当前的菜品是否已存在
                productRecord.goods_uuid = productUUID;
                productRecord.goods_category_uuid = self.currentCategoryRecord.categoryUUID;
                productRecord.goods_unit_uuid = self.currentUnitRecord.unitUUID;
                
                for (ProductRecord4Cocoa *product in allProductList) {
                    if ([product.goods_name isEqualToString:productRecord.goods_name] &&
                        [product.goods_type isEqualToString:productRecord.goods_type]) {
                        [self showDuplicateProductAlert];
                        return;
                    }
                }
                
                
                TICK;
                int status = [productService addCuisine:productRecord];
                TOCK(@"addProduct");
                if (status) {
                    [MBProgressHUD hideAllHudsForWindow];
                    [self showAlertView:@"添加菜品失败"];
                } else {
                    [MBProgressHUD hideAllHudsForWindow];
                }
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    });
    
    return;
}

- (void)handleBarCodeScanner
{
    JCHBarCodeScannerViewController *scannerViewController = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
    scannerViewController.title = @"扫码";
    WeakSelf;
    scannerViewController.barCodeBlock = ^(NSString *barCode) {
        weakSelf -> withoutSKUBarCodeView.textField.text = barCode;
    };
    [self presentViewController:scannerViewController animated:YES completion:nil];
}

- (void)selectUnit
{
    WeakSelf;
    UnitRecord4Cocoa *fromUnitRecord = self.currentUnitRecord;
    JCHUnitListViewController *unitListViewController = [[[JCHUnitListViewController alloc] initWithType:kJCHUnitListTypeSelect] autorelease];
    unitListViewController.selectUnitRecord = self.currentUnitRecord;
    unitListViewController.sendValueBlock = ^(UnitRecord4Cocoa *selectUnitRecord){
        weakSelf.currentUnitRecord = selectUnitRecord;
        weakSelf -> unitArrowTapView.detailLabel.text = selectUnitRecord.unitName;
        [self handleChangeMainUnit:fromUnitRecord toUnit:selectUnitRecord];
    };
    [self.navigationController pushViewController:unitListViewController animated:YES];
}

- (void)selecetCategory
{
    WeakSelf;
    JCHCategoryListViewController *categoryListViewController = [[[JCHCategoryListViewController alloc] initWithType:kJCHCategoryListTypeSelect] autorelease];
    categoryListViewController.selectCategoryRecord = self.currentCategoryRecord;
    categoryListViewController.sendValueBlock = ^(CategoryRecord4Cocoa *selectCategoryRecord){
        weakSelf.currentCategoryRecord = selectCategoryRecord;
        weakSelf -> categoryArrowTapView.detailLabel.text = selectCategoryRecord.categoryName;
    };
    [self.navigationController pushViewController:categoryListViewController animated:YES];
}

#pragma mark - JCHAddSKUValueFooterViewDelegate
- (void)addItem
{
    if (self.currentSKURecord == nil) {
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *goodsSKURecord = nil;
        [skuService queryGoodsSKU:self.currentGoodsSKUUUID skuArray:&goodsSKURecord];
        self.currentSKURecord = goodsSKURecord;
    }
    
    JCHSKUSelectViewController *skuSelectViewController = [[[JCHSKUSelectViewController alloc] initWithGoodsSKUUUID:self.currentGoodsSKUUUID goodsUUID:self.productRecord.goods_uuid] autorelease];
    [self.navigationController pushViewController:skuSelectViewController animated:YES];
}

- (void)showDuplicateProductAlert
{
    [self showAlertView:@"您添加的菜品已存在"];
    return;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameTextView resignFirstResponder];
}

- (void)handleActionSheetShow:(UIButton *)button
{
    [self.view endEditing:YES];
    currentCameraButtonIndex = button.tag;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                                  buttonTitles:@[@"拍照", @"从手机相册选择"]
                                                redButtonIndex:-1
                                                      delegate:self];
    actionSheet.tag = kActionSheetTypeTakePhoto;
    [actionSheet show];
}

- (void)takePhoto:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; //拍照
    } else if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //相册
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - LCActionSheetDelegate
- (void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kActionSheetTypeChooseProductMode:
        {
            if (buttonIndex < self.productModeTitles.count) {
                enum ProductUnitSKUMode enumSelectedMode = (enum ProductUnitSKUMode)buttonIndex;
                if (currentProductMode == enumSelectedMode) {
                    return;
                }
                
                // 显示模式变更提示
                selectedProductMode = enumSelectedMode;
                [self showProductModeChangeAlert:enumSelectedMode];
            }
        }
            break;
            
        case kActionSheetTypeTakePhoto:
        {
            if ((buttonIndex == 0) || (buttonIndex == 1)) {
                [self takePhoto:buttonIndex];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    //设置image的尺寸
    CGSize imagesize = image.size;
    imagesize.height = 600;
    imagesize.width = 600;
    
    //image = [self imageWithImage:image scaledToSize:imagesize];
    image = [UIImage compressImage:image scaledToSize:imagesize];
    [cameraButtonArray[currentCameraButtonIndex] setImage:image forState:UIControlStateNormal];
    if (sizeof(cameraButtonArray)/sizeof(cameraButtonArray[0]) - 1 != currentCameraButtonIndex) {
        cameraButtonArray[currentCameraButtonIndex + 1].hidden = NO;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (!error) {
        NSLog(@"Image written to photo album");
    } else {
        NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
    }
}

#pragma mark -
#pragma mark 选择菜品模式
- (void)handleChooseProductMode:(id)sender
{
    LCActionSheet *actionSheet = [[[LCActionSheet alloc] initWithTitle:nil
                                                          buttonTitles:self.productModeTitles
                                                        redButtonIndex:-1
                                                              delegate:self] autorelease];
    actionSheet.tag = kActionSheetTypeChooseProductMode;
    [actionSheet show];
    
    return;
}

#pragma mark -
#pragma mark 添加菜品SKU
- (void)handleSetProductSKU:(id)sender
{
    JCHSKUSelectViewController *viewController = [[[JCHSKUSelectViewController alloc] initWithGoodsSKUUUID:nil goodsUUID:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置多规格期初库存
- (void)handleSetSpecificationInventory:(id)sender
{
    if (self.skuInventoryArray.count == 0) {
        [self showAlertView:@"请先添加菜品规格，然后设置菜品规格对应的期初库存"];
        return;
    }
    
    enum SetInitialInventoryOperation operationType = kInitialInventoryCreate;
    if (self.productType == kJCHProductTypeModifyProduct) {
        operationType = kInitialInventoryModify;
    }
    
    JCHSetInitialInventoryViewController *viewController = [[[JCHSetInitialInventoryViewController alloc] initWithType:kInitialInventoryForWithSKU
                                                                                                              mainUnit:self.currentUnitRecord
                                                                                                         inventoryList:self.skuInventoryArray
                                                                                                              unitList:nil
                                                                                                         operationType:operationType] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置主辅单位期初库存
- (void)handleSetMainAuxilaryUnitInventory:(id)sender
{
    enum SetInitialInventoryOperation operationType = kInitialInventoryCreate;
    if (self.productType == kJCHProductTypeModifyProduct) {
        operationType = kInitialInventoryModify;
    }
    
    JCHSetInitialInventoryViewController *viewController = [[[JCHSetInitialInventoryViewController alloc] initWithType:kInitialInventoryForMainUnit
                                                                                                              mainUnit:self.currentUnitRecord
                                                                                                         inventoryList:self.unitInventoryArray
                                                                                                              unitList:self.unitRecordArray
                                                                                                         operationType:operationType] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 无规格菜品设置期初库存
- (void)handleSetWithoutSKUInventory:(id)sender
{
    enum SetInitialInventoryOperation operationType = kInitialInventoryCreate;
    if (self.productType == kJCHProductTypeModifyProduct) {
        operationType = kInitialInventoryModify;
    }
    
    JCHSetInitialInventoryViewController *viewController = [[[JCHSetInitialInventoryViewController alloc] initWithType:kInitialInventoryForWithoutSKU
                                                                                                              mainUnit:self.currentUnitRecord
                                                                                                         inventoryList:self.noskuInventoryArray
                                                                                                              unitList:nil
                                                                                                         operationType:operationType] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置多规格售价
- (void)handleSetSKUBarCode:(id)sender
{
    if (self.skuBarCodeArray.count == 0) {
        [self showAlertView:@"请先添加菜品规格，然后设置菜品规格对应的条码"];
        return;
    }
    
    JCHProductBarCodeViewController *viewController = [[[JCHProductBarCodeViewController alloc] initWithType:kProductBarCodeRecordForWithSKU productList:self.skuBarCodeArray
                                                                                                    mainUnit:self.currentUnitRecord
                                                                                                    unitList:self.unitRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置主辅助单位售价
- (void)handleSetUnitBarCode:(id)sender
{
    JCHProductBarCodeViewController *viewController = [[[JCHProductBarCodeViewController alloc] initWithType:kProductBarCodeRecordForMainUnit productList:self.unitBarCodeArray
                                                                                                    mainUnit:self.currentUnitRecord
                                                                                                    unitList:self.unitRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置多规格售价
- (void)handleSetSKUSalePrice:(id)sender
{
    if (self.skuSalePriceArray.count == 0) {
        [self showAlertView:@"请先添加菜品规格，然后设置菜品规格对应的售价"];
        return;
    }
    
    JCHProductSalePriceViewController *viewController = [[[JCHProductSalePriceViewController alloc] initWithType:kProductSalePriceForWithSKU productList:self.skuSalePriceArray
                                                                                                        mainUnit:self.currentUnitRecord
                                                                                                        unitList:self.unitRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置主辅助单位售价
- (void)handleSetUnitSalePrice:(id)sender
{
    JCHProductSalePriceViewController *viewController = [[[JCHProductSalePriceViewController alloc] initWithType:kProductSalePriceForMainUnit productList:self.unitSalePriceArray
                                                                                                        mainUnit:self.currentUnitRecord
                                                                                                        unitList:self.unitRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置菜品特性
- (void)handleSetProductCharacter
{
    JCHTakeoutDishesCharacterViewController *viewController = [[[JCHTakeoutDishesCharacterViewController alloc] initWithString:self.productCharactersJSONString] autorelease];
    WeakSelf;
    [viewController setSaveCharacterBlock:^(NSString *jsonString) {
        weakSelf.productCharactersJSONString = jsonString;
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 设置外卖信息
- (void)handleSetTakeoutInfo
{
    if (selectedProductMode == kProductWithSKU && self.takeoutInfoRecordArray.count == 0) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未选择规格" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    JCHAddDishesTakeoutInfoViewController *viewController = [[[JCHAddDishesTakeoutInfoViewController alloc] initWithProductSKUMode:(JCHProductSKUMode)selectedProductMode takeoutInfoList:self.takeoutInfoRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 重新布局 无规格/多规格/主辅单位 container
- (void)layoutUnitSKUContainerView:(enum ProductUnitSKUMode)enumMode
{
    switch (enumMode) {
        case kProductWithoutSKU: {
            [withoutSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(2 * kStandardItemHeight);
            }];
            
            [withSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            
            [mainUnitContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
            break;
            
        case kProductWithSKU: {
            [withoutSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            
            [withSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(3 * kStandardItemHeight);
            }];
            
            [mainUnitContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
            break;
            
        case kProductMainUnit: {
            [withoutSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            
            [withSKUContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            
            [mainUnitContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(3 * kStandardItemHeight);
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark 显示菜品模式变更消息
- (void)showProductModeChangeAlert:(enum ProductUnitSKUMode)selectMode
{
    NSString *alertMessage = [NSString stringWithFormat:@"是否切换到【%@】，\n一经修改【%@】数据将全部清除。",
                              self.productModeTitles[selectMode], self.productModeTitles[currentProductMode]];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:alertMessage
                                                        delegate:self
                                               cancelButtonTitle:@"否"
                                               otherButtonTitles:@"是", nil] autorelease];
    [alertView show];
    return;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView
{
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        // 调整UI布局
        [self layoutUnitSKUContainerView:selectedProductMode];
        [self loadTakeoutInfoData];
        currentProductMode = selectedProductMode;
        skuModeProductLabel.detailLabel.text = self.productModeTitles[currentProductMode];
    }
    
    return;
}

#pragma mark -
#pragma mark 添加主辅单位
- (void)handleAddMainUnit:(id)sender
{
    JCHAddMainAuxiliaryUnitViewController *viewController = [[[JCHAddMainAuxiliaryUnitViewController alloc] initWithMainUnit:self.productRecord.goods_uuid
                                                                                                                    mainUnit:self.currentUnitRecord unitArray:self.unitRecordArray] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 无规格期初库存
- (NSArray<JCHBeginInventoryForSKUViewData *> *)loadNoSKUInventoryData
{
    NSArray *allInventory = [self loadSKUInventoryData];
    NSMutableArray<JCHBeginInventoryForSKUViewData *> *inventoryList = [[[NSMutableArray alloc] init] autorelease];
    for (JCHBeginInventoryForSKUViewData *data in allInventory) {
        if ([data.skuCombine isEqualToString:@"无规格"]) {
            [inventoryList addObject:data];
        }
    }
    
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [[[ServiceFactory sharedInstance] warehouseService] queryAllWarehouse];
    for (WarehouseRecord4Cocoa *record in warehouseList) {
        BOOL hasSameWarehouse = NO;
        for (JCHBeginInventoryForSKUViewData *data in inventoryList) {
            if ([data.warehouseName isEqualToString:record.warehouseName]) {
                hasSameWarehouse = YES;
                break;
            }
        }
        
        if (NO == hasSameWarehouse) {
            JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
            inventoryRecord.skuCombine = @"无规格";
            inventoryRecord.price = 0;
            inventoryRecord.count = 0;
            inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
            inventoryRecord.unit = self.productRecord.goods_unit;
            inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
            inventoryRecord.skuUUIDVector = nil;
            inventoryRecord.warehouseUUID = record.warehouseID;
            inventoryRecord.warehouseName = record.warehouseName;
            
            [inventoryList addObject:inventoryRecord];
        }
    }
    
    return inventoryList;
}

#pragma - mark 多规格期初库存
- (NSArray<JCHBeginInventoryForSKUViewData *> *)loadSKUInventoryData
{
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    if (self.skuData.count > 0) { //有规格时才显示对规格期初库存
        NSMutableArray<JCHBeginInventoryForSKUViewData *> *beginningInventoryArray = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *skuValueRecords = [NSMutableArray array];
        for (NSDictionary *dict in self.skuData) {
            [skuValueRecords addObject:[dict allValues][0]];
        }
        
        NSDictionary *dict = [JCHTransactionUtility getTransactionsWithData:skuValueRecords];
        NSArray *skuValueCombineArray = [[dict allValues] firstObject];
        NSArray *skuValueUUIDsArray = [[dict allKeys] firstObject];
        NSInteger skuValueCombineNum = skuValueCombineArray.count;
        
        id<FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        NSArray *beginInventoryArray = nil;
        [financeCalculateService queryProductBeginningInventoryInfo:self.productRecord.goods_uuid inventoryArray:&beginInventoryArray];
        for (NSInteger i = 0; i < skuValueCombineNum; i++) {
            //查到的多规格期初库存数量不为0时，找到对应的record，拿到价格数量
            NSArray *skuInventoryArray = nil;
            if (currentProductMode == kProductWithoutSKU) {
                skuInventoryArray = beginInventoryArray;
            } else if (currentProductMode == kProductWithSKU ) {
                skuInventoryArray = beginInventoryArray;
            } else {
                // 主辅单位
            }
            
            NSString *skuCombine = skuValueCombineArray[i];
            NSArray *skuUUIDVector = skuValueUUIDsArray[i];
            
            for (BeginningInventoryInfoRecord4Cocoa *beginningInventoryInfoRecord in skuInventoryArray) {
                NSMutableArray *skuValueRecords = [NSMutableArray array];
                for (NSDictionary *dict in beginningInventoryInfoRecord.goodsSkuRecord.skuArray) {
                    [skuValueRecords addObject:[dict allValues][0]];
                }
                
                NSDictionary *dict = [JCHTransactionUtility getTransactionsWithData:skuValueRecords];
                NSArray *skuValueCombineArray = [[dict allValues] firstObject];
                
                JCHBeginInventoryForSKUViewData *data = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                data.skuCombine = skuCombine;
                data.unit = @"";
                data.unitDigital = self.currentUnitRecord.unitDecimalDigits;
                data.skuUUIDVector = skuUUIDVector;
                
                if ([[skuValueCombineArray firstObject] isEqualToString:data.skuCombine]) {
                    data.count = beginningInventoryInfoRecord.beginningCount;
                    data.price = beginningInventoryInfoRecord.beginningPrice;
                    data.unit = beginningInventoryInfoRecord.unitName;
                    data.unitUUID = beginningInventoryInfoRecord.unitUUID;
                    data.goodsSKUUUID = beginningInventoryInfoRecord.goodsSkuRecord.goodsSKUUUID;
                    data.warehouseUUID = beginningInventoryInfoRecord.warehouseUUID;
                    
                    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                        if ([data.warehouseUUID isEqualToString:warehouse.warehouseID]) {
                            data.warehouseName = warehouse.warehouseName;
                            break;
                        }
                    }
                }
                
                if (nil == data.goodsSKUUUID) {
                    continue;
                }
                
                [beginningInventoryArray addObject:data];
            }
        }
        
        return beginningInventoryArray;
    } else {
        //无规格时显示无规格期初库存
        id<FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
        NSArray *beginInventoryArray = nil;
        if (nil != self.productRecord.goods_uuid) {
            [financeCalculateService queryProductBeginningInventoryInfo:self.productRecord.goods_uuid
                                                         inventoryArray:&beginInventoryArray];
        }
        
        if (0 == beginInventoryArray.count) {
            NSMutableArray *inventoryList = [[[NSMutableArray alloc] init] autorelease];
            for (WarehouseRecord4Cocoa *record in warehouseList) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = @"无规格";
                inventoryRecord.price = 0;
                inventoryRecord.count = 0;
                inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
                inventoryRecord.unit = self.productRecord.goods_unit;
                inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
                inventoryRecord.skuUUIDVector = nil;
                inventoryRecord.warehouseUUID = record.warehouseID;
                
                for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                    if ([warehouse.warehouseID isEqualToString:inventoryRecord.warehouseUUID]) {
                        inventoryRecord.warehouseName = warehouse.warehouseName;
                    }
                }
                
                [inventoryList addObject:inventoryRecord];
            }
            
            return inventoryList;
        } else {
            NSMutableArray *inventoryList = [[[NSMutableArray alloc] init] autorelease];
            for (BeginningInventoryInfoRecord4Cocoa *record in beginInventoryArray) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = @"无规格";
                inventoryRecord.price = record.beginningPrice;
                inventoryRecord.count = record.beginningCount;
                inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
                inventoryRecord.unit = self.productRecord.goods_unit;
                inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
                inventoryRecord.skuUUIDVector = nil;
                inventoryRecord.warehouseUUID = record.warehouseUUID;
                
                for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                    if ([warehouse.warehouseID isEqualToString:inventoryRecord.warehouseUUID]) {
                        inventoryRecord.warehouseName = warehouse.warehouseName;
                    }
                }
                
                [inventoryList addObject:inventoryRecord];
            }
            
            return inventoryList;
        }
    }
}

#pragma mark -
#pragma mark 加载多规格期初库存
- (NSArray<JCHBeginInventoryForSKUViewData *> *)loadUnitInventoryData
{
    NSArray *beginInventoryArray = nil;
    NSMutableArray<JCHBeginInventoryForSKUViewData *> *inventoryArray = [[[NSMutableArray alloc] init] autorelease];
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    NSArray<UnitRecord4Cocoa *> *allUnitList = [unitService queryAllUnit];
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    WarehouseRecord4Cocoa *defaultWarehouse = nil;
    for (WarehouseRecord4Cocoa *record in warehouseList) {
        if ([record.warehouseID isEqualToString:@"0"]) {
            defaultWarehouse = record;
            break;
        }
    }
    
    NSString *productUUID = self.productRecord.goods_uuid;
    if (nil == productUUID || [productUUID isEqualToString:@""]) {
        productUUID = @"";
    }
    
    id<FinanceCalculateService> financeCalculateService = [[ServiceFactory sharedInstance] financeCalculateService];
    [financeCalculateService queryProductBeginningInventoryInfo:productUUID inventoryArray:&beginInventoryArray];
    for (BeginningInventoryInfoRecord4Cocoa *record in beginInventoryArray) {
        JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
        inventoryRecord.skuCombine = record.unitName;
        inventoryRecord.price = record.beginningPrice;
        inventoryRecord.count = record.beginningCount;
        inventoryRecord.unitDigital = 0;
        inventoryRecord.unit = record.unitName;
        inventoryRecord.unitUUID = record.unitUUID;
        inventoryRecord.skuUUIDVector = record.skuUUIDVector;
        
        for (UnitRecord4Cocoa *unit in allUnitList) {
            if ([unit.unitUUID isEqualToString:inventoryRecord.unitUUID]) {
                inventoryRecord.unitDigital = unit.unitDecimalDigits;
                inventoryRecord.unit = unit.unitName;
                inventoryRecord.skuCombine = unit.unitName;
                break;
            }
        }
        
        inventoryRecord.warehouseUUID = record.warehouseUUID;
        for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
            if ([warehouse.warehouseID isEqualToString:inventoryRecord.warehouseUUID]) {
                inventoryRecord.warehouseName = warehouse.warehouseName;
                break;
            }
        }
        
        [inventoryArray addObject:inventoryRecord];
    }
    
    // 检查是否有主单位期初库存
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        BOOL hasMainUnitInventory = NO;
        for (JCHBeginInventoryForSKUViewData *inventory in inventoryArray) {
            if ([inventory.skuCombine isEqualToString:self.currentUnitRecord.unitName] &&
                [inventory.warehouseName isEqualToString:warehouse.warehouseName]) {
                hasMainUnitInventory = YES;
                break;
            }
        }
        
        if (NO == hasMainUnitInventory) {
            JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
            inventoryRecord.skuCombine = self.currentUnitRecord.unitName;
            inventoryRecord.price = 0;
            inventoryRecord.count = 0;
            inventoryRecord.unitDigital = self.currentUnitRecord.unitDecimalDigits;
            inventoryRecord.unit = self.currentUnitRecord.unitName;
            inventoryRecord.unitUUID = self.currentUnitRecord.unitUUID;
            inventoryRecord.skuUUIDVector = @[];
            inventoryRecord.warehouseUUID = warehouse.warehouseID;
            inventoryRecord.warehouseName = warehouse.warehouseName;
            [inventoryArray addObject:inventoryRecord];
        }
    }
    
    // 检查辅单位期初库存是否存在
    for (ProductUnitRecord *unit in self.unitRecordArray) {
        for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
            BOOL findRecord = NO;
            for (JCHBeginInventoryForSKUViewData *inventory in inventoryArray) {
                if ([inventory.unit isEqualToString:unit.unitRecord.unitName] &&
                    [inventory.warehouseName isEqualToString:warehouse.warehouseName]) {
                    findRecord = YES;
                    break;
                }
            }
            
            if (NO == findRecord) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = unit.unitRecord.unitName;
                inventoryRecord.price = 0;
                inventoryRecord.count = 0;
                inventoryRecord.unitDigital = unit.unitRecord.unitDecimalDigits;
                inventoryRecord.unit = unit.unitRecord.unitName;
                inventoryRecord.unitUUID = unit.unitRecord.unitUUID;
                inventoryRecord.skuUUIDVector = @[];
                inventoryRecord.warehouseUUID = warehouse.warehouseID;
                inventoryRecord.warehouseName = warehouse.warehouseName;
                [inventoryArray addObject:inventoryRecord];
            }
        }
    }
    
    // 将默认仓库的主单位菜品放在第一位
    if (inventoryArray.count > 0) {
        for (JCHBeginInventoryForSKUViewData *data in inventoryArray) {
            if ([data.warehouseUUID isEqualToString:@"0"] &&
                [data.unitUUID isEqualToString:self.currentUnitRecord.unitUUID]) {
                [inventoryArray removeObject:data];
                [inventoryArray insertObject:data atIndex:0];
                break;
            }
        }
    }
    
    return inventoryArray;
}

#pragma - mark 多规格售价
- (NSArray<ProductSalePriceRecord *> *)loadSKUSalePriceData:(NSString *)productUUID
{
    NSMutableArray *tempSkuInventoryArray = [NSMutableArray arrayWithArray:self.skuInventoryArray];
    if (0 == tempSkuInventoryArray.count) {
        NSMutableArray *skuValueRecords = [NSMutableArray array];
        for (NSDictionary *dict in self.skuData) {
            [skuValueRecords addObject:[dict allValues][0]];
        }
        
        id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
        NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
        
        NSDictionary *dict = [JCHTransactionUtility getTransactionsWithData:skuValueRecords];
        NSArray *skuValueCombineArray = [[dict allValues] firstObject];
        NSArray *skuValueUUIDsArray = [[dict allKeys] firstObject];
        NSInteger skuValueCombineNum = skuValueCombineArray.count;
        
        // 增加新添加sku组合对应的库存，条码，售价
        for (NSInteger i = 0; i < skuValueCombineNum; i++) {
            BOOL findSame = NO;
            for (NSInteger j = 0; j < self.skuInventoryArray.count; ++j) {
                if (YES == [JCHTransactionUtility skuUUIDs:skuValueUUIDsArray[i] isEqualToArray:self.skuInventoryArray[j].skuUUIDVector]) {
                    findSame = YES;
                    break;
                }
            }
            
            if (NO == findSame) {
                for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                    JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                    inventoryRecord.skuCombine = skuValueCombineArray[i];
                    inventoryRecord.price = 0;
                    inventoryRecord.count = 0;
                    inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
                    inventoryRecord.unit = self.productRecord.goods_unit;
                    inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
                    inventoryRecord.warehouseName = warehouse.warehouseName;
                    inventoryRecord.warehouseUUID = warehouse.warehouseID;
                    inventoryRecord.skuUUIDVector = skuValueUUIDsArray[i];
                    [tempSkuInventoryArray addObject:inventoryRecord];
                }
            }
        }
    }
    
    
    NSMutableArray<ProductSalePriceRecord *> *salePriceArray = [[[NSMutableArray alloc] init] autorelease];
    ProductSalePriceRecord *record = [[[ProductSalePriceRecord alloc] init] autorelease];
    record.recordUUID = nil;
    record.productPrice = [NSString stringWithFormat:@"%.2f", self.productRecord.goods_sell_price];
    record.productName = @"统一出售价";
    [salePriceArray addObject:record];
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray<ProductItemRecord4Cocoa *> *productList = [productService querySkuGoodsItem:productUUID];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    for (ProductItemRecord4Cocoa *product in productList) {
        GoodsSKURecord4Cocoa *skuRecord = nil;
        [skuService queryGoodsSKU:product.goodsSkuUUID skuArray:&skuRecord];
        
        NSMutableArray *skuValueArray = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *value in skuRecord.skuArray) {
            SKUValueRecord4Cocoa *skuValue = value.allValues.firstObject[0];
            [skuValueArray addObject:skuValue.skuValueUUID];
        }
        
        product.skuUUIDVector = skuValueArray;
    }
    
    for (JCHBeginInventoryForSKUViewData *data in tempSkuInventoryArray) {
        ProductSalePriceRecord *price = [[[ProductSalePriceRecord alloc] init] autorelease];
        price.productName = data.skuCombine;
        price.recordUUID = data.skuUUIDVector;
        price.productPrice = @"0.00";
        for (ProductItemRecord4Cocoa *product in productList) {
            if (YES == [JCHTransactionUtility skuUUIDs:data.skuUUIDVector isEqualToArray:product.skuUUIDVector]) {
                price.productPrice = [NSString stringWithFormat:@"%.2f", product.itemPrice];
                break;
            }
        }
        
        BOOL findSame = NO;
        for (ProductSalePriceRecord *item in salePriceArray) {
            if ([item.productName isEqualToString:price.productName]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            [salePriceArray addObject:price];
        }
    }
    
    return salePriceArray;
}

#pragma - mark 多规格条码
- (NSArray<ProductBarCodeRecord *> *)loadSKUBarCodeData:(NSString *)productUUID
{
    NSMutableArray<ProductBarCodeRecord *> *barCodeArray = [[[NSMutableArray alloc] init] autorelease];
    ProductBarCodeRecord *record = [[[ProductBarCodeRecord alloc] init] autorelease];
    record.recordUUID = @[];
    record.productName = @"主条码";
    record.productBarCode = self.productRecord.goods_bar_code ? self.productRecord.goods_bar_code : @"";
    [barCodeArray addObject:record];
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray<ProductItemRecord4Cocoa *> *productList = [productService querySkuGoodsItem:productUUID];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    for (ProductItemRecord4Cocoa *product in productList) {
        GoodsSKURecord4Cocoa *skuRecord = nil;
        [skuService queryGoodsSKU:product.goodsSkuUUID skuArray:&skuRecord];
        
        NSMutableArray *skuValueArray = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *value in skuRecord.skuArray) {
            SKUValueRecord4Cocoa *skuValue = value.allValues.firstObject[0];
            [skuValueArray addObject:skuValue.skuValueUUID];
        }
        
        product.skuUUIDVector = skuValueArray;
    }
    
    for (JCHBeginInventoryForSKUViewData *data in self.skuInventoryArray) {
        ProductBarCodeRecord *barCode = [[[ProductBarCodeRecord alloc] init] autorelease];
        barCode.productName = data.skuCombine;
        barCode.recordUUID = data.skuUUIDVector;
        
        for (ProductItemRecord4Cocoa *product in productList) {
            if (YES == [JCHTransactionUtility skuUUIDs:data.skuUUIDVector isEqualToArray:product.skuUUIDVector]) {
                barCode.productBarCode = product.itemBarCode;
                break;
            }
        }
        
        BOOL findSame = NO;
        for (ProductBarCodeRecord *item in barCodeArray) {
            if ([item.productName isEqualToString:barCode.productName]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            [barCodeArray addObject:barCode];
        }
    }
    
    return barCodeArray;
}

#pragma mark -
#pragma mark 加载unit列表
- (NSMutableArray *)loadUnitRecordData:(NSString *)productUUID
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray<ProductUnitRecord4Cocoa *> *unitList = @[];
    if (NO == [productUUID isEqualToString:@""]) {
        unitList = [productService queryGoodsUnit:productUUID];
    }
    
    NSArray<UnitRecord4Cocoa *> *allUnits = [[[ServiceFactory sharedInstance] unitService] queryAllUnit];
    
    NSMutableArray<ProductUnitRecord *> *productUnitList = [[[NSMutableArray alloc] init] autorelease];
    for (ProductUnitRecord4Cocoa *unit in unitList) {
        ProductUnitRecord *record = [[[ProductUnitRecord alloc] init] autorelease];
        record.recordUUID = nil;
        record.convertRatio = unit.ratio;
        record.unitRecord = nil;
        
        for (UnitRecord4Cocoa *item in allUnits) {
            if ([item.unitUUID isEqualToString:unit.unitUUID]) {
                record.unitRecord = item;
                break;
            }
        }
        
        [productUnitList addObject:record];
    }
    
    return productUnitList;
}

#pragma mark -
#pragma mark 加载主辅单位售价
- (NSMutableArray *)loadUnitSalePriceData:(NSString *)productUUID
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSMutableArray<ProductSalePriceRecord *> *allProductUnitList = [[[NSMutableArray alloc] init] autorelease];
    NSArray<ProductItemRecord4Cocoa *> *unitProductList = [productService queryUnitGoodsItem:productUUID];
    BOOL hasMainUnitRecord = NO;
    for (ProductItemRecord4Cocoa *record in unitProductList) {
        if ([record.unitName isEqualToString:self.currentUnitRecord.unitName]) {
            hasMainUnitRecord = YES;
            break;
        }
    }
    
    if (NO == hasMainUnitRecord) {
        ProductSalePriceRecord *price = [[[ProductSalePriceRecord alloc] init] autorelease];
        price.recordUUID = self.currentUnitRecord.unitName;
        price.productPrice = [NSString stringWithFormat:@"%.2f", self.productRecord.goods_sell_price];
        price.productName = self.currentUnitRecord.unitName;
        [allProductUnitList addObject:price];
    }
    
    for (ProductItemRecord4Cocoa *unit in unitProductList) {
        ProductSalePriceRecord *record = [[[ProductSalePriceRecord alloc] init] autorelease];
        record.recordUUID = unit.unitName;
        record.productPrice = [NSString stringWithFormat:@"%.2f", unit.itemPrice];
        record.productName = unit.unitName;
        
        [allProductUnitList addObject:record];
    }
    
    return allProductUnitList;
}

#pragma mark -
#pragma mark 加载主辅单位条码
- (NSMutableArray *)loadUnitBarCodeData:(NSString *)productUUID
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSMutableArray<ProductBarCodeRecord *> *productUnitList = [[[NSMutableArray alloc] init] autorelease];
    ProductBarCodeRecord *record = [[[ProductBarCodeRecord alloc] init] autorelease];
    record.recordUUID = @[];
    
    if (nil != self.productRecord) {
        record.productName = self.productRecord.goods_unit;
    } else {
        record.productName = self.currentUnitRecord.unitName;
    }
    
    record.productBarCode = self.productRecord.goods_bar_code ? self.productRecord.goods_bar_code : @"";
    [productUnitList addObject:record];
    
    NSArray<ProductItemRecord4Cocoa *> *unitProductList = [productService queryUnitGoodsItem:productUUID];
    for (ProductItemRecord4Cocoa *unit in unitProductList) {
        ProductBarCodeRecord *record = [[[ProductBarCodeRecord alloc] init] autorelease];
        record.recordUUID = unit.goodsUnitUUID;
        record.productName = unit.unitName;
        record.productBarCode = unit.itemBarCode;
        
        [productUnitList addObject:record];
    }
    
    return productUnitList;
}

#pragma mark -
#pragma mark 加载外卖信息
- (void)loadTakeoutInfoData
{
    NSMutableArray *takeoutInfoDataList = [NSMutableArray array];
    //新建菜品
    
    if(selectedProductMode == kProductWithoutSKU) {
        // 无规格
        JCHTakeoutInfoSetViewData *data = [[[JCHTakeoutInfoSetViewData alloc] init] autorelease];
        data.skuName = @"";
        data.boxPrice = 0;
        data.boxCount = 0;
        data.skuUUIDVector = @[];
        [self restoreTakeoutData:data];
        [takeoutInfoDataList addObject:data];
    } else if (selectedProductMode == kProductWithSKU) {
        // 多规格
        
        NSDictionary *dict = [self.skuData firstObject];
        NSArray *skuValueList = [[dict allValues] firstObject];
        
        for (SKUValueRecord4Cocoa *skuValueRecord in skuValueList) {
            JCHTakeoutInfoSetViewData *data = [[[JCHTakeoutInfoSetViewData alloc] init] autorelease];
            data.skuName = skuValueRecord.skuValue;
            data.boxPrice = 0;
            data.boxCount = 0;
            data.skuUUIDVector = @[skuValueRecord.skuValueUUID];
            [self restoreTakeoutData:data];
            [takeoutInfoDataList addObject:data];
        }
    }
 
    
    self.takeoutInfoRecordArray = takeoutInfoDataList;
}

- (void)restoreTakeoutData:(JCHTakeoutInfoSetViewData *)currentData
{
    if (self.takeoutInfoRecordArray) {
        for (JCHTakeoutInfoSetViewData *data in self.takeoutInfoRecordArray) {
            if ([JCHTransactionUtility skuUUIDs:data.skuUUIDVector isEqualToArray:currentData.skuUUIDVector]) {
                currentData.boxPrice = data.boxPrice;
                currentData.boxCount = data.boxCount;
            }
        }
    } else {
        
        if (self.productRecord) {
            if (self.productRecord.sku_hiden_flag) {
                currentData.boxPrice = self.productRecord.takoutRecord.boxPrice;
                currentData.boxCount = self.productRecord.takoutRecord.boxNum;
            } else {
                NSArray<ProductItemRecord4Cocoa *> *productItemList = self.productRecord.productItemList;
                
                for (ProductItemRecord4Cocoa *productItemRecord in productItemList) {
                    if ([JCHTransactionUtility skuUUIDs:currentData.skuUUIDVector isEqualToArray:productItemRecord.skuUUIDVector]) {
                        currentData.boxPrice = productItemRecord.takoutRecord.boxPrice;
                        currentData.boxCount = productItemRecord.takoutRecord.boxNum;
                    }
                }
            }
        }
    }
}

- (void)refreshSKUPriceBarCodeInventory
{
    NSMutableArray *tempSkuInventoryArray = [NSMutableArray array];
    NSMutableArray *tempSkuBarCodeArray = [NSMutableArray array];
    NSMutableArray *tempSkuSalePriceArray = [NSMutableArray array];
    
    NSMutableArray *skuValueRecords = [NSMutableArray array];
    for (NSDictionary *dict in self.skuData) {
        [skuValueRecords addObject:[dict allValues][0]];
    }
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    NSDictionary *dict = [JCHTransactionUtility getTransactionsWithData:skuValueRecords];
    NSArray *skuValueCombineArray = [[dict allValues] firstObject];
    NSArray *skuValueUUIDsArray = [[dict allKeys] firstObject];
    NSInteger skuValueCombineNum = skuValueCombineArray.count;
    
    for (NSInteger i = 0; i < skuValueCombineNum; i++) {
        for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
            BOOL findInventoryForWarehouse = NO;
            for (JCHBeginInventoryForSKUViewData *inventory in self.skuInventoryArray) {
                if ([JCHTransactionUtility skuUUIDs:inventory.skuUUIDVector isEqualToArray:skuValueUUIDsArray[i]]) {
                    if ([inventory.warehouseName isEqualToString:warehouse.warehouseName]) {
                        findInventoryForWarehouse = YES;
                        break;
                    }
                }
            }
            
            if (NO == findInventoryForWarehouse) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = skuValueCombineArray[i];
                inventoryRecord.price = 0;
                inventoryRecord.count = 0;
                inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
                inventoryRecord.unit = self.productRecord.goods_unit;
                inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
                inventoryRecord.warehouseName = warehouse.warehouseName;
                inventoryRecord.warehouseUUID = warehouse.warehouseID;
                inventoryRecord.skuUUIDVector = skuValueUUIDsArray[i];
                [tempSkuInventoryArray addObject:inventoryRecord];
            }
        }
    }
    
    self.skuInventoryArray = tempSkuInventoryArray;
    
    // 增加新添加sku组合对应的库存
    for (NSInteger i = 0; i < skuValueCombineNum; i++) {
        BOOL findSame = NO;
        for (NSInteger j = 0; j < self.skuInventoryArray.count; ++j) {
            if (YES == [JCHTransactionUtility skuUUIDs:skuValueUUIDsArray[i] isEqualToArray:self.skuInventoryArray[j].skuUUIDVector]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = skuValueCombineArray[i];
                inventoryRecord.price = 0;
                inventoryRecord.count = 0;
                inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
                inventoryRecord.unit = self.productRecord.goods_unit;
                inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
                inventoryRecord.warehouseName = warehouse.warehouseName;
                inventoryRecord.warehouseUUID = warehouse.warehouseID;
                inventoryRecord.skuUUIDVector = skuValueUUIDsArray[i];
                [tempSkuInventoryArray addObject:inventoryRecord];
            }
        }
    }
    
    // 增加新添加sku组合对应的条码
    for (NSInteger i = 0; i < skuValueCombineNum; i++) {
        ProductBarCodeRecord *barCode = nil;
        for (NSInteger j = 0; j < self.skuBarCodeArray.count; ++j) {
            if (YES == [JCHTransactionUtility skuUUIDs:skuValueUUIDsArray[i] isEqualToArray:self.skuBarCodeArray[j].recordUUID]) {
                barCode = self.skuBarCodeArray[j];
                break;
            }
        }
        
        if (nil == barCode) {
            barCode = [[[ProductBarCodeRecord alloc] init] autorelease];
            barCode.recordUUID = skuValueUUIDsArray[i];
            barCode.productName = skuValueCombineArray[i];
            barCode.productBarCode = @"";
        }
        
        [tempSkuBarCodeArray addObject:barCode];
    }
    
    // 补上主条码
    for (ProductBarCodeRecord *barCodeRecord in self.skuBarCodeArray) {
        if ([barCodeRecord.productName isEqualToString:@"主条码"]) {
            [tempSkuBarCodeArray insertObject:barCodeRecord atIndex:0];
        }
    }
    
    // 增加新添加sku组合对应的售价
    for (NSInteger i = 0; i < skuValueCombineNum; i++) {
        ProductSalePriceRecord *findRecord = nil;
        for (NSInteger j = 0; j < self.skuSalePriceArray.count; ++j) {
            if (YES == [JCHTransactionUtility skuUUIDs:skuValueUUIDsArray[i] isEqualToArray:self.skuSalePriceArray[j].recordUUID]) {
                findRecord = self.skuSalePriceArray[j];
                break;
            }
        }
        
        if (nil == findRecord) {
            findRecord = [[[ProductSalePriceRecord alloc] init] autorelease];
            findRecord.recordUUID = skuValueUUIDsArray[i];
            findRecord.productPrice = @"0.00";
            findRecord.productName = skuValueCombineArray[i];
        }
        
        [tempSkuSalePriceArray addObject:findRecord];
    }
    
    // 补上统一出售价
    for (ProductSalePriceRecord *price in self.skuSalePriceArray) {
        if ([price.productName isEqualToString:@"统一出售价"]) {
            [tempSkuSalePriceArray insertObject:price atIndex:0];
        }
    }
    
    for (NSInteger i = 0; i < self.skuInventoryArray.count; i++) {
        BOOL findSame = NO;
        for (NSInteger j = 0; j < skuValueCombineNum; ++j) {
            if (YES == [JCHTransactionUtility skuUUIDs:skuValueUUIDsArray[j] isEqualToArray:self.skuInventoryArray[i].skuUUIDVector]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            id skuValueUUID = self.skuInventoryArray[i].skuUUIDVector;
            for (ProductBarCodeRecord *record in tempSkuBarCodeArray) {
                if (record.recordUUID == skuValueUUID) {
                    [tempSkuBarCodeArray removeObject:record];
                    break;
                }
            }
            
            for (ProductSalePriceRecord *record in tempSkuSalePriceArray) {
                if (record.recordUUID == skuValueUUID) {
                    [tempSkuSalePriceArray removeObject:record];
                    break;
                }
            }
            
            while (YES) {
                JCHBeginInventoryForSKUViewData *viewData = nil;
                for (JCHBeginInventoryForSKUViewData *record in tempSkuInventoryArray) {
                    if (record.skuUUIDVector == skuValueUUID) {
                        viewData= record;
                        break;
                    }
                }
                
                if (nil == viewData) {
                    break;
                } else {
                    [tempSkuInventoryArray removeObject:viewData];
                }
            }
        }
    }
    
    // 去除已删除的sku组合对应的库存，条码，售价
    self.skuBarCodeArray = tempSkuBarCodeArray;
    self.skuSalePriceArray = tempSkuSalePriceArray;
    
    
    // 判断是否已设置条码
    BOOL hasSetBarCode = NO;
    for (ProductBarCodeRecord *record in self.skuBarCodeArray) {
        if (nil != record.productBarCode &&
            NO == [record.productBarCode isEqualToString:@""]) {
            hasSetBarCode = YES;
            break;
        }
    }
    
    if (YES == hasSetBarCode) {
        withSKUBarCodeView.detailLabel.text = @"已录入";
    } else {
        withSKUBarCodeView.detailLabel.text = @"";
    }
    
    // 规格
    NSString *withSkuText = @"";
    for (NSInteger i = 0; i < self.skuData.count; i++) {
        NSArray *currentSKUData = [self.skuData[i] allValues][0];
        for (SKUValueRecord4Cocoa *skuValueRecord in currentSKUData) {
            if ([withSkuText isEqualToString:@""]) {
                withSkuText = [NSString stringWithFormat:@"%@", skuValueRecord.skuValue];
            } else {
                withSkuText = [NSString stringWithFormat:@"%@/%@", withSkuText, skuValueRecord.skuValue];
            }
        }
    }
    
    withSKUSpecificationView.detailLabel.text = withSkuText;
    
    // 售价
    BOOL hasSetSalePrice = NO;
    for (ProductSalePriceRecord *record in self.skuSalePriceArray) {
        if (NO == [record.productPrice isEqualToString:@""] &&
            0 != record.productPrice.doubleValue) {
            hasSetSalePrice = YES;
            break;
        }
    }
    
    if (YES == hasSetSalePrice) {
        withSKUPriceView.detailLabel.text = @"已录入";
    } else {
        withSKUPriceView.detailLabel.text = @"";
    }
    
    
    // 多规格期初库存
    BOOL hasSetSKUInventory = NO;
    for (JCHBeginInventoryForSKUViewData *record in self.skuInventoryArray) {
        if (record.price != 0 && record.count != 0) {
            hasSetSKUInventory = YES;
            break;
        }
    }
    
    if (YES == hasSetSKUInventory) {
        withSKUInventoryView.detailLabel.text = @"已录入";
    } else {
        withSKUInventoryView.detailLabel.text = @"";
    }
    
    // 无规格期初库存
    BOOL hasSetNoSKUInventory = NO;
    for (JCHBeginInventoryForSKUViewData *record in self.noskuInventoryArray) {
        if (record.price != 0 && record.count != 0) {
            hasSetNoSKUInventory = YES;
            break;
        }
    }
    
    if (YES == hasSetNoSKUInventory) {
        withoutSKUInventoryView.detailLabel.text = @"已录入";
    } else {
        withoutSKUInventoryView.detailLabel.text = @"";
    }
    
    return;
}

- (void)refreshUnitPriceBarCodeInventory
{
    NSMutableArray *unitInventoryArray = [[[NSMutableArray alloc] initWithArray:self.unitInventoryArray] autorelease];
    NSMutableArray *unitSalePriceArray = [[[NSMutableArray alloc] initWithArray:self.unitSalePriceArray] autorelease];
    NSMutableArray *unitBarCodeArray = [[[NSMutableArray alloc] initWithArray:self.unitBarCodeArray] autorelease];
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    if (0 == unitInventoryArray.count) {
        for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
            JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
            inventoryRecord.skuCombine = self.currentUnitRecord.unitName;
            inventoryRecord.price = 0;
            inventoryRecord.count = 0;
            inventoryRecord.unitDigital = self.currentUnitRecord.unitDecimalDigits;
            inventoryRecord.unit = self.currentUnitRecord.unitName;
            inventoryRecord.unitUUID = self.currentUnitRecord.unitUUID;
            inventoryRecord.skuUUIDVector = nil;
            inventoryRecord.warehouseName = warehouse.warehouseName;
            inventoryRecord.warehouseUUID = warehouse.warehouseID;
            [unitInventoryArray addObject:inventoryRecord];
        }
    }
    
    if (0 == unitSalePriceArray.count) {
        ProductSalePriceRecord *price = [[[ProductSalePriceRecord alloc] init] autorelease];
        price.recordUUID = self.currentUnitRecord.unitName;
        price.productPrice = @"0.00";
        price.productName = self.currentUnitRecord.unitName;
        [unitSalePriceArray addObject:price];
    }
    
    if (0 == unitBarCodeArray.count) {
        ProductBarCodeRecord *barCode = [[[ProductBarCodeRecord alloc] init] autorelease];
        barCode.recordUUID = self.currentUnitRecord.unitName;
        barCode.productName = self.currentUnitRecord.unitName;
        barCode.productBarCode = @"";
        [unitBarCodeArray addObject:barCode];
    }
    
    for (ProductUnitRecord *record in self.unitRecordArray) {
        BOOL findSame = NO;
        for (ProductSalePriceRecord *salePrice in self.unitSalePriceArray) {
            if ([salePrice.productName isEqualToString:record.unitRecord.unitName]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
                inventoryRecord.skuCombine = record.unitRecord.unitName;
                inventoryRecord.price = 0;
                inventoryRecord.count = 0;
                inventoryRecord.unitDigital = record.unitRecord.unitDecimalDigits;
                inventoryRecord.unit = record.unitRecord.unitName;
                inventoryRecord.unitUUID = record.unitRecord.unitUUID;
                inventoryRecord.skuUUIDVector = nil;
                inventoryRecord.warehouseName = warehouse.warehouseName;
                inventoryRecord.warehouseUUID = warehouse.warehouseID;
                [unitInventoryArray addObject:inventoryRecord];
            }
            
            ProductSalePriceRecord *priceRecord = [[[ProductSalePriceRecord alloc] init] autorelease];
            priceRecord.recordUUID = record.unitRecord.unitName;
            priceRecord.productPrice = @"0.00";
            priceRecord.productName = record.unitRecord.unitName;
            [unitSalePriceArray addObject:priceRecord];
            
            ProductBarCodeRecord *barCode = [[[ProductBarCodeRecord alloc] init] autorelease];
            barCode.recordUUID = record.unitRecord.unitName;
            barCode.productName = record.unitRecord.unitName;
            barCode.productBarCode = @"";
            [unitBarCodeArray addObject:barCode];
        }
    }
    
    NSMutableArray *selectedUnitArray = [[[NSMutableArray alloc] init] autorelease];
    for (ProductSalePriceRecord *salePrice in unitSalePriceArray) {
        [selectedUnitArray addObject:salePrice.recordUUID];
    }
    
    for (NSString *unitName in selectedUnitArray) {
        if ([unitName isEqualToString:self.currentUnitRecord.unitName]) {
            continue;
        }
        
        BOOL findSame = NO;
        for (ProductUnitRecord *unit in self.unitRecordArray) {
            if ([unitName isEqualToString:unit.unitRecord.unitName]) {
                findSame = YES;
            }
        }
        
        if (NO == findSame) {
            for (ProductBarCodeRecord *record in unitBarCodeArray) {
                if (record.recordUUID == unitName) {
                    [unitBarCodeArray removeObject:record];
                    break;
                }
            }
            
            for (ProductSalePriceRecord *record in unitSalePriceArray) {
                if (record.recordUUID == unitName) {
                    [unitSalePriceArray removeObject:record];
                    break;
                }
            }
            
            while (YES) {
                JCHBeginInventoryForSKUViewData *viewData = nil;
                for (JCHBeginInventoryForSKUViewData *record in unitInventoryArray) {
                    if ([record.skuCombine isEqualToString:unitName]) {
                        viewData = record;
                        break;
                    }
                }
                
                if (nil == viewData) {
                    break;
                } else {
                    [unitInventoryArray removeObject:viewData];
                }
            }
        }
    }
    
    self.unitInventoryArray = unitInventoryArray;
    self.unitSalePriceArray = unitSalePriceArray;
    self.unitBarCodeArray = unitBarCodeArray;
    
    
    // 判断是否已设置条码
    BOOL hasSetBarCode = NO;
    for (ProductBarCodeRecord *record in self.unitBarCodeArray) {
        if (nil != record.productBarCode &&
            NO == [record.productBarCode isEqualToString:@""]) {
            hasSetBarCode = YES;
            break;
        }
    }
    
    if (YES == hasSetBarCode) {
        mainUnitBarCodeView.detailLabel.text = @"已录入";
    }
    
    // 主辅单位
    NSString *mainUnitText = self.currentUnitRecord.unitName;
    for (ProductUnitRecord *record in self.unitRecordArray) {
        if ([mainUnitText isEqualToString:@""]) {
            mainUnitText = [NSString stringWithFormat:@"%@", record.unitRecord.unitName];
        } else {
            mainUnitText = [NSString stringWithFormat:@"%@/%@", mainUnitText, record.unitRecord.unitName];
        }
    }
    
    mainUnitUnitView.detailLabel.text = mainUnitText;
    
    // 售价
    BOOL hasSetSalePrice = NO;
    for (ProductSalePriceRecord *record in self.unitSalePriceArray) {
        if (NO == [record.productPrice isEqualToString:@""] &&
            0 != record.productPrice.doubleValue) {
            hasSetSalePrice = YES;
            break;
        }
    }
    
    if (YES == hasSetSalePrice) {
        mainUnitPriceView.detailLabel.text = @"已录入";
    } else {
        mainUnitPriceView.detailLabel.text = @"";
    }
    
    // 期初库存
    BOOL hasSetInventory = NO;
    for (JCHBeginInventoryForSKUViewData *record in self.unitInventoryArray) {
        if (record.price != 0 && record.count != 0) {
            hasSetInventory = YES;
            break;
        }
    }
    
    if (YES == hasSetInventory) {
        mainUnitInventoryView.detailLabel.text = @"已录入";
    } else {
        mainUnitInventoryView.detailLabel.text = @"";
    }
    
    return;
}

- (void)handleChangeMainUnit:(UnitRecord4Cocoa *)fromUnit toUnit:(UnitRecord4Cocoa *)toUnit
{
    if ([fromUnit.unitName isEqualToString:toUnit.unitName]) {
        return;
    }
    
    for (ProductSalePriceRecord *record in self.unitSalePriceArray) {
        if ([record.productName isEqualToString:fromUnit.unitName]) {
            record.recordUUID = toUnit.unitName;
            record.productName = toUnit.unitName;
        }
    }
    
    for (ProductBarCodeRecord *record in self.unitBarCodeArray) {
        if ([record.productName isEqualToString:fromUnit.unitName]) {
            record.recordUUID = toUnit.unitName;
            record.productName = toUnit.unitName;
        }
    }
    
    for (JCHBeginInventoryForSKUViewData *record in self.unitInventoryArray) {
        if ([record.unit isEqualToString:fromUnit.unitName]) {
            record.skuCombine = toUnit.unitName;
            record.unitDigital = toUnit.unitDecimalDigits;
            record.unit = toUnit.unitName;
            record.unitUUID = toUnit.unitUUID;
        }
    }
    
    return;
}

- (void)saveProductImages
{
    NSArray<NSString *> *oldImagesArray = @[self.productRecord.goods_image_name ? self.productRecord.goods_image_name : @"",
                                            self.productRecord.goods_image_name2 ? self.productRecord.goods_image_name2 : @"",
                                            self.productRecord.goods_image_name3 ? self.productRecord.goods_image_name3 : @"",
                                            self.productRecord.goods_image_name4 ? self.productRecord.goods_image_name4 : @"",
                                            self.productRecord.goods_image_name5 ? self.productRecord.goods_image_name5 : @""];
    for (size_t i = 0; i < sizeof(cameraButtonArray)/sizeof(cameraButtonArray[0]); ++i) {
        UIButton *cameraButton = cameraButtonArray[i];
        UIImage *currentImage = [cameraButton imageForState:UIControlStateNormal];
        if (currentImage == self.defaultCameraImage) {
            currentImage = nil;
        }
        
        if (currentImage == self.defaultPlaceholderImage) {
            currentImage = nil;
        }
        
        if (currentImage != nil) {
            NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);
            
            //压缩图片不超过400k
            NSInteger imageKB = imageData.length / 1024;
            CGFloat compressionQuality = 1.0f;
            while (imageKB > 400) {
                compressionQuality -= 0.05;
                imageData = UIImageJPEGRepresentation(currentImage, compressionQuality);
                imageKB = imageData.length / 1024;
            }
            
            NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *imageDirectory = [document stringByAppendingString:@"/images"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //将图片存储到本地documents
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            if (nil != statusManager.accountBookID && (NO ==[statusManager.accountBookID isEqualToString:@""])) {
                self.productImagesArray[i] = [NSString stringWithFormat:@"%@-%@", statusManager.accountBookID, [[NSUUID UUID] UUIDString]];
            } else {
                self.productImagesArray[i] = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];
            }
            
            BOOL saveImageSuccess = [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@", imageDirectory, self.productImagesArray[i]] contents:imageData attributes:nil];
            if (NO == saveImageSuccess) {
                NSLog(@"save image fail");
            }
            
            //删除之前保存的照片
            NSString *oldImageName = oldImagesArray[i];
            if (oldImageName != nil &&
                NO == [oldImageName isEqualToString:@""] &&
                NO == [oldImageName isEqualToString:kDefaultCameraButtonImageName]) {
                NSString *imagePath = [JCHImageUtility getImagePath:oldImageName];
                BOOL removeImageSuccess = [fileManager removeItemAtPath:imagePath error:nil];
                if (NO == removeImageSuccess) {
                    NSLog(@"remove image fail");
                }
            }
        }
    }
    
    // 上传图片
    [JCHImageUtility uploadProductImages:self.productImagesArray];
    
    return;
}

- (void)showAlertView:(NSString *)message
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
    return;
}

- (NSArray *)createDefaultUnitInventory:(NSArray *)unitInventoryArray
{
    NSMutableArray *inventoryArray = [[[NSMutableArray alloc] initWithArray:unitInventoryArray] autorelease];
    NSArray *warehouseList = [[[ServiceFactory sharedInstance] warehouseService] queryAllWarehouse];
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        BOOL hasInventory = NO;
        for (JCHBeginInventoryForSKUViewData *record in inventoryArray) {
            if ([record.warehouseName isEqualToString:warehouse.warehouseName]) {
                hasInventory = YES;
                break;
            }
        }
        
        if (NO == hasInventory) {
            JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
            inventoryRecord.skuCombine = self.currentUnitRecord.unitName;
            inventoryRecord.price = 0;
            inventoryRecord.count = 0;
            inventoryRecord.unitDigital = self.currentUnitRecord.unitDecimalDigits;
            inventoryRecord.unit = self.currentUnitRecord.unitName;
            inventoryRecord.unitUUID = self.currentUnitRecord.unitUUID;
            inventoryRecord.skuUUIDVector = @[];
            inventoryRecord.warehouseUUID = warehouse.warehouseID;
            inventoryRecord.warehouseName = warehouse.warehouseName;
            [inventoryArray addObject:inventoryRecord];
        }
    }
    
    return inventoryArray;
}

- (NSArray *)createDefaultNoSKUInventory:(NSArray *)noskuInventoryArray
{
    NSMutableArray *inventoryList = [[[NSMutableArray alloc] initWithArray:noskuInventoryArray] autorelease];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [[[ServiceFactory sharedInstance] warehouseService] queryAllWarehouse];
    for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
        BOOL hasInventory = NO;
        for (JCHBeginInventoryForSKUViewData *record in inventoryList) {
            if ([record.warehouseName isEqualToString:warehouse.warehouseName]) {
                hasInventory = YES;
                break;
            }
        }
        
        if (NO == hasInventory) {
            JCHBeginInventoryForSKUViewData *inventoryRecord = [[[JCHBeginInventoryForSKUViewData alloc] init] autorelease];
            inventoryRecord.skuCombine = @"无规格";
            inventoryRecord.price = 0;
            inventoryRecord.count = 0;
            inventoryRecord.unitDigital = self.productRecord.goods_unit_digits;
            inventoryRecord.unit = self.productRecord.goods_unit;
            inventoryRecord.unitUUID = self.productRecord.goods_unit_uuid;
            inventoryRecord.skuUUIDVector = nil;
            inventoryRecord.warehouseUUID = warehouse.warehouseID;
            inventoryRecord.warehouseName = warehouse.warehouseName;
            
            [inventoryList addObject:inventoryRecord];
        }
    }
    
    return inventoryList;
}

#pragma mark -
#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == withoutSKUPriceView.textField) {
        if (textField.text.doubleValue == 0) {
            textField.text = @"";
        }
    }
    
    return;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == withoutSKUPriceView.textField) {
        if (textField.text == nil || [textField.text isEqualToString:@""]) {
            textField.text = @"0.00";
        }
    }
}

- (void)handleViewWillAppear
{
    //如果是从sku选择界面保存返回回来，则当前的sku数据源从sku选择界面传过来
    if (self.currentSKURecord) {
        self.skuData = self.currentSKURecord.skuArray;
    }
    
    if (currentProductMode == kProductWithSKU ||
        currentProductMode == kProductWithoutSKU) {
        [self refreshSKUPriceBarCodeInventory];
        [self loadTakeoutInfoData];
    } else if (currentProductMode == kProductMainUnit) {
        [self refreshUnitPriceBarCodeInventory];
    } else {
        // pass
    }
    
    return;
}


@end


