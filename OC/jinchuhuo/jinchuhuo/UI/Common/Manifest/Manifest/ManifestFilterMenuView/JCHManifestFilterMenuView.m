//
//  JCHManifestFilterMenuView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHManifestFilterMenuView.h"
#import "JCHDateRangePickView.h"
#import "JCHTitleArrowButton.h"
#import "JCHInputAccessoryView.h"
#import "JCHManifestTypeSelectOptionView.h"
#import "CommonHeader.h"

@interface JCHManifestFilterMenuView () <UITextFieldDelegate, JCHDateRangePickViewDelegate>

@property (nonatomic, retain) UIButton *selectedManifestTypeButton;
@property (nonatomic, retain) UIView *backgroundMaskView;
@property (nonatomic, retain) UIView *fatherView;
@property (nonatomic, retain) UIView *pullDownContainerView;

@property (nonatomic, assign) BOOL show;

//当前选择的货单类型是不是仓单
@property (nonatomic, assign) BOOL selectWarehouseType;

@end

@implementation JCHManifestFilterMenuView
{
    JCHTitleArrowButton *_manifestTypeButton;
    JCHTitleArrowButton *_manifestFilterButton;
    UIView *_manifestTypeContainerView;
    UIView *_manifestFilterContainerView;
    UITextField *_searchTextField;
    UILabel *_infoLabel;
    
    JCHManifestTypeSelectOptionView *_manifestTypeOptionView;
    JCHManifestTypeSelectOptionView *_manifestWarehouseOptionView;
    
    UIButton *_manifestDateButton;
    UIButton *_manifestTimeButton;
    UIView *_manifestAmountRangeContainerView;
    UITextField *_manifestMinAmountTextField;
    UITextField *_manifestMaxAmountTextField;
    JCHManifestTypeSelectOptionView *_payWayOptionView;
    JCHManifestTypeSelectOptionView *_payStatusOptionView;
    UIScrollView *_manifestFilterOptionContainerView;
}
- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.fatherView = superView;
        
        [self createUI];
        [self resetManifestFilterCondition:YES];
    }
    return self;
}


//重写该方法，当该view作为titleView时可以消除两边空隙
- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(0, 0, kScreenWidth, kStandardItemHeight)];
}

//重置筛选条件   containManifestType是否重置货单类型
- (void)resetManifestFilterCondition:(BOOL)containManifestType
{
    if (containManifestType) {
        NSDictionary *dict =  @{kManifestDateStartKey   : @"",
                                kManifestDateEndKey     : @"",
                                kManifestTimeStartKey   : @"",
                                kManifestTimeEndKey     : @"",
                                kManifestAmountStartKey : @"" ,
                                kManifestAmountEndKey   : @"",
                                kManifestTypeKey        : @(-1),
                                kManifestPayWayKey      : @(-1),
                                kManifestPayStatusKey   : @(-1)};
        self.manifestFilterCondition = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        [_manifestTypeOptionView cancleSelect];
        [_manifestWarehouseOptionView cancleSelect];
        _manifestTypeOptionView.index = -1;
        [self clearOption];
        
        UIButton *firstButton = nil;
        for (UIView *subView in _manifestTypeOptionView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                if (subView.tag == -1) {
                    firstButton = (UIButton *)subView;
                }
            }
        }
        firstButton.selected = YES;
        [self selectManifestType:firstButton];
        
        _searchTextField.text = @"";
        self.searchString = @"";
    } else {
        
        [self clearOption];
        
        [self.manifestFilterCondition setObject:@"" forKey:kManifestDateStartKey];
        [self.manifestFilterCondition setObject:@"" forKey:kManifestDateEndKey];
        [self.manifestFilterCondition setObject:@"" forKey:kManifestTimeStartKey];
        [self.manifestFilterCondition setObject:@"" forKey:kManifestTimeEndKey];
        [self.manifestFilterCondition setObject:@"" forKey:kManifestAmountStartKey];
        [self.manifestFilterCondition setObject:@"" forKey:kManifestAmountEndKey];
        [self.manifestFilterCondition setObject:@(-1) forKey:kManifestPayWayKey];
        [self.manifestFilterCondition setObject:@(-1) forKey:kManifestPayStatusKey];

        
        _searchTextField.text = @"";
        self.searchString = @"";
    }
}

