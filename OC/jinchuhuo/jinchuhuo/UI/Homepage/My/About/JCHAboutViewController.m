//
//  JCHAboutViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "JCHAboutViewController.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHAboutTableViewCell.h"
#import "JCHColorSettings.h"
#import "UIView+JCHView.h"
#import "Masonry.h"

@interface JCHAboutViewController () <MFMailComposeViewControllerDelegate>
{
    UIImageView *logoImageView;
    UILabel *appVersionLabel;
    
    UITableView *contentTableView;
    UILabel *copyrightLabel;
}
@end

@implementation JCHAboutViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.title = @"关于我们";
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
    [self createUI];

    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    const CGFloat imageViewOffset = 55;
    const CGFloat imageViewHeight = 79;
    const CGFloat labelOffset = 11;
    const CGFloat labelHeight = 20;
    const CGFloat tableViewOffset = 55;
    const CGFloat tableViewHeight = 44 * 3;
    
    CGFloat currentImageViewOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:imageViewOffset];
    CGFloat currentImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:imageViewHeight];
    CGFloat currentLabelOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:labelOffset];
    CGFloat currentLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:labelHeight];
    CGFloat currentTableTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:tableViewOffset];
    CGFloat copyrightLabelBottomOffset = 20.0f;
    
    logoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:logoImageView];
    logoImageView.image = [UIImage imageNamed:@"about_logo"];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(currentImageViewOffset);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(currentImageViewHeight);
        make.height.mas_equalTo(currentImageViewHeight);
    }];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
#if MMR_RESTAURANT_VERSION
    NSString *appName = @"买卖人餐饮";
#elif MMR_TAKEOUT_VERSION
    NSString *appName = @"买卖人外卖";
#else
    NSString *appName = @"买卖人开店";
#endif
    
    NSString *appVersionTitle = [NSString stringWithFormat:@"%@ %@ 版", appName, appVersion];
    appVersionLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:appVersionTitle
                                           font:[UIFont jchSystemFontOfSize:16.0f]
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentCenter];
    [self.view addSubview:appVersionLabel];
    [appVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).with.offset(currentLabelOffset);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(0.5);
        make.height.mas_equalTo(currentLabelHeight);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(appVersionLabel.mas_bottom).with.offset(currentTableTopOffset);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(tableViewHeight);
    }];
    
//    [contentTableView layoutIfNeeded];
    [contentTableView addSeparateLineWithMasonryTop:YES bottom:YES];
    
//    UIView *bottomLine = [[[UIView alloc] init] autorelease];
//    bottomLine.backgroundColor = JCHColorSeparateLine;
//    [self.view addSubview:bottomLine];
//    
//    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(contentTableView);
//        make.right.equalTo(contentTableView);
//        make.bottom.equalTo(contentTableView);
//        make.height.mas_equalTo(kSeparateLineWidth);
//    }];
   
    copyrightLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"Copyright © 2016 买卖人 版权所有"
                                          font: [UIFont systemFontOfSize:12]
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentCenter];
    [self.view addSubview:copyrightLabel];
    
    [copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-copyrightLabelBottomOffset);
        make.height.mas_equalTo(currentLabelHeight);
    }];
    
    return;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titleArray = @[@"官方网站", @"微信公众号", @"加入我们"];
    NSArray *subTitleArray = @[@"www.maimairen.com", @"买卖人", @""];
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHAboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.detailTitleLabel.text = [subTitleArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        [self handleSendDataByEmail:nil];
    }
}

- (void)handleSendDataByEmail:(id)sender
{
    if (NO == [MFMailComposeViewController canSendMail]){
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"您iPhone上的 \"邮件\" 应用程序没有绑定任何邮箱地址，请绑定后给我们发送邮件。"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
    [mailController setMailComposeDelegate:self];
    [mailController setSubject:@""];
    [mailController setToRecipients:@[@"hr@maimairen.com"]];
    [mailController setBccRecipients:@[]];
    [mailController setMessageBody:@"" isHTML:NO];

    
    // 弹出邮件发送视图
    [self presentViewController:mailController
                       animated:YES
                     completion:nil];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"取消发送邮件.");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"保存草稿");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"发送成功");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"发送失败: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
