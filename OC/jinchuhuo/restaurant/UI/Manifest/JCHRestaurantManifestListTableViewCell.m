//
//  JCHRestaurantManifestListTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 2016/12/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestListTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "CommonHeader.h"

enum {
    kManifestCellCountLabelWidth = 120,
};


@interface JCHRestaurantManifestListTableViewCell ()
{
    UILabel *manifestOrderIDLabel;
    UILabel *manifestOrderDateLabel;
    UILabel *manifestOrderAmountLabel;
    UILabel *manifestRemarkLabel;
    UILabel *usedTimeLabel;
    UIButton *showMenuButton;
    UIView *bottomLine;
    UILabel *productCountTitleLabel;
    UILabel *productCountLabel;
    UILabel *operatorLabel;
}
@end

@implementation JCHRestaurantManifestListTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
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
    manifestOrderIDLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"aa"
                                                font:JCHFont(13)
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentLeft];
    //manifestOrderIDLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:manifestOrderIDLabel];
    
    manifestOrderDateLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"00"
                                                  font:JCHFont(12)
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentLeft];
    //manifestOrderDateLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:manifestOrderDateLabel];
    
    usedTimeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"00"
                                         font:JCHFont(12)
                                    textColor:JCHColorHeaderBackground
                                       aligin:NSTextAlignmentLeft];
    //manifestOrderDateLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:usedTimeLabel];
    
    manifestOrderAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"88"
                                                    font:JCHFont(16)
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentRight];
    //manifestOrderAmountLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:manifestOrderAmountLabel];
    
    manifestRemarkLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"备注:"
                                               font:JCHFont(12)
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:manifestRemarkLabel];
    
    showMenuButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(showMenu:)
                                          title:nil
                                     titleColor:nil
                                backgroundColor:nil];
    [showMenuButton setImage:[UIImage imageNamed:@"manifest_more_normal"] forState:UIControlStateNormal];
    [showMenuButton setImage:[UIImage imageNamed:@"manifest_more_active"] forState:UIControlStateSelected];
    [self.contentView addSubview:showMenuButton];
    
    productCountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@""
                                                  font:JCHFont(13)
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentRight];
    [self.contentView addSubview:productCountTitleLabel];
    
    productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"0个"
                                             font:JCHFont(14)
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentRight];
    [self.contentView addSubview:productCountLabel];
    
    operatorLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(12)
                                    textColor:JCHColorAuxiliary
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:operatorLabel];
    
    bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:bottomLine];
    
    
    UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.contentView.frame.size.height)] autorelease];
    selectedBackgroundView.backgroundColor = JCHColorSelectedBackground;
    self.selectedBackgroundView = selectedBackgroundView;
    
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    const CGFloat imageHeight = 15;
    const CGFloat imageWidth = imageHeight;
    
    const CGFloat manifestOrderIDLabelHeight = 18.0f;
    const CGFloat manifestOrderIDLabelWidth = (kScreenWidth - imageWidth - 3 * kStandardLeftMargin) * 2 / 3;
    const CGFloat manifestOrderAmountLabelHeight = 20.0f;
    
    [manifestOrderIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(manifestOrderIDLabelWidth);
        make.height.mas_equalTo(manifestOrderIDLabelHeight);
        make.top.equalTo(self.contentView.mas_top).with.offset(kStandardLeftMargin);
    }];
    
    [operatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestOrderIDLabel.mas_left);
        make.width.mas_equalTo(manifestOrderIDLabelWidth);
        make.height.mas_equalTo(manifestOrderIDLabelHeight);
        make.top.equalTo(manifestOrderIDLabel.mas_bottom);
    }];
    
    [manifestOrderDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestOrderIDLabel);
        make.width.mas_equalTo(150);
        make.top.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(manifestOrderIDLabelHeight);
    }];
    
    [usedTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestOrderDateLabel.mas_right);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardRightMargin);
        make.top.equalTo(manifestOrderDateLabel.mas_top);
        make.height.mas_equalTo(manifestOrderIDLabelHeight);
    }];
    
    [manifestRemarkLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestOrderDateLabel);
        make.right.equalTo(manifestOrderDateLabel);
        make.top.equalTo(manifestOrderDateLabel.mas_bottom);
        make.height.equalTo(manifestOrderDateLabel);
    }];
    
    [showMenuButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.width.mas_equalTo(52);
        make.height.mas_equalTo(41);
        make.centerY.equalTo(manifestOrderIDLabel);
    }];
    
    [manifestOrderAmountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(manifestRemarkLabel.mas_bottom);
        make.height.mas_equalTo(manifestOrderAmountLabelHeight);
        make.right.equalTo(self.contentView).with.offset(-kStandardRightMargin);
        make.left.equalTo(manifestOrderIDLabel.mas_right).offset(kStandardLeftMargin);
    }];
    
    [productCountTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(manifestOrderIDLabel);
        make.left.equalTo(manifestOrderIDLabel.mas_right);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productCountTitleLabel.mas_bottom);
        make.left.right.equalTo(productCountTitleLabel);
        make.height.mas_equalTo(20);
    }];
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).mas_offset(-kStandardLeftMargin);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (void)setCellData:(ManifestInfo *)cellData
{
    productCountTitleLabel.hidden = YES;
    productCountLabel.hidden = YES;
    manifestOrderAmountLabel.hidden = NO;
    operatorLabel.hidden = NO;
    manifestRemarkLabel.hidden = NO;
    
    manifestOrderIDLabel.text = cellData.manifestOrderID;
    manifestOrderDateLabel.text = [NSString stringWithFormat:@"开单时间：%@", cellData.manifestDate];
    manifestOrderAmountLabel.text = [NSString stringWithFormat:@"¥ %@", cellData.manifestAmount];
    manifestRemarkLabel.text = [NSString stringWithFormat:@"备注：%@", cellData.manifestRemark];
    productCountLabel.text = [NSString stringWithFormat:@"%ld个", cellData.manifestProductCount];
    
    if (YES == cellData.hasFinished) {
        usedTimeLabel.textColor = JCHColorAuxiliary;
        usedTimeLabel.text = [NSString stringWithFormat:@"就餐: %@", cellData.usedTime];
    } else {
        usedTimeLabel.textColor = JCHColorHeaderBackground;
        usedTimeLabel.text = [NSString stringWithFormat:@"已开: %@", cellData.usedTime];
    }
    
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", cellData.operatorID]];
    NSString *manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
    operatorLabel.text = [NSString stringWithFormat:@"开单人：%@", manifestOperator];
    
}

- (void)showMenu:(UIButton *)button
{
    if (button.selected) {
        [self hideUtilityButtonsAnimated:YES];
    } else {
        [self showRightUtilityButtonsAnimated:YES];
    }
}

- (void)setButtonStateSelected:(BOOL)selected
{
    showMenuButton.selected = selected;
}


- (void)hideShowMenuButton:(BOOL)hidden
{
    if (hidden) {
        showMenuButton.hidden = YES;
    }
    else
    {
        showMenuButton.hidden = NO;
    }
}

@end