- (void)dealloc
{
    self.selectedManifestTypeButton = nil;
    self.backgroundMaskView = nil;
    self.fatherView = nil;
    self.pullDownContainerView = nil;
    self.manifestFilterCondition = nil;
    self.commitBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    CGFloat menuButtonWidth = 65;
    CGFloat menuButtonHeight = 44;
    CGFloat menuButtonLeftOffset = 5;
    _manifestTypeButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    
    _manifestTypeButton.autoReverseArrow = YES;
    _manifestTypeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_manifestTypeButton setTitle:@"货单" forState:UIControlStateNormal];
    
    if (statusManager.isShopManager) {
        [_manifestTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_manifestTypeButton setImage:[UIImage imageNamed:@"homepage_storename_open"] forState:UIControlStateNormal];
    } else {
        [_manifestTypeButton setTitleColor:JCHColorAuxiliary forState:UIControlStateNormal];
        [_manifestTypeButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
        [_manifestTypeButton setImage:[UIImage imageNamed:@"inventory_multiselect_open_icon"] forState:UIControlStateNormal];
        [_manifestTypeButton setImage:[UIImage imageNamed:@"inventory_multiselect_close_icon"] forState:UIControlStateSelected];
        _manifestTypeButton.autoReverseArrow = NO;
    }
    
    [_manifestTypeButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_manifestTypeButton];
    
    CGSize fitSize = [_manifestTypeButton.titleLabel sizeThatFits:CGSizeZero];
    menuButtonWidth = fitSize.width + _manifestTypeButton.imageView.image.size.width + 15;
    
    [_manifestTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(menuButtonLeftOffset);
        make.top.equalTo(self);
        make.width.mas_equalTo(menuButtonWidth);
        make.height.mas_equalTo(menuButtonHeight);
    }];
    
    _manifestFilterButton = [JCHTitleArrowButton buttonWithType:UIButtonTypeCustom];
    _manifestFilterButton.titleLabel.font = [UIFont systemFontOfSize:13];
    if (statusManager.isShopManager) {
        [_manifestFilterButton setImage:[UIImage imageNamed:@"nav_ic_filter"] forState:UIControlStateNormal];
        [_manifestFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        
        [_manifestFilterButton setImage:[[UIImage imageNamed:@"nav_ic_filter"] imageWithTintColor:JCHColorAuxiliary] forState:UIControlStateNormal];
        [_manifestFilterButton setImage:[[UIImage imageNamed:@"nav_ic_filter"] imageWithTintColor:JCHColorHeaderBackground] forState:UIControlStateSelected];
        [_manifestFilterButton setTitleColor:JCHColorAuxiliary forState:UIControlStateNormal];
        [_manifestFilterButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    }
    [_manifestFilterButton setTitle:@"筛选" forState:UIControlStateNormal];
    [_manifestFilterButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_manifestFilterButton];
    
    
    
    [_manifestFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(_manifestTypeButton);
        make.width.mas_equalTo(menuButtonWidth);
    }];
    
    
    UIView *_searchBackgroundView = [[[UIView alloc] init] autorelease];
    _searchBackgroundView.layer.cornerRadius = 3;
    _searchBackgroundView.clipsToBounds = YES;
    [self addSubview:_searchBackgroundView];
    
    if (statusManager.isShopManager) {
        _searchBackgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        _searchBackgroundView.backgroundColor = JCHColorGlobalBackground;
    }
    
    [_searchBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestTypeButton.mas_right).with.offset(menuButtonLeftOffset);
        make.right.equalTo(self).offset(-(menuButtonWidth + 2 * menuButtonLeftOffset));
        make.top.equalTo(self).with.offset(0.7 * kStandardWidthOffset);
        make.centerY.equalTo(self);
    }];
    
    UIImageView *_searchImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inventory_multiselect_search_icon"]] autorelease];
    [_searchBackgroundView addSubview:_searchImageView];
    
    [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_searchBackgroundView).with.offset(kStandardWidthOffset);
        make.width.mas_equalTo(1.5 * kStandardWidthOffset);
        make.height.mas_equalTo(1.5 * kStandardWidthOffset);
        make.centerY.equalTo(_searchBackgroundView);
    }];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    _searchTextField = [JCHUIFactory createTextField:CGRectZero
                                         placeHolder:@"搜索"
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentLeft];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.font = JCHFont(13);
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeyDone;
    _searchTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.tintColor = [UIColor blueColor];
    [_searchTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [_searchBackgroundView addSubview:_searchTextField];
    
    [_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_searchImageView.mas_right).offset(kStandardLeftMargin / 2);
        make.right.equalTo(_searchBackgroundView);
        make.top.equalTo(_searchBackgroundView);
        make.bottom.equalTo(_searchBackgroundView);
    }];
    
