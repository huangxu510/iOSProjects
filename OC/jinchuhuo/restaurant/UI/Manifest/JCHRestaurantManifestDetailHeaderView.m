//
//  JCHRestaurantManifestDetailHeaderView.m
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestDetailHeaderView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHManifestType.h"
#import "Masonry.h"
#import "CommonHeader.h"

@implementation JCHRestaurantManifestDetailHeaderViewData

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
    [self.deskNumber release];
    [self.usedTime release];
    [self.remark release];
    [self.manifestOperator release];
    
    [super dealloc];
    return;
}

@end


@interface JCHRestaurantManifestDetailHeaderView ()
{
    UILabel *titleLabel;
    UILabel *dateLabel;
    UILabel *usedTimeLabel;
    UILabel *operatorLabel;
    UILabel *remarkLabel;
}

@property (nonatomic, assign) NSInteger manifestType;
@end

@implementation JCHRestaurantManifestDetailHeaderView

- (id)initWithType:(NSInteger)manifestType
{
    self = [super init];
    if (self) {
        self.manifestType = manifestType;
        self.viewHeight = 102;
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
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"单号："
                                      font:labelFont
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.top.equalTo(self).with.offset(labelTopOffset);
        make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    dateLabel = [JCHUIFactory createLabel:CGRectZero
                                    title:@"日期："
                                     font:labelFont
                                textColor:JCHColorMainBody
                                   aligin:NSTextAlignmentLeft];
    [self addSubview:dateLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    usedTimeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"时间"
                                         font:labelFont
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    usedTimeLabel.clipsToBounds = YES;
    [self addSubview:usedTimeLabel];
    
    [usedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dateLabel.mas_right);
        make.top.equalTo(dateLabel);
        make.width.equalTo(dateLabel);
        make.height.mas_equalTo(labelHeight);
    }];
    
    operatorLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"开单人"
                                         font:labelFont
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    operatorLabel.clipsToBounds = YES;
    [self addSubview:operatorLabel];
    
    [operatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateLabel.mas_bottom);
        make.left.equalTo(dateLabel.mas_left);
        make.right.equalTo(self).with.offset(-kStandardRightMargin);
        make.height.mas_equalTo(labelHeight);
    }];

    remarkLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"客户："
                                       font:labelFont
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    remarkLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:remarkLabel];
    
    [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(operatorLabel);
        make.top.equalTo(operatorLabel.mas_bottom);
        make.width.equalTo(operatorLabel);
        make.height.mas_equalTo(labelHeight);
    }];
    
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

- (void)setViewData:(JCHRestaurantManifestDetailHeaderViewData *)viewData
{
    titleLabel.text = [NSString stringWithFormat:@"桌号: %@    人数: %d    菜品: %d",
                       viewData.deskNumber, (int)viewData.personCount, (int)viewData.dishesCount];
    dateLabel.text = viewData.manifestDate;
    if (YES == viewData.hasFinished) {
        usedTimeLabel.text = [NSString stringWithFormat:@"已开: %@", viewData.usedTime];
    } else {
        usedTimeLabel.text = [NSString stringWithFormat:@"就餐: %@", viewData.usedTime];
    }
    
    operatorLabel.text = [NSString stringWithFormat:@"开单人: %@", viewData.manifestOperator];
    remarkLabel.text = [NSString stringWithFormat:@"备注: %@", viewData.remark];
    
    return;
}


@end
