//
//  JCHJournalAccountTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHJournalAccountTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import <Masonry.h>

@implementation JCHJournalAccountTableViewCellData

- (void)dealloc
{
    [self.date release];
    [self.manifestID release];

    [super dealloc];
}


@end

@implementation JCHJournalAccountTableViewCell

{
    UIImageView *_iconImageView;
    UILabel *_dateLabel;
    UILabel *_journalAccountTypeLabel;
    UILabel *_valueLabel;
    UIButton *_showMenuButton;
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
    UIFont *labelFont = [UIFont systemFontOfSize:15.0f];
    CGFloat headImageViewWidth = 42.0f;
    
    _iconImageView = [[[UIImageView alloc] init] autorelease];
    _iconImageView.layer.cornerRadius = headImageViewWidth / 2;
    _iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(headImageViewWidth);
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
    }];
    
    _journalAccountTypeLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"充值"
                                                    font:labelFont
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_journalAccountTypeLabel];
    
    [_journalAccountTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(_iconImageView);
        make.height.mas_equalTo(headImageViewWidth / 2);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(kStandardLeftMargin);
    }];
    
    
    _dateLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(13)
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_dateLabel];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_journalAccountTypeLabel);
        make.top.equalTo(_journalAccountTypeLabel.mas_bottom);
        make.bottom.equalTo(_iconImageView);
    }];
    
   
    _valueLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont systemFontOfSize:17.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_valueLabel];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_journalAccountTypeLabel.mas_right);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    _showMenuButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(showMenu:)
                                           title:nil
                                      titleColor:nil
                                 backgroundColor:nil];
    [_showMenuButton setImage:[UIImage imageNamed:@"manifest_more_normal"] forState:UIControlStateNormal];
    [_showMenuButton setImage:[UIImage imageNamed:@"manifest_more_active"] forState:UIControlStateSelected];
    [self.contentView addSubview:_showMenuButton];
    _showMenuButton.hidden = YES;
    
    [_showMenuButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.width.mas_equalTo(52);
        make.height.mas_equalTo(41);
        make.top.equalTo(self.contentView.mas_top).with.offset(4);
    }];
}


- (void)setCellData:(JCHJournalAccountTableViewCellData *)data
{
    _dateLabel.text = data.date;
    UIColor *increaseColor = JCHColorHeaderBackground;
    UIColor *decreaseColor = JCHColorMainBody;
    
    switch (data.manifestType) {
        case kJCHOrderShipment:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_shipment"];
        }
            break;
            
        case kJCHOrderPurchases:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_purchase"];
        }
            break;
            
        case kJCHOrderShipmentReject:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_refund"];
        }
            break;
            
        case kJCHOrderPurchasesReject:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_refund"];
        }
            break;
            
        case kJCHManifestCardRecharge:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_recharge"];
        }
            break;
            
        case kJCHManifestCardRefund:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_refund"];
        }
            break;
            
        case kJCHOrderModifyBalance:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_adjustment"];
        }
            break;
            
        case kJCHOrderTransferAccount:
        {
           
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_transfer"];
        }
            break;
            
        case kJCHManifestExtraIncome:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_income"];
        }
            break;
            
        case kJCHManifestExtraExpenses:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_expense"];
        }
            break;
            
            default:
        {
            _iconImageView.image = [UIImage imageNamed:@"journalAccount_other"];
        }
            break;
    }
    
    if (data.value >= 0) {
        
        _valueLabel.textColor = increaseColor;
        _valueLabel.text = [NSString stringWithFormat:@"¥ %.2f", data.value];
    } else {
        
        _valueLabel.textColor = decreaseColor;
        _valueLabel.text = [NSString stringWithFormat:@"- ¥ %.2f", fabs(data.value)];
    }
    _journalAccountTypeLabel.text = data.manifestDescription;
}

- (void)showMenu:(UIButton *)button
{
    if (button.selected) {
        [self hideUtilityButtonsAnimated:YES];
    } else {
        [self showRightUtilityButtonsAnimated:YES];
    }
}

@end