//    _infoLabel = [JCHUIFactory createLabel:CGRectZero
//                                     title:@"仓单搜索与筛选功能即将上线!"
//                                      font:JCHFont(14.0)
//                                 textColor:[UIColor whiteColor]
//                                    aligin:NSTextAlignmentCenter];
//    _infoLabel.hidden = YES;
//    _infoLabel.userInteractionEnabled = NO;
//    
//    [self addSubview:_infoLabel];
//    
//    if (statusManager.isShopManager) {
//        _infoLabel.backgroundColor = JCHColorHeaderBackground;
//        _infoLabel.textColor = [UIColor whiteColor];
//    } else {
//        _infoLabel.backgroundColor = [UIColor whiteColor];
//        _infoLabel.textColor = JCHColorAuxiliary;
//    }
//    
//    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_manifestTypeButton.mas_right);
//        make.right.equalTo(self).offset(-kStandardLeftMargin);
//        make.top.bottom.equalTo(self);
//    }];

    self.pullDownContainerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.pullDownContainerView.clipsToBounds = YES;
    self.pullDownContainerView.backgroundColor = [UIColor whiteColor];
    [self.fatherView addSubview:self.pullDownContainerView];
    
    
    CGFloat optionVerticalGap = 20;
    _manifestTypeContainerView = [[[UIView alloc] init] autorelease];
    [self.pullDownContainerView addSubview:_manifestTypeContainerView];
    
    [_manifestTypeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.top.equalTo(self.pullDownContainerView);
    }];
    
    NSArray *manifestTypeArray = @[@"全部货单", @"进货单", @"出货单", @"进货退单", @"出货退单"];
    NSArray *manifestWarehouseArray = @[@"全部仓单", @"移库单", @"盘点单", @"拼装单", @"拆装单"];//@[@"全部仓单", @"移库单", @"拆卸单", @"盘点单", @"拼装单"];
    
    
    if (statusManager.isShopManager == NO) {
        manifestTypeArray = @[@"全部货单", @"出货单", @"出货退单"];
    }
    
    _manifestTypeOptionView = [[[JCHManifestTypeSelectOptionView alloc] initWithFrame:CGRectZero title:@"货单" dataSource:manifestTypeArray] autorelease];
    _manifestTypeOptionView.index = -1;
    WeakSelf;
    [_manifestTypeOptionView setButtonClick:^(UIButton *button) {
        [weakSelf selectManifestType:button];
    }];
    [_manifestTypeContainerView addSubview:_manifestTypeOptionView];
    
    [_manifestTypeOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_manifestTypeContainerView);
        make.top.equalTo(_manifestTypeContainerView).with.offset(optionVerticalGap);
        make.height.mas_equalTo(_manifestTypeOptionView.viewHeight);
    }];

  
    if (statusManager.isShopManager) {
        _manifestWarehouseOptionView = [[[JCHManifestTypeSelectOptionView alloc] initWithFrame:CGRectZero title:@"仓单" dataSource:manifestWarehouseArray] autorelease];
        [_manifestWarehouseOptionView setButtonClick:^(UIButton *button) {
            [weakSelf selectManifestWarehouseType:button];
        }];
        [_manifestTypeContainerView addSubview:_manifestWarehouseOptionView];
        
        [_manifestWarehouseOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_manifestTypeOptionView.mas_bottom);
            make.left.width.equalTo(_manifestTypeOptionView);
            make.height.mas_equalTo(_manifestWarehouseOptionView.viewHeight);
        }];
        
        [_manifestTypeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_manifestWarehouseOptionView.mas_bottom).offset(optionVerticalGap);
        }];
    } else {
        [_manifestTypeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_manifestTypeOptionView.mas_bottom).offset(optionVerticalGap);
        }];
    }
    

    _manifestFilterContainerView = [[[UIView alloc] init] autorelease];
    _manifestFilterContainerView.hidden = YES;
    [self.pullDownContainerView addSubview:_manifestFilterContainerView];
    
    [_manifestFilterContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.pullDownContainerView);
        make.width.mas_equalTo(kScreenWidth);
        //make.height.mas_equalTo(200).priorityLow();
    }];

    _manifestFilterOptionContainerView = [[[UIScrollView alloc] init] autorelease];
    _manifestFilterOptionContainerView.backgroundColor = JCHColorGlobalBackground;
    [_manifestFilterContainerView addSubview:_manifestFilterOptionContainerView];
    
    [_manifestFilterOptionContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_manifestFilterContainerView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    CGFloat titleLabelHeight = 25;
    CGFloat verticalGap = 10;
    CGFloat scrollViewHeight = 0;
    UIFont *titleLabelFont = [UIFont jchBoldSystemFontOfSize:12];
    
    UILabel *dateTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"开单日期"
                                                   font:titleLabelFont
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentLeft];
    [_manifestFilterOptionContainerView addSubview:dateTitleLabel];
    
    [dateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestFilterOptionContainerView).offset(verticalGap);
        make.left.equalTo(_manifestFilterOptionContainerView).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(titleLabelHeight);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
    }];
    scrollViewHeight += titleLabelHeight + verticalGap;
    CGFloat buttonHeight = 30.0f;
    
    _manifestDateButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(selectOption:)
                                               title:@"选择开单日期"
                                          titleColor:JCHColorMainBody
                                     backgroundColor:[UIColor whiteColor]];
    _manifestDateButton.titleLabel.font = JCHFont(13);
    [_manifestDateButton setTitleColor:JCHColorAuxiliary forState:UIControlStateNormal];
    [_manifestDateButton setTitleColor:JCHColorMainBody forState:UIControlStateSelected];
    [_manifestDateButton addBorderLine];
    [_manifestFilterOptionContainerView addSubview:_manifestDateButton];
    
    [_manifestDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateTitleLabel.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
        make.left.right.equalTo(dateTitleLabel);
    }];
    
    scrollViewHeight += buttonHeight;

    UILabel *timeTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"开单时间"
                                                   font:titleLabelFont
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentLeft];
    [_manifestFilterOptionContainerView addSubview:timeTitleLabel];
    
    [timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestDateButton.mas_bottom).offset(verticalGap);
        make.left.equalTo(_manifestFilterOptionContainerView).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(titleLabelHeight);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
    }];
    
    scrollViewHeight += titleLabelHeight + verticalGap;
    
    
    _manifestTimeButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(selectOption:)
                                               title:@"选择开单时间"
                                          titleColor:JCHColorMainBody
                                     backgroundColor:[UIColor whiteColor]];
    _manifestTimeButton.titleLabel.font = JCHFont(13);
    [_manifestTimeButton setTitleColor:JCHColorAuxiliary forState:UIControlStateNormal];
    [_manifestTimeButton setTitleColor:JCHColorMainBody forState:UIControlStateSelected];
    [_manifestTimeButton addBorderLine];
    [_manifestFilterOptionContainerView addSubview:_manifestTimeButton];
    
    [_manifestTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeTitleLabel.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
        make.left.right.equalTo(dateTitleLabel);
    }];
    scrollViewHeight += buttonHeight;

    _manifestAmountRangeContainerView = [[[UIView alloc] init] autorelease];
    [_manifestFilterOptionContainerView addSubview:_manifestAmountRangeContainerView];
    
    [_manifestAmountRangeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_manifestFilterOptionContainerView);
        make.top.equalTo(_manifestTimeButton.mas_bottom).offset(verticalGap);
        make.height.mas_equalTo(titleLabelHeight + buttonHeight);
    }];
    
    scrollViewHeight += titleLabelHeight + buttonHeight + verticalGap;
    
    UILabel *amountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"开单金额"
                                                     font:titleLabelFont
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentLeft];
    [_manifestAmountRangeContainerView addSubview:amountTitleLabel];
    
    [amountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestAmountRangeContainerView);
        make.left.equalTo(_manifestAmountRangeContainerView).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(titleLabelHeight);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
    }];
    
    
    CGFloat amountCenterLabelWidth = 50;
    
    
    
    _manifestMinAmountTextField = [JCHUIFactory createTextField:CGRectZero
                                              placeHolder:@"最小金额"
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentCenter];
    _manifestMinAmountTextField.font = JCHFont(13);
    _manifestMinAmountTextField.backgroundColor = [UIColor whiteColor];
    _manifestMinAmountTextField.layer.cornerRadius = 3;
    _manifestMinAmountTextField.clipsToBounds = YES;
    _manifestMinAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_manifestMinAmountTextField addBorderLine];
    [_manifestAmountRangeContainerView addSubview:_manifestMinAmountTextField];
    
    [_manifestMinAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(amountTitleLabel.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
        make.left.equalTo(dateTitleLabel);
        make.width.mas_equalTo((kScreenWidth - amountCenterLabelWidth - 2 * kStandardLeftMargin) / 2);
    }];
    
    
    UILabel *amountCenterLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"至"
                                                      font:JCHFont(12)
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentCenter];
    [_manifestAmountRangeContainerView addSubview:amountCenterLabel];
    
    [amountCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestMinAmountTextField.mas_right);
        make.top.bottom.equalTo(_manifestMinAmountTextField);
        make.width.mas_equalTo(amountCenterLabelWidth);
    }];
    
    _manifestMaxAmountTextField = [JCHUIFactory createTextField:CGRectZero
                                            placeHolder:@"最大金额"
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentCenter];
    _manifestMaxAmountTextField.font = JCHFont(13);
    _manifestMaxAmountTextField.backgroundColor = [UIColor whiteColor];
    _manifestMaxAmountTextField.layer.cornerRadius = 3;
    _manifestMaxAmountTextField.clipsToBounds = YES;
    _manifestMaxAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_manifestMaxAmountTextField addBorderLine];
    [_manifestAmountRangeContainerView addSubview:_manifestMaxAmountTextField];
    
    [_manifestMaxAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(amountCenterLabel.mas_right);
        make.width.top.bottom.equalTo(_manifestMinAmountTextField);
    }];


    NSArray *pawWayArray = @[@"全部", @"现金", @"赊欠", @"微信"];
    NSArray *payStatusArray = @[@"全部", @"未收款", @"已收款", @"未付款", @"已付款"];
    if (statusManager.isShopManager == NO) {
        payStatusArray = @[@"全部", @"未收款", @"已收款"];
    }
    
    _payWayOptionView = [[[JCHManifestTypeSelectOptionView alloc] initWithFrame:CGRectZero title:@"结算方式" dataSource:pawWayArray] autorelease];
    _payWayOptionView.index = -1;
    [_manifestFilterOptionContainerView addSubview:_payWayOptionView];
    
    [_payWayOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestFilterOptionContainerView);
        make.top.equalTo(_manifestMaxAmountTextField.mas_bottom).offset(verticalGap);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(_payWayOptionView.viewHeight);
    }];
    
    scrollViewHeight += _payWayOptionView.viewHeight + verticalGap;
    
    _payStatusOptionView = [[[JCHManifestTypeSelectOptionView alloc] initWithFrame:CGRectZero title:@"赊欠状态" dataSource:payStatusArray] autorelease];
    _payStatusOptionView.index = -1;
    [_manifestFilterOptionContainerView addSubview:_payStatusOptionView];
    
    [_payStatusOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestFilterOptionContainerView);
        make.top.equalTo(_payWayOptionView.mas_bottom).offset(verticalGap);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(_payStatusOptionView.viewHeight);
    }];
    
    scrollViewHeight += _payStatusOptionView.viewHeight + verticalGap;
    
    scrollViewHeight += verticalGap;
    _manifestFilterOptionContainerView.contentSize = CGSizeMake(0, scrollViewHeight);
    
    CGFloat scrollViewMaxHeight = kScreenHeight - 64 - 49 - 2 * kStandardItemHeight - 50;
    [_manifestFilterOptionContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(scrollViewHeight).priorityLow();
        make.height.mas_lessThanOrEqualTo(scrollViewMaxHeight).priorityHigh();
    }];
    
    [_manifestFilterContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_manifestFilterOptionContainerView).offset(kStandardItemHeight);
    }];
    
    
    UIButton *clearButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(clearOption)
                                                 title:@"重置"
                                            titleColor:JCHColorMainBody
                                       backgroundColor:[UIColor whiteColor]];
    clearButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    clearButton.layer.cornerRadius = 0;
    clearButton.clipsToBounds = NO;
    [_manifestFilterContainerView addSubview:clearButton];
    
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(_manifestFilterContainerView);
        make.width.mas_equalTo(kScreenWidth / 2);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    
    UIButton *commitButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(commit)
                                         title:@"确定"
                                    titleColor:JCHColorHeaderBackground
                               backgroundColor:[UIColor whiteColor]];
    commitButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    commitButton.layer.cornerRadius = 0;
    [_manifestFilterContainerView addSubview:commitButton];
    
    [commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(clearButton.mas_right);
        make.top.bottom.width.equalTo(clearButton);
    }];
    [clearButton addSeparateLineWithMasonryTop:YES bottom:NO];
    [commitButton addSeparateLineWithMasonryTop:YES bottom:NO];
    
    UIView *verticalLine = [[[UIView alloc] init] autorelease];
    verticalLine.frame = CGRectMake(0, 0, kSeparateLineWidth, kStandardItemHeight);
    verticalLine.backgroundColor = JCHColorSeparateLine;
    [commitButton addSubview:verticalLine];
    
    self.backgroundMaskView = [[[UIView alloc] init] autorelease];
    self.backgroundMaskView.backgroundColor = [UIColor blackColor];
    self.backgroundMaskView.alpha = 0;
    [self.fatherView addSubview:self.backgroundMaskView];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)] autorelease];
    [self.backgroundMaskView addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.backgroundMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.right.bottom.equalTo(self.fatherView);
    }];
}

