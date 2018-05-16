//
//  JCHSettlementTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettlementTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHSettlementTableViewCellData

- (void)dealloc
{
    [self.imageName release];
    [self.titleText release];
    [self.detailText release];
    
    [super dealloc];
}

@end

@implementation JCHSettlementTableViewCell
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UIButton *_rightButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:64.0f];
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:64.0f];
    CGFloat buttonheight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:31.0f];
    
    _iconImageView = [[[UIImageView alloc] init] autorelease];
    [self.contentView addSubview:_iconImageView];
    
    [_iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.and.height.mas_equalTo(imageViewWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    _rightButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleButtonAction)
                                        title:@""
                                   titleColor:JCHColorBlueButton backgroundColor:[UIColor whiteColor]];
    _rightButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    _rightButton.layer.cornerRadius = 4;
    _rightButton.clipsToBounds = YES;
    _rightButton.layer.borderColor = JCHColorBlueButton.CGColor;
    _rightButton.layer.borderWidth = 1;
    
    
  
    [self.contentView addSubview:_rightButton];
    
    [_rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonheight);
        make.centerY.equalTo(self.contentView);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"微信支付通道"
                                       font:[UIFont jchSystemFontOfSize:17.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    CGSize fitSize = [_titleLabel sizeThatFits:CGSizeZero];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_rightButton).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
    
    _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@"由微信提供结算服务"
                                        font:[UIFont jchSystemFontOfSize:15.0f]
                                   textColor:JCHColorAuxiliary
                                      aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_detailLabel];
    
    fitSize = [_detailLabel sizeThatFits:CGSizeZero];
    
    [_detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_rightButton).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
}

- (void)handleButtonAction
{
    if ([self.delegate respondsToSelector:@selector(handleJCHSettlementTableViewCellDelegateClick:)]) {
        [self.delegate handleJCHSettlementTableViewCellDelegateClick:self];
    }
}

- (void)setCellData:(JCHSettlementTableViewCellData *)data
{
    _iconImageView.image = [UIImage imageNamed:data.imageName];
    _titleLabel.text = data.titleText;
    _detailLabel.text = data.detailText;
  
    if (data.settlementStatus == kJCHSettlementStatusApply) {
        
        _rightButton.enabled = YES;
        [_rightButton setTitle:@"申请" forState:UIControlStateNormal];
        _rightButton.layer.borderColor = JCHColorBlueButton.CGColor;
        [_rightButton setTitleColor:JCHColorBlueButton forState:UIControlStateNormal];
    } else if (data.settlementStatus == kJCHSettlementStatusHasApply) {
        
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"已申请" forState:UIControlStateDisabled];
        _rightButton.layer.borderColor = JCHColorAuxiliary.CGColor;
        [_rightButton setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
    }  else if (data.settlementStatus == kJCHSettlementStatusOnAuditing) {
        
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"审核中" forState:UIControlStateDisabled];
        _rightButton.layer.borderColor = JCHColorAuxiliary.CGColor;
        [_rightButton setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
    }else if (data.settlementStatus == kJCHSettlementStatusOpen) {
        
        _rightButton.enabled = YES;
        [_rightButton setTitle:@"开通" forState:UIControlStateNormal];
        _rightButton.layer.borderColor = UIColorFromRGB(0xff6400).CGColor;
        [_rightButton setTitleColor:UIColorFromRGB(0xff6400) forState:UIControlStateNormal];
    } else if (data.settlementStatus == kJCHSettlementStatusHasOpen){
        
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"已开通" forState:UIControlStateDisabled];
        _rightButton.layer.borderColor = JCHColorAuxiliary.CGColor;
        [_rightButton setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
    } else if (data.settlementStatus == kJCHSettlementStatusDisable) {
        
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"申请" forState:UIControlStateDisabled];
        _rightButton.layer.borderColor = JCHColorAuxiliary.CGColor;
        [_rightButton setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
    }
        
}


@end
