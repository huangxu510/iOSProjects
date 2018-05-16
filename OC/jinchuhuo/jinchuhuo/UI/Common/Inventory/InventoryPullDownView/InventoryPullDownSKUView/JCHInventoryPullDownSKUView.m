//
//  JCHInventoryPullDownSKUView.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/28.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHInventoryPullDownSKUView.h"
#import "JCHAddProductSKUSelectView.h"
#import "JCHTransactionUtility.h"
#import "CommonHeader.h"

@implementation JCHInventoryPullDownSKUView
{
    UIScrollView *_contentScrollView;
    UIButton *_commitButton;
    UIButton *_clearButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _contentScrollView = [[[UIScrollView alloc] init] autorelease];
    _contentScrollView.backgroundColor = [UIColor whiteColor];
    _contentScrollView.scrollEnabled = YES;
    [self addSubview:_contentScrollView];
    
    _commitButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(commit)
                                         title:@"确定"
                                    titleColor:JCHColorHeaderBackground
                               backgroundColor:[UIColor whiteColor]];
    _commitButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    _commitButton.layer.cornerRadius = 0;
    [self addSubview:_commitButton];
    
    _clearButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(clearOption)
                                         title:@"清除选项"
                                    titleColor:JCHColorMainBody
                               backgroundColor:[UIColor whiteColor]];
    _clearButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    _clearButton.layer.cornerRadius = 0;
    [self addSubview:_clearButton];
    
    UIView *horizontalLine = [[[UIView alloc] init] autorelease];
    horizontalLine.frame = CGRectMake(0, 0, kScreenWidth, kSeparateLineWidth);
    horizontalLine.backgroundColor = JCHColorSeparateLine;
    [_clearButton addSubview:horizontalLine];
    
    UIView *verticalLine = [[[UIView alloc] init] autorelease];
    verticalLine.frame = CGRectMake(0, 0, kSeparateLineWidth, 44);
    verticalLine.backgroundColor = JCHColorSeparateLine;
    [_commitButton addSubview:verticalLine];
}

 //data : @[@{skuTypeName : @[skuValueRecord, ...]}, ...];
- (void)setData:(NSArray *)data
{
    [_contentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat viewHeight = 0;
    
    for (NSInteger i = 0; i < data.count; i++) {
        
        JCHAddProductSKUSelectView *skuSelectView = [[[JCHAddProductSKUSelectView alloc] initWithFrame:CGRectMake(0, viewHeight, kScreenWidth, 0)] autorelease];
        skuSelectView.autoSelectIfOneSKUValue = NO;
        [skuSelectView setButtonData:data[i]];
        
        CGRect frame = skuSelectView.frame;
        frame.size.height = skuSelectView.viewHeight;
        viewHeight += skuSelectView.viewHeight;
        skuSelectView.frame = frame;
        if (i == data.count - 1) {
            [skuSelectView setBrokenLineViewHidden:YES];
        }
        [_contentScrollView addSubview:skuSelectView];
    }
    
    CGFloat maxHeight = 0;
    if (iPhone4) {
        maxHeight = 35 * 7;
    } else {
        maxHeight = 44 * 7;
    }
    
    if (viewHeight == 0) {
        self.maxHeight = 0;
        return;
    }
    CGFloat buttonHeight = 44;
    if (viewHeight + buttonHeight > maxHeight) {
        self.maxHeight = maxHeight;
        CGSize contentSize = _contentScrollView.contentSize;
        contentSize.height = viewHeight;
        _contentScrollView.contentSize = contentSize;
        _contentScrollView.frame = CGRectMake(0, 0, kScreenWidth, maxHeight - buttonHeight);
        _clearButton.frame = CGRectMake(0, CGRectGetMaxY(_contentScrollView.frame), kScreenWidth / 2, buttonHeight);
        _commitButton.frame = CGRectMake(kScreenWidth / 2, CGRectGetMaxY(_contentScrollView.frame), kScreenWidth / 2, buttonHeight);
    } else {
        self.maxHeight = viewHeight + buttonHeight;
        _contentScrollView.frame = CGRectMake(0, 0, kScreenWidth, viewHeight);
        _clearButton.frame = CGRectMake(0, CGRectGetMaxY(_contentScrollView.frame), kScreenWidth / 2, buttonHeight);
        _commitButton.frame = CGRectMake(kScreenWidth / 2, CGRectGetMaxY(_contentScrollView.frame), kScreenWidth / 2, buttonHeight);
    }
}

- (void)commit
{
    NSMutableArray *skuData = [NSMutableArray array];
    for (JCHAddProductSKUSelectView *view in _contentScrollView.subviews) {
        if ([view isKindOfClass:[JCHAddProductSKUSelectView class]] && view.selectedData.count > 0) {
            [skuData addObject:view.selectedData];
        }
    }
    
    
    if (skuData.count > 5) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"最多只能选取5种规格"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuData];
    
    //保存所有组合对应的skuValueUUIDs (Nsarray)
    NSArray *skuValueUUIDsArray = [skuValuedDict allKeys][0];
    
    if ([self.delegate respondsToSelector:@selector(filteredSKUValueUUIDArray:)]) {
        [self.delegate filteredSKUValueUUIDArray:skuValueUUIDsArray];
    }
}

- (void)clearOption
{
    for (JCHAddProductSKUSelectView *view in _contentScrollView.subviews) {
        if ([view isKindOfClass:[JCHAddProductSKUSelectView class]]) {
            [view unselectData];
        }
    }
}

@end