- (void)setOffsetY:(CGFloat)offsetY
{
    if (_offsetY != offsetY) {
        _offsetY = offsetY;
        [self.backgroundMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).with.offset(-offsetY);
        }];
    }
}


- (void)selectManifestType:(UIButton *)button
{
    if (self.selectWarehouseType) {
        [self resetManifestFilterCondition:NO];
        self.selectWarehouseType = NO;
        [self switchFilterView:NO];
    }
    
    
    [_manifestWarehouseOptionView cancleSelect];
    [_manifestTypeButton setTitle:button.currentTitle forState:UIControlStateNormal];
    
    CGSize fitSize = [_manifestTypeButton.titleLabel sizeThatFits:CGSizeZero];
    CGFloat menuButtonWidth = fitSize.width + _manifestTypeButton.imageView.frame.size.width + 15;
    
    [_manifestTypeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(menuButtonWidth);
    }];
    
    NSInteger manifestType = _manifestTypeOptionView.index;
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager == NO) {
        if (manifestType == 0) {
            manifestType = 1;
        } else if (manifestType == 1) {
            manifestType = 3;
        }
    }

    [self.manifestFilterCondition setObject:@(manifestType) forKey:kManifestTypeKey];
    
    if (self.show) {
        [self menuButtonClick:_manifestTypeButton];
    }
    
    if (self.commitBlock) {
        self.commitBlock();
    }
}

