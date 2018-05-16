//
//  JCHManifestListTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestListTableViewCell.h"
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


@implementation ManifestInfo

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
    [self.manifestLogoName release];
    [self.manifestOrderID release];
    [self.manifestDate release];
    [self.manifestAmount release];
    [self.manifestRemark release];
    
    [super dealloc];
    return;
}

@end


@interface JCHManifestListTableViewCell ()
{
    UIImageView *manifestLogoImageView;
    UILabel *manifestOrderIDLabel;
    UILabel *manifestOrderDateLabel;
    UILabel *manifestOrderAmountLabel;
    UILabel *manifestRemarkLabel;
    UILabel *returnedLabel;
    UILabel *hasnotPayedLabel;
    UIButton *showMenuButton;
    UIView *bottomLine;
    UILabel *productCountTitleLabel;
    UILabel *productCountLabel;
    UILabel *operatorLabel;
}
@end

@implementation JCHManifestListTableViewCell


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
    manifestLogoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    manifestLogoImageView.image = [UIImage imageNamed:@"icon_jinChuHuo_120px.png"];
    [self.contentView addSubview:manifestLogoImageView];

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

    manifestOrderAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"88"
                                               font:JCHFont(16)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentRight];
    //manifestOrderAmountLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:manifestOrderAmountLabel];

    returnedLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"已退单"
                                         font:JCHFont(16)
                                    textColor:UIColorFromRGB(0xff9532)
                                       aligin:NSTextAlignmentRight];
    returnedLabel.hidden = YES;
    [self.contentView addSubview:returnedLabel];

    hasnotPayedLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"待付款"
                                            font:JCHFont(16)
                                       textColor:UIColorFromRGB(0xff9532)
                                          aligin:NSTextAlignmentRight];
    hasnotPayedLabel.hidden = YES;
    [self.contentView addSubview:hasnotPayedLabel];

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
                                            title:@"商品数量"
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


    [manifestLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(kStandardLeftMargin);
    }];

    
    const CGFloat manifestOrderIDLabelHeight = 18.0f;
    const CGFloat manifestOrderIDLabelWidth = (kScreenWidth - imageWidth - 3 * kStandardLeftMargin) * 2 / 3;
    const CGFloat manifestOrderAmountLabelHeight = 20.0f;
    const CGFloat returnedLabelWidth = 60;
    
    [manifestOrderIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestLogoImageView.mas_right).with.offset(kStandardLeftMargin / 2);
        make.width.mas_equalTo(manifestOrderIDLabelWidth);
        make.height.mas_equalTo(manifestOrderIDLabelHeight);
        make.top.equalTo(manifestLogoImageView);
    }];

    [manifestOrderDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(manifestLogoImageView);
        make.right.equalTo(manifestOrderIDLabel);
        make.top.equalTo(self.contentView.mas_centerY);
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

    [returnedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.width.mas_equalTo(returnedLabelWidth);
        make.top.equalTo(showMenuButton.mas_bottom);
        make.height.mas_equalTo(manifestOrderAmountLabelHeight);
    }];

    [hasnotPayedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(returnedLabel);
    }];

    [manifestOrderAmountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(returnedLabel.mas_bottom);
        make.height.equalTo(returnedLabel);
        make.right.equalTo(returnedLabel);
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
        make.left.and.right.and.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    if (self.manifestType == kJCHManifestInventory || self.manifestType == kJCHManifestMigrate || self.manifestType == kJCHManifestAssembling || self.manifestType == kJCHManifestDismounting) {
        [operatorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(manifestLogoImageView);
            make.right.equalTo(manifestOrderIDLabel);
            make.top.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(manifestOrderIDLabelHeight);
        }];
        
        [manifestOrderDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(operatorLabel);
            make.right.equalTo(operatorLabel);
            make.top.equalTo(operatorLabel.mas_bottom);
            make.height.equalTo(operatorLabel);
        }];
    }
 
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (void)setCellData:(ManifestInfo *)cellData
{
    hasnotPayedLabel.hidden = YES;
    returnedLabel.hidden = YES;
    productCountTitleLabel.hidden = YES;
    productCountLabel.hidden = YES;
    manifestOrderAmountLabel.hidden = YES;
    operatorLabel.hidden = YES;
    manifestRemarkLabel.hidden = YES;
    
    switch (cellData.manifestType) {
        case kJCHOrderPurchases:            // 进货单
        {
            cellData.manifestLogoName = @"manifest_icon_purchase";
            hasnotPayedLabel.text = @"待付款";
            if (cellData.hasPayed) {
                
                hasnotPayedLabel.hidden = YES;
            } else {
                hasnotPayedLabel.hidden = NO;
            }
            
            if (cellData.isManifestReturned) {
                returnedLabel.hidden = NO;
                hasnotPayedLabel.hidden = YES;
            } else {
                returnedLabel.hidden = YES;
            }
            manifestOrderAmountLabel.hidden = NO;
            manifestRemarkLabel.hidden = NO;
        }
            break;
        case kJCHOrderShipment:             // 出货单
        {
            cellData.manifestLogoName = @"manifest_icon_shipment";
            hasnotPayedLabel.text = @"待收款";
            if (cellData.hasPayed) {
                hasnotPayedLabel.hidden = YES;
            } else {
                hasnotPayedLabel.hidden = NO;
            }
            
            if (cellData.isManifestReturned) {
                returnedLabel.hidden = NO;
                hasnotPayedLabel.hidden = YES;
            } else {
                returnedLabel.hidden = YES;
            }
            manifestOrderAmountLabel.hidden = NO;
            manifestRemarkLabel.hidden = NO;
        }
            break;
        case kJCHOrderPurchasesReject:          // 进货退单
        {
            cellData.manifestLogoName = @"dan_icon_tuihuo";
            returnedLabel.text = @"已退单";
            returnedLabel.hidden = NO;
            hasnotPayedLabel.hidden = YES;
            manifestOrderAmountLabel.hidden = NO;
            manifestRemarkLabel.hidden = NO;
        }
            break;
        case kJCHOrderShipmentReject:           // 出货退单
        {
            cellData.manifestLogoName = @"dan_icon_tuihuo";
            returnedLabel.text = @"已退单";
            returnedLabel.hidden = NO;
            hasnotPayedLabel.hidden = YES;
            manifestOrderAmountLabel.hidden = NO;
            manifestRemarkLabel.hidden = NO;
        }
            break;
        case kJCHOrderReceipt:                  // 收款单
        {
            cellData.manifestLogoName = @"dan_icon_zu";
            returnedLabel.text = @"已退单";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.text = @"待收款";
            hasnotPayedLabel.hidden = NO;
        }
            break;
        case kJCHOrderPayment:                  //付款单
        {
            cellData.manifestLogoName = @"dan_icon_zu";
            returnedLabel.text = @"已退单";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.text = @"待付款";
            hasnotPayedLabel.hidden = NO;
        }
            break;
            
        case kJCHManifestInventory:            //盘点单
        {
            cellData.manifestLogoName = @"manifestList_icon_check";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.hidden = YES;
            showMenuButton.hidden = YES;
            productCountTitleLabel.hidden = NO;
            productCountLabel.hidden = NO;
            manifestOrderAmountLabel.hidden = YES;
            operatorLabel.hidden = NO;
            manifestRemarkLabel.hidden = YES;
        }
            break;
            
        case kJCHManifestMigrate:              //移库单
        {
            cellData.manifestLogoName = @"manifest_icon_migrate";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.hidden = YES;
            showMenuButton.hidden = YES;
            productCountTitleLabel.hidden = NO;
            productCountLabel.hidden = NO;
            manifestOrderAmountLabel.hidden = YES;
            operatorLabel.hidden = NO;
            manifestRemarkLabel.hidden = YES;
        }
            break;
        
        case kJCHManifestAssembling:
        {
            cellData.manifestLogoName = @"manifest_icon_assembling";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.hidden = YES;
            showMenuButton.hidden = YES;
            productCountTitleLabel.hidden = NO;
            productCountLabel.hidden = NO;
            manifestOrderAmountLabel.hidden = YES;
            operatorLabel.hidden = NO;
            manifestRemarkLabel.hidden = YES;
        }
            break;
            
        case kJCHManifestDismounting:
        {
            cellData.manifestLogoName = @"manifest_icon_dismounting";
            returnedLabel.hidden = YES;
            hasnotPayedLabel.hidden = YES;
            showMenuButton.hidden = YES;
            productCountTitleLabel.hidden = NO;
            productCountLabel.hidden = NO;
            manifestOrderAmountLabel.hidden = YES;
            operatorLabel.hidden = NO;
            manifestRemarkLabel.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    manifestLogoImageView.image = [UIImage imageNamed:cellData.manifestLogoName];
    manifestOrderIDLabel.text = cellData.manifestOrderID;
    manifestOrderDateLabel.text = [NSString stringWithFormat:@"开单时间：%@", cellData.manifestDate];
    manifestOrderAmountLabel.text = [NSString stringWithFormat:@"¥ %@", cellData.manifestAmount];
    manifestRemarkLabel.text = [NSString stringWithFormat:@"备注：%@", cellData.manifestRemark];
    productCountLabel.text = [NSString stringWithFormat:@"%ld个", cellData.manifestProductCount];
    
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", cellData.operatorID]];
    NSString *manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
    operatorLabel.text = [NSString stringWithFormat:@"盘点人：%@", manifestOperator];
    
    if (cellData.manifestType == kJCHManifestInventory) {
        operatorLabel.text = [NSString stringWithFormat:@"盘点人：%@", manifestOperator];
    } else if (cellData.manifestType == kJCHManifestMigrate) {
        operatorLabel.text = [NSString stringWithFormat:@"移库人：%@", manifestOperator];
    } else if (cellData.manifestType == kJCHManifestAssembling) {
        operatorLabel.text = [NSString stringWithFormat:@"拼装人：%@", manifestOperator];
    } else if (cellData.manifestType == kJCHManifestDismounting) {
        operatorLabel.text = [NSString stringWithFormat:@"拆装人：%@", manifestOperator];
    }
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
