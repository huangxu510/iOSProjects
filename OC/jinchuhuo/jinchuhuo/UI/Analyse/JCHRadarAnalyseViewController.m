//
//  JCHAnalyseRadarViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHRadarAnalyseViewController.h"
#import "JCHClientAnalyseViewController.h"
#import "JCHAnalyseComponentView.h"
#import "JCHBarChartAnalyseViewController.h"
#import "JCHInventoryAnalyseViewController.h"
#import "JCHBarChartAnalyseViewController.h"
#import "JCHInventoryAnalyseViewController.h"
#import "JCHAnalyseIntroductionView.h"
#import "JCHRadarView.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "CommonHeader.h"
#import <Masonry.h>
#import <KLCPopup.h>

@interface JCHRadarAnalyseViewController () <JCHRadarViewDelegate>
{
    UILabel *_updateDataLabel;
    JCHRadarView *_radarView;
    UILabel *_turnoverDaysLabel;
    UILabel *_moveOffRateLabel;

    BOOL _apperarFromPop;
}


@end

@implementation JCHRadarAnalyseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"分析";
    [self createUI];
    

    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_apperarFromPop) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        _apperarFromPop = NO;
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)createUI
{
    CGFloat topViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:357];
    UIView *topContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, topViewHeight)] autorelease];
    [self.view addSubview:topContainerView];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = topContainerView.bounds;
    [topContainerView.layer addSublayer:gradientLayer];
    
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);

    
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0x0094ff).CGColor, (__bridge id)UIColorFromRGB(0x5bbefe).CGColor];
    //gradientLayer.locations = @[@(0.5f), @(0.5f)];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"分析"
                                               font:[UIFont boldSystemFontOfSize:18.0]
                                          textColor:[UIColor whiteColor]
                                             aligin:NSTextAlignmentCenter];
    [topContainerView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainerView).with.offset(kStatusBarHeight);
        make.height.mas_equalTo(kNavigatorBarHeight);
        make.centerX.equalTo(topContainerView);
        make.width.mas_equalTo(150);
    }];
    
    CGFloat infoLabelHeight = 20;
    UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"运营指数是根据以下五个维度综合评估而来"
                                              font:JCHFont(10)
                                         textColor:[UIColor whiteColor]
                                            aligin:NSTextAlignmentCenter];
    [topContainerView addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(infoLabelHeight);
        make.left.equalTo(topContainerView).with.offset(kStandardLeftMargin);
        make.centerX.equalTo(topContainerView);
    }];
    
    _updateDataLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"更新于 2016-08-03 12:12"
                                            font:JCHFont(10)
                                       textColor:RGBColor(255, 255, 255, 0.6)
                                          aligin:NSTextAlignmentCenter];
    [topContainerView addSubview:_updateDataLabel];
    
    [_updateDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoLabel.mas_bottom);
        make.left.right.height.equalTo(infoLabel);
    }];
    
    CGFloat radarViewMinY = 64 + 2 * infoLabelHeight;
    
    _radarView = [[[JCHRadarView alloc] initWithFrame:CGRectMake(0, radarViewMinY, kScreenWidth, topViewHeight - radarViewMinY)] autorelease];
    _radarView.delegate = self;
    [topContainerView addSubview:_radarView];
    
    UIView *bottomContainerView = [[[UIView alloc] init] autorelease];
    bottomContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomContainerView];
    
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(topContainerView.mas_bottom);
    }];
    
    CGFloat buttonHeight = (kScreenHeight - topViewHeight - kTabBarHeight) / 4;
    CGFloat buttonWidth = kScreenWidth / 2;
    NSArray *titles = @[@"库存周转", @"动销率", @"进货分析", @"出货分析", @"毛利分析", @"库存分析", @"客户分析", @"店员统计"];
    NSArray *imageNames = @[@"ic_analysis_purchase", @"ic_analysis_shipment", @"ic_analysis_profit", @"ic_analysis_stock", @"ic_analysis_customer", @"ic_analysis_clerk"];
    for (NSInteger i = 0; i < 8; i++) {
        CGRect frame = CGRectMake(i % 2 * buttonWidth, i / 2 * buttonHeight, buttonWidth, buttonHeight);
        
        if (i < 2) {
            UIView *dataContainerView = [[[UIView alloc] initWithFrame:frame] autorelease];
            [bottomContainerView addSubview:dataContainerView];
            
            CGFloat dataLabelHeight = buttonHeight * 0.5;
            CGFloat dataLabelTopOffset = buttonHeight * 0.15;
            CGFloat infoLabelHeight = buttonHeight * 0.3;
            
            UILabel *dataLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"20天"
                                                      font:[UIFont jchBoldSystemFontOfSize:19]
                                                 textColor:UIColorFromRGB(0xdd4041)
                                                    aligin:NSTextAlignmentCenter];
            [dataContainerView addSubview:dataLabel];
            
            [dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(dataContainerView).with.offset(dataLabelTopOffset);
                make.height.mas_equalTo(dataLabelHeight);
                make.right.equalTo(dataContainerView).with.offset(-kStandardLeftMargin);
                make.left.equalTo(dataContainerView).with.offset(kStandardLeftMargin);
            }];
            
            UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:titles[i]
                                                      font:JCHFont(12.0)
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentCenter];
            [dataContainerView addSubview:infoLabel];
            
            [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(dataLabel.mas_bottom);
                make.height.mas_equalTo(infoLabelHeight);
                make.left.right.equalTo(dataLabel);
            }];
            
            if (i == 0) {
                _turnoverDaysLabel = dataLabel;
            } else {
                _moveOffRateLabel = dataLabel;
            }
        } else {
            UIButton *button = [JCHUIFactory createButton:frame
                                                   target:self
                                                   action:@selector(buttonClick:)
                                                    title:titles[i]
                                               titleColor:JCHColorMainBody
                                          backgroundColor:[UIColor whiteColor]];
            button.tag = i;
            button.titleLabel.font = JCHFont(15);
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [button setImage:[UIImage imageNamed:imageNames[i - 2]] forState:UIControlStateNormal];
            [button addSeparateLineWithMasonryTop:YES bottom:NO];
            [bottomContainerView addSubview:button];
            [button setBackgroundImage:[UIImage imageWithColor:JCHColorGlobalBackground] forState:UIControlStateHighlighted];
            button.adjustsImageWhenHighlighted = NO;
            
            if (i == 7){
                //[button setImage:[UIImage imageNamed:@""] forState:UIControlStateDisabled];
                
                NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:@"店员统计\n(即将发布)"] autorelease];;
                NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
                paragraphStyle.lineSpacing = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:5];
                paragraphStyle.alignment = NSTextAlignmentCenter;
                [attributedString setAttributes:@{NSFontAttributeName : JCHFont(15), NSParagraphStyleAttributeName : paragraphStyle}
                                          range:NSMakeRange(0, 4)];
                
                [attributedString setAttributes:@{NSFontAttributeName : JCHFont(10), NSParagraphStyleAttributeName : paragraphStyle}
                                          range:NSMakeRange(4, attributedString.length - 4)];
                [button setTitle:nil forState:UIControlStateNormal];
                button.titleLabel.numberOfLines = 0;
                [button setAttributedTitle:attributedString forState:UIControlStateNormal];
                button.enabled = NO;
            }
        }
    }
    
    UIView *topVerticalLine = [[[UIView alloc] init] autorelease];
    topVerticalLine.backgroundColor = JCHColorSeparateLine;
    [bottomContainerView addSubview:topVerticalLine];
    
    [topVerticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomContainerView).with.offset(10);
        make.height.mas_equalTo(buttonHeight - 20);
        make.width.mas_equalTo(kSeparateLineWidth);
        make.centerX.equalTo(bottomContainerView);
    }];
    
    UIView *bottomVerticalLine = [[[UIView alloc] init] autorelease];
    bottomVerticalLine.backgroundColor = JCHColorSeparateLine;
    [bottomContainerView addSubview:bottomVerticalLine];
    
    [bottomVerticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomContainerView).with.offset(buttonHeight);
        make.bottom.centerX.equalTo(bottomContainerView);
        make.width.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)buttonClick:(UIButton *)sender
{
    _apperarFromPop = YES;
    JCHBarChartAnalyseViewController *barChartVC = [[[JCHBarChartAnalyseViewController alloc] init] autorelease];
    barChartVC.hidesBottomBarWhenPushed = YES;
    
    switch (sender.tag) {
        case 2:         //进货分析
        {
            if ([JCHPerimissionUtility displayPurchaseAnalysis]) {
                barChartVC.enumAnalyseType = kJCHAnalysePurchase;
                [self.navigationController pushViewController:barChartVC animated:YES];
            } else {
                [self showAlertView];
            }
        }
            break;
            
        case 3:         //出货分析
        {
            if ([JCHPerimissionUtility displayShipmentAnalysis]) {
                barChartVC.enumAnalyseType = kJCHAnalyseShipment;
                [self.navigationController pushViewController:barChartVC animated:YES];
            } else {
                [self showAlertView];
            }
        }
            break;
            
        case 4:         //毛利分析
        {
            if ([JCHPerimissionUtility displayProfitAnalysis]) {
                barChartVC.enumAnalyseType = kJCHAnalyseProfit;
                [self.navigationController pushViewController:barChartVC animated:YES];
            } else {
                [self showAlertView];
            }
        }
            break;
            
        case 5:         //库存分析
        {
            if ([JCHPerimissionUtility displayInventoryAnalysis]) {
                JCHInventoryAnalyseViewController *pieVC = [[[JCHInventoryAnalyseViewController alloc] init] autorelease];
                pieVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pieVC animated:YES];
            } else {
                [self showAlertView];
            }
        }
            break;
            
        case 6:         //客户分析
        {
            JCHClientAnalyseViewController *clientAnalyseViewController = [[[JCHClientAnalyseViewController alloc] init] autorelease];
            clientAnalyseViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:clientAnalyseViewController animated:YES];
        }
            break;
            
        case 7:         //店员分析
        {
            
        }
            break;
            
        default:
            break;
    }

}