- (void)selectManifestWarehouseType:(UIButton *)button
{
    if (!self.selectWarehouseType) {
        [self resetManifestFilterCondition:NO];
        self.selectWarehouseType = YES;
        [self switchFilterView:YES];
    }
    
    [_manifestTypeOptionView cancleSelect];
    [_manifestTypeButton setTitle:button.currentTitle forState:UIControlStateNormal];
    
    CGSize fitSize = [_manifestTypeButton.titleLabel sizeThatFits:CGSizeZero];
    CGFloat menuButtonWidth = fitSize.width + _manifestTypeButton.imageView.frame.size.width + 15;
    
    [_manifestTypeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(menuButtonWidth);
    }];
    
    NSInteger manifestType = _manifestWarehouseOptionView.index;
    
    /**
     *   kJCHManifestMigrate = 6,            // 移库单
         kJCHManifestDismounting = 7,        // 拆装单
         kJCHManifestInventory = 8,          // 盘点单
         kJCHManifestAssembling = 9,         // 组装单
     */
    
    if (manifestType == -1) { //全部仓单
        manifestType = -2;
    }
    
    if (manifestType == 0) { //移库单
        manifestType = 6;
    }
    
    if (manifestType == 1) { //盘点单
        manifestType = 8;
    }
    
    if (manifestType == 2) {
        manifestType = 9;
    }
    
    if (manifestType == 3) {
        manifestType = 7;
    }
    
    
    [self.manifestFilterCondition setObject:@(manifestType) forKey:kManifestTypeKey];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self menuButtonClick:_manifestTypeButton];
        if (self.commitBlock) {
            self.commitBlock();
        }
    });
}

