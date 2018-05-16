//
//  JCHShopsContainerView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopsContainerView.h"
#import "CommonHeader.h"
#import "BookInfoRecord4Cocoa.h"
#import "ServiceFactory.h"
#import "JCHShopUtility.h"
#import "JCHSyncStatusManager.h"
#import <Masonry.h>

@implementation JCHShopsComponentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0x575e7b);
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:66.0f];
    CGFloat buttonLeftOffset = (kScreenWidth - buttonWidth * 4) / 8;
    CGFloat buttonTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:16.0f];
    
    CGFloat arrowImageViewWidth = 15.0f;
    
    CGFloat labelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    
    self.shopButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:nil
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:UIColorFromRGB(0x5f6681)];
    self.shopButton.layer.cornerRadius = 4.0f;
    self.clipsToBounds = YES;
    [self addSubview:self.shopButton];
    
    [self.shopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(buttonLeftOffset);
        make.width.mas_equalTo(buttonWidth);
        make.top.self.with.offset(buttonTopOffset);
        make.height.mas_equalTo(buttonWidth);
    }];
    
    self.arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"store_selected"]] autorelease];
    self.arrowImageView.hidden = YES;
    [self.shopButton addSubview:self.arrowImageView];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shopButton.mas_right);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.bottom.equalTo(self.shopButton.mas_bottom);
        make.height.mas_equalTo(arrowImageViewWidth);
    }];
    
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"我的店"
                                               font:[UIFont jchSystemFontOfSize:12.0f]
                                          textColor:[UIColor whiteColor]
                                             aligin:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shopButton);
        make.width.mas_equalTo((kScreenWidth - 20) / 4);
        make.top.equalTo(self.shopButton.mas_bottom);
        make.height.mas_equalTo(labelHeight);
    }];
}

@end

@interface JCHShopsContainerView ()

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSMutableArray *shopCompentViews;
@property (nonatomic, retain) UIPageControl *pageControl;

@end

@implementation JCHShopsContainerView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0x575e7b);
        self.pagingEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    self.data = nil;
    self.shopCompentViews = nil;
    
    [super dealloc];
}


- (void)setViewData:(NSArray *)dataArray
{
    // 对店铺列表进行排序，自己的店放在前面
    NSArray *data = [JCHShopUtility sortShopList:dataArray];
    
    // 去除默认类型的店铺
    data = [JCHShopUtility removeDefaultBookInfoRecord:data];
    self.data = data;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.shopCompentViews removeAllObjects];
    
    //多店显示，可以滑动，每个页面最多显示8个店铺，最后一个显示新增小店
    NSInteger numberOfPages = ceil((CGFloat)(data.count + 1) / 8);
    self.contentSize = CGSizeMake(numberOfPages * kScreenWidth, 0);
    CGFloat componentViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:kJCHShopsComponentViewHeight];
    
    for (NSInteger i = 0; i < numberOfPages; i++) {
        
        CGFloat pageContainerViewX = kScreenWidth * i;
        CGFloat pageContainerViewY = 0;
        CGFloat pageContainerViewWidth = kScreenWidth;
        CGFloat pageContainerViewHeight = self.data.count >= 4 ? 2 * componentViewHeight : componentViewHeight;
        
        UIView *pageContainerView = [[[UIView alloc] initWithFrame:CGRectMake(pageContainerViewX, pageContainerViewY, pageContainerViewWidth, pageContainerViewHeight)] autorelease];
        pageContainerView.backgroundColor = self.backgroundColor;
        [self addSubview:pageContainerView];
        
        NSInteger numberOfThisPage = 8;
        if (i == numberOfPages - 1) {
            numberOfThisPage = self.data.count % numberOfThisPage + 1;
        }
        
        for (NSInteger j = 0; j < numberOfThisPage; j++) {
            
            CGFloat componentViewWidth = kScreenWidth / 4;
            CGFloat componentViewX = componentViewWidth * (j % 4);
            CGFloat componentViewY = j >= 4 ? componentViewHeight : 0;
            
            JCHShopsComponentView *componentView = [[[JCHShopsComponentView alloc] initWithFrame:CGRectMake(componentViewX, componentViewY, componentViewWidth, componentViewHeight)] autorelease];
            
            NSInteger numberOfData = i * 8 + j;
            NSString *imageName = [NSString stringWithFormat:@"img_store_%ld", numberOfData < 5 ? (numberOfData + 1) : (numberOfData % 5) + 1];
            
            if (numberOfData == data.count) {
                imageName = @"img_store_6";
                componentView.titleLabel.text = @"新增小店";  //加入店铺
                componentView.arrowImageView.hidden = YES;
            } else{
                BookInfoRecord4Cocoa *record = data[j + 8 * i];
                componentView.titleLabel.text = record.bookName;
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                
                //当前的店
                if ([record.bookID isEqualToString:statusManager.accountBookID]) {
                    componentView.arrowImageView.hidden = NO;
                }
                
                //禁用的店
                if (record.bookStatus == 1) {
                    componentView.shopButton.enabled = NO;
                }
            }
            
            [componentView.shopButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            
            //! @todo 设置店铺禁用图片
            [componentView.shopButton setImage:[UIImage imageNamed:@"img_store_disabled"] forState:UIControlStateDisabled];
            [componentView.shopButton addTarget:self action:@selector(handleSwitchShop:) forControlEvents:UIControlEventTouchUpInside];
            componentView.shopButton.tag = numberOfData;
            [pageContainerView addSubview:componentView];
            [self.shopCompentViews addObject:componentView];
        }
    }
    
    if (self.pageControl == nil) {
        self.pageControl = [[[UIPageControl alloc] init] autorelease];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        [self.superview addSubview:self.pageControl];
    }
    self.pageControl.numberOfPages = numberOfPages;
    if (numberOfPages > 1) {
        self.pageControl.hidden = NO;
    } else {
        self.pageControl.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(self.frame.size.height - kJCHPageControlHeight - 5);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kJCHPageControlHeight);
    }];
}

- (void)handleSwitchShop:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSwitchShop:data:)]) {
        [self.delegate handleSwitchShop:sender.tag data:self.data];
    }
}

- (void)selectShop:(NSInteger)index
{
    for (JCHShopsComponentView *view in self.shopCompentViews) {
        if ([view isKindOfClass:[JCHShopsComponentView class]]) {
            view.arrowImageView.hidden = YES;
            if (view.shopButton.tag == index) {
                view.arrowImageView.hidden = NO;
            }
        }
    }
}

- (void)updatePageControl:(NSInteger)index
{
    self.pageControl.currentPage = index;
}

@end