- (void)showAlertView
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                 message:@"您没有权限查看该报表"
                                                delegate:nil
                                       cancelButtonTitle:@"我知道了"
                                       otherButtonTitles:nil];
    [av show];
}

#pragma mark - JCHRadarViewDelegate
- (void)handleVertexViewClick:(NSInteger)tag
{
    NSArray *titles = @[@"资产效率", @"开单水平", @"现金获取", @"盈利能力", @"负债能力"];
    NSArray *details = @[@"资产效率是衡量资产（含库存和其它资产）管理效率的能力，值越高表明管理资产的能力越强",
                         @"开单能力是从销售时间覆盖和销售品类来衡量开单的能力，值越高表明开单的能力越强",
                         @"现金获取是衡量经营过程中获取现金的能力，值越高表明通过经营获取现金的能力越强",
                         @"盈利能力是衡量经营的利润水平，值越高表明通过经营获取利润的能力越强",
                         @"负债能力是衡量当前经营水平所能承担的负债偿还程度，值越高表明负债可偿还的能力越强"];
    NSMutableArray *imageNamesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        NSString *imageName = [NSString stringWithFormat:@"pic_analysis_guidepage_%ld", i + 1];
        [imageNamesArray addObject:imageName];
    }
    
    const CGFloat height = [JCHSizeUtility calculateWidthWithSourceWidth:417];
    const CGFloat width = [JCHSizeUtility calculateWidthWithSourceWidth:312];
    JCHAnalyseIntroductionView *introductionView = [[[JCHAnalyseIntroductionView alloc] initWithFrame:CGRectMake(0, 0, width, height)
                                                                    titles:titles
                                                                   details:details
                                                                imageNames:imageNamesArray] autorelease];
    introductionView.index = tag;
    
    
    KLCPopup *popupView = [KLCPopup popupWithContentView:introductionView
                                       showType:KLCPopupShowTypeGrowIn
                                    dismissType:KLCPopupDismissTypeFadeOut
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:YES
                          dismissOnContentTouch:NO];

    [popupView show];
    [introductionView setButtonClick:^{
        [popupView dismiss:YES];
    }];
}