- (void)switchFilterView:(BOOL)warehouseManifest
{
    CGFloat viewGap = 10;
    CGFloat manifestAmountRangeContainerViewHeight = 55;
    CGFloat scrollViewMaxHeight = kScreenHeight - 64 - 49 - 2 * kStandardItemHeight - 50;
    if (warehouseManifest) {
    
        [_manifestAmountRangeContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [_payWayOptionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [_payStatusOptionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        _manifestAmountRangeContainerView.hidden = YES;
        _payStatusOptionView.hidden = YES;
        _payWayOptionView.hidden = YES;
        
        CGFloat scrollViewHeight = _manifestFilterOptionContainerView.contentSize.height;
        scrollViewHeight -= manifestAmountRangeContainerViewHeight;
        scrollViewHeight -= _payWayOptionView.viewHeight;
        scrollViewHeight -= _payStatusOptionView.viewHeight;
        scrollViewHeight -= 2 * viewGap;
        
        [_manifestFilterOptionContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(scrollViewHeight).priorityLow();
            make.height.mas_lessThanOrEqualTo(scrollViewMaxHeight).priorityHigh();
        }];
        _manifestFilterOptionContainerView.contentSize = CGSizeMake(0, scrollViewHeight);
    } else {
        
        [_manifestAmountRangeContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(manifestAmountRangeContainerViewHeight);
        }];
        
        [_payWayOptionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_payWayOptionView.viewHeight);
        }];
        
        [_payStatusOptionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_payStatusOptionView.viewHeight);
        }];
        
        _manifestAmountRangeContainerView.hidden = NO;
        _payStatusOptionView.hidden = NO;
        _payWayOptionView.hidden = NO;
        
        CGFloat scrollViewHeight = _manifestFilterOptionContainerView.contentSize.height;
        scrollViewHeight += manifestAmountRangeContainerViewHeight;
        scrollViewHeight += _payWayOptionView.viewHeight;
        scrollViewHeight += _payStatusOptionView.viewHeight;
        scrollViewHeight += 2 * viewGap;
        
        [_manifestFilterOptionContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(scrollViewHeight).priorityLow();
            make.height.mas_lessThanOrEqualTo(scrollViewMaxHeight).priorityHigh();
        }];
        _manifestFilterOptionContainerView.contentSize = CGSizeMake(0, scrollViewHeight);
    }
}

