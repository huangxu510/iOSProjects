//
//  JCHShopAssistantTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopAssistantCollectionViewCell.h"
#import "JCHShopAssistantView.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "BookMemberRecord4Cocoa.h"
#import "JCHSyncStatusManager.h"
#import "JCHImageUtility.h"
#import "JCHDisplayNameUtility.h"
#import <Masonry.h>

@interface JCHShopAssistantCollectionViewCell () <JCHShopAssistantViewDelegate>
{
    UIScrollView *_backScrollView;
    CGFloat _defaultViewWidth;
    CGFloat _cellHeight;
}
@end

@implementation JCHShopAssistantCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _defaultViewWidth = 50 + 2 * kStandardLeftMargin;
        _cellHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:100 noStretchingIn6Plus:YES];
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _backScrollView = [[[UIScrollView alloc] init] autorelease];
    _backScrollView.frame = CGRectMake(0, 0, kScreenWidth, _cellHeight);
    _backScrollView.contentSize = CGSizeMake(0, 0);
    _backScrollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_backScrollView];
}

- (void)setData:(NSArray *)data
{
    [_backScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < data.count; i++) {
        JCHShopAssistantView *view = [[[JCHShopAssistantView alloc] initWithFrame:CGRectMake(_defaultViewWidth * i, 0, _defaultViewWidth, _cellHeight)] autorelease];
        view.delegate = self;
        view.tag = i;
        [_backScrollView addSubview:view];
        JCHShopAssistantViewData *viewData = [[[JCHShopAssistantViewData alloc] init] autorelease];
        
        BookMemberRecord4Cocoa *memberRecord = data[i];
        
        //没有备注显示昵称
        viewData.name = [JCHDisplayNameUtility getDisplayRemark:memberRecord];
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        if ([memberRecord.userId isEqualToString:statusManager.userID]) {
            viewData.name = @"我";
        }
        
        
        viewData.headImage = [JCHImageUtility getAvatarImageNameFromAvatarUrl:memberRecord.avatarUrl];
        
        BOOL isShopManager = [ServiceFactory isShopManager:memberRecord.userId
                                             accountBookID:statusManager.accountBookID];
        if (isShopManager) {
            viewData.markImage = @"setting_shopkeeper";
        } else {
            viewData.markImage = @"setting_clerk";
        }

        [view setData:viewData];
    }
    
    if (data.count < 5) {
        
        JCHShopAssistantView *defaultView = [[[JCHShopAssistantView alloc] initWithFrame:CGRectMake(_defaultViewWidth * data.count, 0, _defaultViewWidth, _cellHeight)] autorelease];
        defaultView.delegate = self;
        defaultView.tag = 10000;
        [defaultView.headImageButton setImage:[UIImage imageNamed:@"addclerk_sel"] forState:UIControlStateHighlighted];
        [_backScrollView addSubview:defaultView];
    }
    
    CGFloat contentWidth = CGRectGetMaxX(_backScrollView.subviews.lastObject.frame);
    
    if ((data.count + 1) * _defaultViewWidth > kScreenWidth) {
        _backScrollView.contentSize = CGSizeMake(contentWidth, 0);
    }
}

#pragma mark - JCHShopAssistantViewDelegate

- (void)handleClickView:(JCHShopAssistantView *)view
{
    if (view.tag == 10000) {
        if ([self.cellDelegate respondsToSelector:@selector(handleAddShopAssistant)]) {
            [self.cellDelegate handleAddShopAssistant];
        }
    }
    else
    {
        if ([self.cellDelegate respondsToSelector:@selector(handleShowAssistantInfo:)]) {
            [self.cellDelegate handleShowAssistantInfo:view.tag];
        }
    }
}

@end