#pragma mark - LoadData
- (void)loadData
{
    /**
     *   10 库存周转天数
     1 资产效率
     2 负债能力
     3 盈利能力
     4 现金获取
     5 开单水平
     52 动销率
     */

    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *manageIndexKey = [NSString stringWithFormat:@"%@_ManageIndex", statusManager.accountBookID];
    
    NSDictionary *manageIndexData = [JCHUserDefaults objectForKey:manageIndexKey];
    
    CGFloat manageIndex = [manageIndexData[@"manageIndex"] doubleValue];
    NSInteger manageIndexDetail_10 = [manageIndexData[@"manageIndexDetail_10"] integerValue];
    CGFloat manageIndexDetail_52 = [manageIndexData[@"manageIndexDetail_52"] doubleValue];
    NSNumber *manageIndexDetail_1 = manageIndexData[@"manageIndexDetail_1"];
    NSNumber *manageIndexDetail_2 = manageIndexData[@"manageIndexDetail_2"];
    NSNumber *manageIndexDetail_3 = manageIndexData[@"manageIndexDetail_3"];
    NSNumber *manageIndexDetail_4 = manageIndexData[@"manageIndexDetail_4"];
    NSNumber *manageIndexDetail_5 = manageIndexData[@"manageIndexDetail_5"];
    
    manageIndexDetail_1 = [self switchIndexDetail:manageIndexDetail_1];
    manageIndexDetail_2 = [self switchIndexDetail:manageIndexDetail_2];
    manageIndexDetail_3 = [self switchIndexDetail:manageIndexDetail_3];
    manageIndexDetail_4 = [self switchIndexDetail:manageIndexDetail_4];
    manageIndexDetail_5 = [self switchIndexDetail:manageIndexDetail_5];
    
    
    NSTimeInterval timeInterval = [manageIndexData[@"timestamp"] doubleValue];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *updateDateString = [dateFormatter stringFromDate:updateDate];
    _updateDataLabel.text = [NSString stringWithFormat:@"更新于 %@ (每周一更新)", updateDateString];
    
    _turnoverDaysLabel.text = [NSString stringWithFormat:@"%ld天", manageIndexDetail_10];
    _moveOffRateLabel.text = [NSString stringWithFormat:@"%.2f%%", manageIndexDetail_52 * 100];
    
    //radarView的数据是按逆时针排序的
    //5个指数的范围是0 - 1 转换为 0.2 - 1   n + 0.2 * (1 - n)
    if (manageIndexData == nil) {
        _radarView.manageScore = 350;
        [_radarView setViewData:@[@(0.4), @(0.4), @(0.4), @(0.4), @(0.4)]];
    } else {
        _radarView.manageScore = (NSInteger)[JCHFinanceCalculateUtility roundDownFloatNumber:manageIndex scale:0];
        [_radarView setViewData:@[manageIndexDetail_1, manageIndexDetail_5, manageIndexDetail_4, manageIndexDetail_3, manageIndexDetail_2]];
    }
    
    [_radarView startAnimation];
}

- (NSNumber *)switchIndexDetail:(NSNumber *)indexDetail
{
    CGFloat indexDetailFloat = [indexDetail doubleValue];
    indexDetailFloat = indexDetailFloat * 0.6 + 0.4;
    return @(indexDetailFloat);
}



@end
