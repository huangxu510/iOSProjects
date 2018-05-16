//
//  JCHShopInfoManageProVersionInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopInfoManageProVersionInfoView.h"
#import "CommonHeader.h"

@implementation JCHShopInfoManageProVersionInfoView
{
    UILabel *_titleLabel;
    UILabel *_dateEndLabel;
    UILabel *_remainingDaysLabel;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"银麦会员服务时间"
                                           font:[UIFont jchSystemFontOfSize:15.0f]
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
        [self addSubview:_titleLabel];
        
        CGSize fitSize = [_titleLabel sizeThatFits:CGSizeZero];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.and.bottom.equalTo(self);
            make.width.mas_equalTo(fitSize.width);
        }];
        
        _dateEndLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:[UIFont jchSystemFontOfSize:12.0f]
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
        [self addSubview:_dateEndLabel];
        
        [_dateEndLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel.mas_right).with.offset(kStandardLeftMargin);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.top.equalTo(self).with.offset(4);
            make.bottom.equalTo(self.mas_centerY);
        }];
        
        _remainingDaysLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@""
                                                   font:[UIFont jchSystemFontOfSize:12.0f]
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentRight];
        [self addSubview:_remainingDaysLabel];
        
        [_remainingDaysLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.equalTo(_dateEndLabel);
            make.top.equalTo(self.mas_centerY);
        }];
        [self loadData];
    }
    return self;
}

- (void)loadData
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    
    if (addedServiceManager.level == kJCHAddedServiceSiverLevel) {
        _titleLabel.text = @"银麦会员服务时间";
    } else if (addedServiceManager.level == kJCHAddedServiceGoldLevel) {
        _titleLabel.text = @"金麦会员服务时间";
    }
    
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endTime = [dateFormater dateFromString:addedServiceManager.endTime];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSString *endTimeString = [dateFormater stringFromDate:endTime];
    _dateEndLabel.text = [NSString stringWithFormat:@"服务到期时间: %@", endTimeString];
    _remainingDaysLabel.text = [NSString stringWithFormat:@"剩余%ld天", addedServiceManager.remainingDays];
}

@end