- (void)menuButtonClick:(UIButton *)sender
{
    self.selectedManifestTypeButton = sender;
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        if (self.show) {
            [self hideView:^{
                [self showView:sender];
            }];
        } else {
            [self showView:sender];
        }
        
    } else {
        [self hideView:nil];
    }
}

- (void)showView:(UIButton *)button
{
    self.show = YES;
    [self.fatherView bringSubviewToFront:self.backgroundMaskView];
    [self.fatherView addSubview:self.pullDownContainerView];
    
    
    UIView *referenceView = nil;
    if (button == _manifestTypeButton) {
        _manifestTypeContainerView.hidden = NO;
        _manifestFilterContainerView.hidden = YES;
        referenceView = _manifestTypeContainerView;
        _manifestTypeButton.selected = YES;
        _manifestFilterButton.selected = NO;
    } else {
        _manifestTypeContainerView.hidden = YES;
        _manifestFilterContainerView.hidden = NO;
        referenceView = _manifestFilterContainerView;
        _manifestTypeButton.selected = NO;
        _manifestFilterButton.selected = YES;
    }
    
    [self.pullDownContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).with.offset(-self.offsetY);
        make.left.right.equalTo(self.fatherView);
        make.height.mas_equalTo(0);
    }];
    [self.pullDownContainerView layoutIfNeeded];
    [self.fatherView layoutIfNeeded];
    
    [self.pullDownContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).with.offset(-self.offsetY);
        make.left.right.equalTo(self.fatherView);
        make.height.equalTo(referenceView);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.fatherView layoutIfNeeded];
        self.backgroundMaskView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideView:(void(^)(void))completion
{
    self.show = NO;
    [self.pullDownContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.right.equalTo(self.fatherView);
        make.height.mas_equalTo(0);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.pullDownContainerView.superview layoutIfNeeded];
        self.backgroundMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.pullDownContainerView removeFromSuperview];
        self.selectedManifestTypeButton = nil;
        if (completion) {
            completion();
        }
    }];
}

- (void)hideView
{
    [self menuButtonClick:self.selectedManifestTypeButton];
}

- (void)selectOption:(UIButton *)sender
{
    if (sender == _manifestDateButton) {
        JCHDateRangePickView *dateRangePickView = [[[JCHDateRangePickView alloc] initWithFrame:CGRectZero] autorelease];
        dateRangePickView.tag = 1000;
        dateRangePickView.delegate = self;
        dateRangePickView.datePickerMode = UIDatePickerModeDate;
        
        NSArray *comonents = [[_manifestDateButton titleForState:UIControlStateSelected] componentsSeparatedByString:@"至"];
        
        if (comonents.count > 1) {
            dateRangePickView.defaultStartTime = comonents[0];
            dateRangePickView.defaultEndTime = comonents[1];
        }
        
        [dateRangePickView showView];
    } else if (sender == _manifestTimeButton) {
        JCHDateRangePickView *dateRangePickView = [[[JCHDateRangePickView alloc] initWithFrame:CGRectZero] autorelease];
        dateRangePickView.tag = 1001;
        dateRangePickView.delegate = self;
        dateRangePickView.datePickerMode = UIDatePickerModeTime;
        
        NSArray *comonents = [[_manifestTimeButton titleForState:UIControlStateSelected] componentsSeparatedByString:@"至"];
        
        if (comonents.count > 1) {
            dateRangePickView.defaultStartTime = comonents[0];
            dateRangePickView.defaultEndTime = comonents[1];
        }
        [dateRangePickView showView];
    }
}

