//
//  JCHSettlementGuideViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettlementGuideViewController.h"
#import "JCHSettlementViewContrller.h"
#import "JCHHTMLViewController.h"
#import "JCHSettlementGuideView.h"
#import "JCHSettlementManager.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHSettlementGuideViewController ()
{
    UIImageView *logoImageView;
    UILabel *tipsLabel;
    UIButton *openSettlementButton;
}
@end

@implementation JCHSettlementGuideViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"结算通道";
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self queryBindID];
    
    [self createUI];
}

- (void)createUI
{
    logoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    logoImageView.image = [UIImage imageNamed:@"bg_settlement"];
    [self.view addSubview:logoImageView];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:190]);
        make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:185]);
        make.top.equalTo(self.view).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50]);
    }];
    
    UIView *topView = logoImageView;
    {
        JCHSettlementGuideView *guideView = [[[JCHSettlementGuideView alloc] initWithFrame:CGRectZero
                                                                               buttonTitle:@"安全"
                                                                               buttonColor:UIColorFromRGB(0XF79978)
                                                                                labelTitle:@"资金由银行提供结算服务"] autorelease];
        
        [self.view addSubview:guideView];
        
        [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:320]);
            make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:25]);
            make.top.equalTo(topView.mas_bottom).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:30]);
        }];
        
        topView = guideView;
        
    }
    
    {
        JCHSettlementGuideView *guideView = [[[JCHSettlementGuideView alloc] initWithFrame:CGRectZero
                                                                               buttonTitle:@"简单"
                                                                               buttonColor:UIColorFromRGB(0X97C268)
                                                                                labelTitle:@"一键开通微信,支付宝收钱"] autorelease];
        
        [self.view addSubview:guideView];
        
        [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:320]);
            make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:25]);
            make.top.equalTo(topView.mas_bottom).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:21]);
        }];
        
        topView = guideView;
    }
    
    {
        JCHSettlementGuideView *guideView = [[[JCHSettlementGuideView alloc] initWithFrame:CGRectZero
                                                                               buttonTitle:@"免费"
                                                                               buttonColor:UIColorFromRGB(0X87A1D0)
                                                                                labelTitle:@"绑卡免费开户，免费提现"] autorelease];
        
        [self.view addSubview:guideView];
        
        [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:320]);
            make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:25]);
            make.top.equalTo(topView.mas_bottom).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:21]);
        }];
        
        topView = guideView;
    }
    
    tipsLabel = [JCHUIFactory createLabel:CGRectZero
                                    title:@"有任何疑问或者需要协助，\n请拨打热线电话: 400-869-0055"
                                     font:JCHFont(13.0)
                                textColor:UIColorFromRGB(0XA4A4A4)
                                   aligin:NSTextAlignmentCenter];
    tipsLabel.numberOfLines = 2;
    [self.view addSubview:tipsLabel];

    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view);
        make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:45]);
        make.top.equalTo(topView.mas_bottom).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:30]);
    }];
    
    openSettlementButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleOpenSettlement:)
                                                title:@"立即秒开结算通道"
                                           titleColor:[UIColor whiteColor]
                                      backgroundColor:JCHColorHeaderBackground];
    [self.view addSubview:openSettlementButton];
    
    [openSettlementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:345]);
        make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50]);
        make.top.equalTo(tipsLabel.mas_bottom).offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:15]);
    }];
}

- (void)test
{
    
}

- (void)handleOpenSettlement:(id)sender
{
    UIViewController *viewController = nil;
    BOOL accountStatus = [[JCHSettlementManager sharedInstance] getOpenAccountStatus];
    NSString *bindID = [[JCHSettlementManager sharedInstance] getBindID];
    if (nil == bindID) {
        bindID = @"";
    }
    
    if (accountStatus == YES) {
        viewController = [[[JCHSettlementViewContrller alloc] init] autorelease];
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"%@?bindId=%@&UA=iOS&status=0",
                            kCMBCOpenAccountServiceURL,
                            bindID];
        
        viewController = [[[JCHHTMLViewController alloc] initWithURL:urlStr postRequest:NO] autorelease];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)queryBindID
{
    [[JCHSettlementManager sharedInstance] querySettlementMethodStatus:^(NSInteger enableMerchant, NSInteger enableAlipay, NSInteger enableWeiXin, NSString *bindID) {
        NSLog(@"query bind id success");
    } failureHandler:^{
        NSLog(@"query bind id failure");
    }];
}

@end
