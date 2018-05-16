//
//  JCHValueAddedServiceView.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddedServicePackageView.h"
#import "CommonHeader.h"

@implementation JCHAddedServicePackageViewData

- (void)dealloc
{
    self.duration = nil;
    [super dealloc];
}

@end


@implementation JCHAddedServicePackageView
{
    UILabel *_durationLabel;
    UILabel *_priceLabel;
    UIImageView *_hotMarkImageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xfdf1e5);
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 4.0f;
        self.layer.borderColor = UIColorFromRGB(0xeda459).CGColor;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat durationLabelLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:9 * kSizeScaleFrom5S];
    CGFloat durationLabelTopOffset = durationLabelLeftOffset;
    
    _durationLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:[UIFont jchSystemFontOfSize:21.0f]
                                     textColor:UIColorFromRGB(0xad671f)
                                        aligin:NSTextAlignmentLeft];
    [self addSubview:_durationLabel];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(durationLabelLeftOffset);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(self).with.offset(durationLabelTopOffset);
        make.centerY.equalTo(self);
    }];
    
    _priceLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"¥240.00"
                                       font:[UIFont jchSystemFontOfSize:14.0f]
                                  textColor:UIColorFromRGB(0xad671f)
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_priceLabel];
    
    CGSize fitSize = [_priceLabel sizeThatFits:CGSizeZero];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX);
        make.right.equalTo(self).with.offset(-durationLabelLeftOffset);
        make.bottom.equalTo(_durationLabel);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
    
    _hotMarkImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"valueAddedService_hot"]] autorelease];
    _hotMarkImageView.hidden = YES;
    
    [self addSubview:_hotMarkImageView];
    
    [_hotMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.equalTo(self);
        make.width.mas_equalTo(41 * kSizeScaleFrom5S);
        make.height.mas_equalTo(29 * kSizeScaleFrom5S);
    }];
}

- (void)setViewData:(JCHAddedServicePackageViewData *)data
{
    NSString *duration = [NSString stringWithFormat:@"%@个月", data.duration];
    NSMutableAttributedString *attrDuration = [[[NSMutableAttributedString alloc] initWithString:duration attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xad671f), NSFontAttributeName : [UIFont jchSystemFontOfSize:21.0f]}] autorelease];
    [attrDuration setAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xad671f), NSFontAttributeName : [UIFont jchSystemFontOfSize:14.0f]} range:NSMakeRange(duration.length - 2, 2)];
    
    _durationLabel.attributedText = attrDuration;
    
    NSString *price = [NSString stringWithFormat:@"¥%.2f", data.price];
    _priceLabel.text = price;
    
    _hotMarkImageView.hidden = data.hotMarkImageHidden;
}

@end
