//
//  JCHManifestDetailHeaderView.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestDetailHeaderView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHManifestType.h"
#import "Masonry.h"
#import "CommonHeader.h"

@implementation JCHManifestDetailHeaderViewData

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
    [self.manifestDate release];
    [self.manifestID release];
    [self.manifestBuyer release];
    [self.manifestSeller release];
    [self.manifestWarehouseInfo release];
    
    [super dealloc];
    return;
}

@end


@interface JCHManifestDetailHeaderView ()
{
    UILabel *_manifestIDLabel;
    UILabel *_manifestDateLabel;
    UILabel *_manifestContactLabel;
    UILabel *_manifestWarehouseLabel;
    UILabel *_manifestOperatorLabel;
}

@property (nonatomic, assign) NSInteger manifestType;
@end

@implementation JCHManifestDetailHeaderView

- (id)initWithType:(NSInteger)manifestType
{
    self = [super init];
    if (self) {
        self.manifestType = manifestType;
        self.viewHeight = 122;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    UIFont *labelFont = [UIFont systemFontOfSize:13.0f];
    CGFloat labelHeight = 20.0f;
    CGFloat labelTopOffset = 11.0f;
    
    _manifestIDLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"单号："
                                           font:labelFont
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self addSubview:_manifestIDLabel];
    
    [_manifestIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.top.equalTo(self).with.offset(labelTopOffset);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    _manifestDateLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"日期："
                                             font:labelFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    [self addSubview:_manifestDateLabel];
    
    [_manifestDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestIDLabel);
        make.top.equalTo(_manifestIDLabel.mas_bottom);
        make.width.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    _manifestOperatorLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"开单人："
                                                  font:labelFont
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    _manifestOperatorLabel.clipsToBounds = YES;
    [self addSubview:_manifestOperatorLabel];
    
    [_manifestOperatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestIDLabel);
        make.top.equalTo(_manifestDateLabel.mas_bottom);
        make.width.equalTo(_manifestIDLabel);
       make.height.mas_equalTo(labelHeight);
    }];
    
    _manifestWarehouseLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"仓库"
                                                   font:labelFont
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentLeft];
    _manifestWarehouseLabel.clipsToBounds = YES;
    [self addSubview:_manifestWarehouseLabel];
    
    [_manifestWarehouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestOperatorLabel.mas_bottom);
        make.left.right.equalTo(_manifestOperatorLabel);
        make.height.mas_equalTo(labelHeight);
    }];
#if 1
    _manifestContactLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"客户："
                                                 font:labelFont
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
    _manifestContactLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_manifestContactLabel];
    
    [_manifestContactLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestIDLabel);
        make.top.equalTo(_manifestWarehouseLabel.mas_bottom);
        make.width.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(labelHeight);
    }];
#endif

    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin / 2);
        make.width.mas_equalTo(kScreenWidth - kStandardLeftMargin);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];

    return;
}

- (void)setViewData:(JCHManifestDetailHeaderViewData *)viewData
{
    _manifestIDLabel.text = [NSString stringWithFormat:@"单号：%@", viewData.manifestID];
    _manifestDateLabel.text = [NSString stringWithFormat:@"日期：%@", viewData.manifestDate];
    if ([viewData.manifestOperator isEmptyString]) {
        [_manifestOperatorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
    }
    
    if (self.manifestType == kJCHOrderShipment || self.manifestType == kJCHOrderPurchases) {
        _manifestOperatorLabel.text = [NSString stringWithFormat:@"开单人：%@", viewData.manifestOperator];
        
        // 外卖版不显示仓库
#if MMR_TAKEOUT_VERSION
        [_manifestWarehouseLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
#else
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"仓库：%@", viewData.manifestWarehouseInfo];
#endif
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"仓库：%@", viewData.manifestWarehouseInfo];

        if (viewData.manifestType == kJCHOrderPurchases || viewData.manifestType == kJCHOrderPurchasesReject) {
            _manifestContactLabel.text = [NSString stringWithFormat:@"供应商：%@", viewData.manifestSeller];
        } else if (viewData.manifestType == kJCHOrderShipment || viewData.manifestType == kJCHOrderShipmentReject) {
            _manifestContactLabel.text = [NSString stringWithFormat:@"客户：%@", viewData.manifestBuyer];
        }
        

    } else if (self.manifestType == kJCHManifestInventory) {
        _manifestOperatorLabel.text = [NSString stringWithFormat:@"盘点人：%@", viewData.manifestOperator];
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"仓库：%@", viewData.manifestWarehouseInfo];
        NSString *productCountText = [NSString stringWithFormat:@"共盘点%ld种单品", viewData.productCount];
        NSString *increaseText = viewData.increaseSKUCount == 0 ? @"" : [NSString stringWithFormat:@"盘盈%ld种(数量%g)", viewData.increaseSKUCount, viewData.increaseCount];
        NSString *comma = [increaseText isEqualToString:@""] ? @"" : @"，";
        NSString *decreaseText = viewData.decreaseSKUCount == 0 ? @"" : [NSString stringWithFormat:@"%@盘亏%ld种(数量%g)", comma, viewData.decreaseSKUCount, viewData.decreaseCount];
        _manifestContactLabel.text = [NSString stringWithFormat:@"%@。%@%@", productCountText, increaseText, decreaseText];
    } else if (self.manifestType == kJCHManifestMigrate) {
        _manifestOperatorLabel.text = [NSString stringWithFormat:@"移库人：%@", viewData.manifestOperator];
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"%@", viewData.manifestWarehouseInfo];
        NSString *productCountText = [NSString stringWithFormat:@"共移出%ld种（数量%g）单品", viewData.productCount, viewData.totalCount];
        _manifestContactLabel.text = productCountText;
    } else if (self.manifestType == kJCHManifestAssembling) {
        _manifestOperatorLabel.text = [NSString stringWithFormat:@"拼装人：%@", viewData.manifestOperator];
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"仓库：%@", viewData.manifestWarehouseInfo];
        NSString *productCountText = [NSString stringWithFormat:@"共%ld种单品", viewData.productCount];
        _manifestContactLabel.text = productCountText;
    } else if (self.manifestType == kJCHManifestDismounting) {
        _manifestOperatorLabel.text = [NSString stringWithFormat:@"拆装人：%@", viewData.manifestOperator];
        _manifestWarehouseLabel.text = [NSString stringWithFormat:@"仓库：%@", viewData.manifestWarehouseInfo];
        NSString *productCountText = [NSString stringWithFormat:@"共%ld种单品", viewData.productCount];
        _manifestContactLabel.text = productCountText;
    }
    
    return;
}


@end