//筛选里面的重置
- (void)clearOption
{
    _manifestDateButton.selected = NO;
    _manifestTimeButton.selected = NO;
    _manifestMinAmountTextField.text = @"";
    _manifestMaxAmountTextField.text = @"";
    _payWayOptionView.index = -1;
    _payStatusOptionView.index = -1;
}

//筛选里面的确定
- (void)commit
{
    NSArray *dateRangeArray = nil;
    
    if (_manifestDateButton.selected) {
        dateRangeArray = [_manifestDateButton.currentTitle componentsSeparatedByString:@"至"];
    }
    NSArray *timeRangeArray = nil;
    if (_manifestTimeButton.selected) {
        timeRangeArray = [_manifestTimeButton.currentTitle componentsSeparatedByString:@"至"];
    }
    
    NSString *dateStartString = dateRangeArray ? dateRangeArray[0] : @"";
    NSString *dateEndString = dateRangeArray ? dateRangeArray[1] : @"";
    NSString *timeStartString = timeRangeArray ? timeRangeArray[0] : @"";
    NSString *timeEndString = timeRangeArray ? timeRangeArray[1] : @"";
    NSString *amountStartString = _manifestMinAmountTextField.text;
    NSString *amountEndString = _manifestMaxAmountTextField.text;
    


    if (![amountStartString isEqualToString:@""] && ![amountEndString isEqualToString:@""]) {
        if (amountStartString.doubleValue >= amountEndString.doubleValue) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"金额范围有误"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return;
        }
    }
    
    NSInteger manifestPayWay = _payWayOptionView.index;
    NSInteger manifestPayStatus = _payStatusOptionView.index;

    ////处理店员筛选tag对应问题
    //JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    //if (statusManager.isShopManager == NO) {
        //if (manifestPayStatus == 1) {
            //manifestPayStatus = 2;
        //}
    //}

    [self.manifestFilterCondition setObject:dateStartString forKey:kManifestDateStartKey];
    [self.manifestFilterCondition setObject:dateEndString forKey:kManifestDateEndKey];
    [self.manifestFilterCondition setObject:timeStartString forKey:kManifestTimeStartKey];
    [self.manifestFilterCondition setObject:timeEndString forKey:kManifestTimeEndKey];
    [self.manifestFilterCondition setObject:amountStartString forKey:kManifestAmountStartKey];
    [self.manifestFilterCondition setObject:amountEndString forKey:kManifestAmountEndKey];
    [self.manifestFilterCondition setObject:@(manifestPayWay) forKey:kManifestPayWayKey];
    [self.manifestFilterCondition setObject:@(manifestPayStatus) forKey:kManifestPayStatusKey];
    
    [self menuButtonClick:_manifestFilterButton];
    
    if (self.commitBlock) {
        self.commitBlock();
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.searchString = textField.text;
    [textField resignFirstResponder];
    
    if (self.commitBlock) {
        self.commitBlock();
    }
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    self.searchString = textField.text;
}

#pragma mark - JCHDateRangePickViewDelegate

- (void)dateRangePickViewSelectDateRange:(JCHDateRangePickView *)dateRangePickView
                           withStartTime:(NSString *)startTime
                                 endTime:(NSString *)endTime
{
    if (dateRangePickView.tag == 1000) {
        _manifestDateButton.selected = YES;
        NSString *dateRange = [NSString stringWithFormat:@"%@至%@", startTime, endTime];
        [_manifestDateButton setTitle:dateRange forState:UIControlStateSelected];
    } else if (dateRangePickView.tag == 1001) {
        _manifestTimeButton.selected = YES;
        NSString *dateRange = [NSString stringWithFormat:@"%@至%@", startTime, endTime];
        [_manifestTimeButton setTitle:dateRange forState:UIControlStateSelected];
    }
}

@end
