//
//  JCHUserInfoUserHeadImageSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHUserInfoUserHeadImageSelectViewController.h"
#import "JCHUserInfoViewController.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "ServiceFactory.h"

@implementation JCHUserInfoUserHeadImageSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"选择图像";
    self.view.backgroundColor = JCHColorGlobalBackground;
    [self createUI];
}

- (void)createUI
{
    CGFloat buttonHeight = 85;
    CGFloat buttonWidth = kScreenWidth / 3;
    CGFloat buttonImageWidth = 65;
    CGFloat buttonImageHeight = 65;
    CGFloat selectImageWidth = 23;
    CGFloat selectImageHeight = 23;
    CGFloat buttonImageHorizontalGap = (buttonWidth - buttonImageWidth) / 2;
    CGFloat buttonImageVerticalGap = (buttonHeight - buttonImageHeight) / 2;
    
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    
    for (NSInteger i = 0; i < 5; i++)
    {
        CGFloat buttonY = i / 3 * buttonHeight;
        UIButton *headImageButton = [JCHUIFactory createButton:CGRectMake(i % 3 * buttonWidth, buttonY, buttonWidth, buttonHeight)
                                                        target:self
                                                        action:@selector(handleSelectTheImage:)
                                                         title:nil
                                                    titleColor:nil
                                               backgroundColor:nil];
        headImageButton.tag = i + 1;
        NSString *imageName = [NSString stringWithFormat:@"avatar_%ld", (long)i + 1];
        [headImageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.view addSubview:headImageButton];
        
       
        UIImageView *selectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_selected"]] autorelease];
        selectImageView.frame = CGRectMake(buttonWidth - (buttonImageHorizontalGap + selectImageWidth), buttonHeight - (buttonImageVerticalGap + selectImageHeight), selectImageWidth, selectImageHeight);
        selectImageView.layer.cornerRadius = selectImageWidth / 2;
        selectImageView.clipsToBounds = YES;
        selectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        selectImageView.layer.borderWidth = 1;
        selectImageView.hidden = YES;
        if ([manager.headImageName isEqualToString:imageName]) {
            selectImageView.hidden = NO;
        }
        [headImageButton addSubview:selectImageView];
    }
}

- (void)handleSelectTheImage:(UIButton *)sender
{
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    manager.headImageName = [NSString stringWithFormat:@"avatar_%ld", (long)sender.tag];
    [JCHSyncStatusManager writeToFile];
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:manager.userID];
    bookMemberRecord.avatarUrl = [NSString stringWithFormat:@"file://avatar_%ld", (long)sender.tag];

    //更新所有账本中的book member信息
    [ServiceFactory updateBookMemberInAllAccountBook:manager.userID bookMember:bookMemberRecord];
    
    //由上个页面将用户信息上传到服务器
    NSArray *viewControllers = self.navigationController.viewControllers;
    JCHUserInfoViewController *userInfoVierController = viewControllers[viewControllers.count - 2];
    [userInfoVierController doUpdateUserProfile];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
