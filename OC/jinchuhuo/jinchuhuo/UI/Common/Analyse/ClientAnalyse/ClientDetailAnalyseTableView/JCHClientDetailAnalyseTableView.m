//
//  JCHClientDetailAnalyseTableView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseTableView.h"
#import "JCHClientDetailAnalyseManifestCell.h"
#import "JCHClientDetailAnalyseCategoryCell.h"
//#import "JCHClientDetailProductNameCell.h"
#import "JCHClientDetailAnalyseCategorySectionView.h"
#import "CommonHeader.h"

@interface JCHClientDetailAnalyseTableView () <UITableViewDataSource, UITableViewDelegate>
{
    UIButton *_manifestButton;
    UIButton *_productCategoryButton;
    UIButton *_productNameButton;
    UIView *_indexView;
    UITableView *_manifestTableView;
    UITableView *_productCategoryTableView;
    UITableView *_productNameTableView;
    UIScrollView *_tableScrollView;
    CGFloat _previousOffsetX;
    
    BOOL _isReturned;
}

@end

@implementation JCHClientDetailAnalyseTableView

- (instancetype)initWithFrame:(CGRect)frame isReturned:(BOOL)isReturned
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        _previousOffsetX = 0;
        _isReturned = isReturned;
    }
    return self;
}

- (void)dealloc
{
    [self.productCategoryDataSource release];
    [self.productNameDataSource release];
    [self.manifestDataSource release];
    
    [super dealloc];
}

- (void)createUI
{
    const CGFloat buttonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:40];
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    UIColor *titleColor = JCHColorMainBody;
    
    _manifestButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleButtonClick:)
                                            title:@"订单明细"
                                       titleColor:JCHColorMainBody
                                  backgroundColor:nil];
    [_manifestButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _manifestButton.titleLabel.font = titleFont;
    [_manifestButton addSeparateLineWithMasonryTop:NO bottom:YES];
    [self addSubview:_manifestButton];
    
    _manifestButton.selected = YES;
    
    _productCategoryButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleButtonClick:)
                                                  title:@"商品分类"
                                             titleColor:titleColor
                                        backgroundColor:nil];
    [_productCategoryButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _productCategoryButton.titleLabel.font = titleFont;
    [_productCategoryButton addSeparateLineWithMasonryTop:NO bottom:YES];
    [self addSubview:_productCategoryButton];
    
    _productNameButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handleButtonClick:)
                                              title:@"商品名称"
                                         titleColor:titleColor
                                    backgroundColor:nil];
    [_productNameButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _productNameButton.titleLabel.font = titleFont;
    [_productNameButton addSeparateLineWithMasonryTop:NO bottom:YES];
    [self addSubview:_productNameButton];
    
    _indexView = [[[UIView alloc] init] autorelease];
    _indexView.backgroundColor = JCHColorHeaderBackground;
    [self addSubview:_indexView];
    
    _tableScrollView = [[[UIScrollView alloc] init] autorelease];
    _tableScrollView.contentSize = CGSizeMake(3 * kScreenWidth, 0);
    _tableScrollView.pagingEnabled = YES;
    _tableScrollView.bounces = NO;
    _tableScrollView.showsHorizontalScrollIndicator = NO;
    _tableScrollView.delegate = self;
    [self addSubview:_tableScrollView];
    
    _manifestTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttonHeight, kWidth, kHeight - buttonHeight) style:UITableViewStylePlain] autorelease];
    _manifestTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _manifestTableView.delegate = self;
    _manifestTableView.dataSource = self;
    _manifestTableView.bounces = YES;
    [_tableScrollView addSubview:_manifestTableView];
    
    _productCategoryTableView = [[[UITableView alloc] initWithFrame:CGRectMake(kWidth, buttonHeight, kWidth, kHeight - buttonHeight) style:UITableViewStylePlain] autorelease];
    _productCategoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _productCategoryTableView.delegate = self;
    _productCategoryTableView.dataSource = self;
    _productCategoryTableView.bounces = YES;
    [_tableScrollView addSubview:_productCategoryTableView];
    
    _productNameTableView = [[[UITableView alloc] initWithFrame:CGRectMake(2 * kWidth, buttonHeight, kWidth, kHeight - buttonHeight) style:UITableViewStylePlain] autorelease];
    _productNameTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _productNameTableView.delegate = self;
    _productNameTableView.dataSource = self;
    _productNameTableView.bounces = YES;
    [_tableScrollView addSubview:_productNameTableView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat buttonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:42];
    const CGFloat buttonWidth = kWidth / 3;
    
    [_manifestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(self);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    [_productCategoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_manifestButton.mas_right);
        make.width.equalTo(_manifestButton);
        make.top.equalTo(_manifestButton);
        make.height.equalTo(_manifestButton);
    }];
    
    [_productNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productCategoryButton.mas_right);
        make.width.equalTo(_productCategoryButton);
        make.top.equalTo(_productCategoryButton);
        make.height.equalTo(_productCategoryButton);
    }];
    
    [_indexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(_manifestButton);
        make.height.mas_equalTo(2);
        make.bottom.equalTo(_manifestButton);
    }];
    
    [_tableScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestButton.mas_bottom);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    
    _manifestTableView.frame = CGRectMake(0, 0, kWidth, kHeight - buttonHeight);
    _productCategoryTableView.frame = CGRectMake(kWidth, 0, kWidth, kHeight - buttonHeight);
    _productNameTableView.frame = CGRectMake(2 * kWidth, 0, kWidth, kHeight - buttonHeight);
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)handleButtonClick:(UIButton *)button
{
    if (button == _manifestButton) {
        NSLog(@"tradeDate");
        [self changeSelectedButton:_manifestButton];
        [_tableScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (button == _productCategoryButton)
    {
        NSLog(@"productCategory");
        [self changeSelectedButton:_productCategoryButton];
        [_tableScrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
    }
    else
    {
        NSLog(@"productName");
        [self changeSelectedButton:_productNameButton];
        [_tableScrollView setContentOffset:CGPointMake(2 * kScreenWidth, 0) animated:YES];
    }
}

#pragma  mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY != 0 || ((offsetY == 0) && (offsetX == 0))) {
        return;
    }
    CGRect frame =  _indexView.frame;
    frame.origin.x += (offsetX - _previousOffsetX) / 3;
    _indexView.frame = frame;
    
    _previousOffsetX = offsetX;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_tableScrollView == scrollView) {
        if (offsetY != 0) {
            return;
        }
        if (offsetX == 0) {
            [self changeSelectedButton:_manifestButton];
        }
        else if (offsetX == kScreenWidth)
        {
            [self changeSelectedButton:_productCategoryButton];
        }
        else
        {
            [self changeSelectedButton:_productNameButton];
        }
    }
}

- (void)changeSelectedButton:(UIButton *)selectedButton
{
    _manifestButton.selected = NO;
    _productCategoryButton.selected = NO;;
    _productNameButton.selected = NO;
    selectedButton.selected = YES;
}

- (void)reloadData
{
    [_manifestTableView reloadData];
    [_productCategoryTableView reloadData];
    [_productNameTableView reloadData];
}

#pragma mark - UITableViewDelegate
-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _manifestTableView) {
        return self.manifestDataSource.count;
    }
    else if (tableView == _productCategoryTableView)
    {
        return self.productCategoryDataSource.count;
    }
    return self.productNameDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //订单明细
    if (tableView == _manifestTableView)
    {
        JCHClientDetailAnalyseManifestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHClientDetailAnalyseManifestCell"];
        if (cell == nil) {
            cell = [[[JCHClientDetailAnalyseManifestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHClientDetailAnalyseManifestCell"] autorelease];
            cell -> _bottomLine.hidden = YES;
        }
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row % 2 == 1) {
            cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        ManifestRecord4Cocoa *manifestRecord = self.manifestDataSource[indexPath.row];
        
        JCHClientDetailAnalyseManifestCellData *data = [[[JCHClientDetailAnalyseManifestCellData alloc] init] autorelease];
        data.manifestID = manifestRecord.manifestID;
        
        id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
        BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", manifestRecord.operatorID]];
        NSString *manifestOperator = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];
        data.manifestOperator = manifestOperator;
        data.manifestTimeInterval = manifestRecord.manifestTimestamp;
        data.amount = [JCHFinanceCalculateUtility roundDownFloatNumber:manifestRecord.manifestAmount * manifestRecord.manifestDiscount - manifestRecord.eraseAmount];
        data.manifestType = manifestRecord.manifestType;
        data.isManifestReturned = manifestRecord.isManifestReturned;
        data.hasPayed = manifestRecord.hasPayed;
        data.profitAmount = manifestRecord.profitAmount;
        data.profitRate = manifestRecord.profitRatio;
        
        if (manifestRecord.manifestRemark == nil || [manifestRecord.manifestRemark isEqualToString:@""]){
            NSMutableArray *productNames = [NSMutableArray array];
            for (ManifestTransactionRecord4Cocoa *transactionRecord in manifestRecord.manifestTransactionArray) {
                if (![productNames containsObject:transactionRecord.productName]) {
                    [productNames addObject:transactionRecord.productName];
                }
            }
            NSMutableString *remarkStr = [NSMutableString stringWithString:@""];
            
            if (productNames.count > 0) {
                for (NSString *productName in productNames) {
                    [remarkStr appendString:[NSString stringWithFormat:@"%@、", productName]];
                }
                [remarkStr deleteCharactersInRange:NSMakeRange(remarkStr.length - 1, 1)];
            }
            
            data.manifestRemark = remarkStr;
        } else {
            data.manifestRemark = manifestRecord.manifestRemark;
        }
        
        [cell setViewData:data];
        
        return cell;
    }//商品分类
    else if (tableView == _productCategoryTableView)
    {
        JCHClientDetailAnalyseCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHClientDetailAnalyseCategoryCell"];
        if (cell == nil) {
            cell = [[JCHClientDetailAnalyseCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHClientDetailAnalyseCategoryCell" isReturned:_isReturned];
            cell -> _bottomLine.hidden = YES;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row % 2 == 1) {
            cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (_isReturned) {
            CustomCategoryReturnReportRecord4Cocoa *cusomCategoryReturnReportRecord = self.productCategoryDataSource[indexPath.row];
            
            JCHClientDetailAnalyseCategoryCellData *data = [[[JCHClientDetailAnalyseCategoryCellData alloc] init] autorelease];
            data.productName = cusomCategoryReturnReportRecord.categoryName;
            data.categoryCount = [NSString stringWithFormat:@"品类:%ld", cusomCategoryReturnReportRecord.productCount];
            data.totalAmount = cusomCategoryReturnReportRecord.totalSaleAmount;
            data.profitRate = cusomCategoryReturnReportRecord.amountRatio;
            
            [cell setViewData:data];
        } else {
            CustomCategoryReportRecord4Cocoa *customCategoryReportRecord = self.productCategoryDataSource[indexPath.row];
            
            JCHClientDetailAnalyseCategoryCellData *data = [[[JCHClientDetailAnalyseCategoryCellData alloc] init] autorelease];
            data.productName = customCategoryReportRecord.categoryName;
            data.categoryCount = [NSString stringWithFormat:@"品类:%ld", customCategoryReportRecord.productCount];
            data.totalAmount = customCategoryReportRecord.totalSaleAmount;
            data.profitAmount = customCategoryReportRecord.totalProfitAmount;
            data.profitRate = customCategoryReportRecord.profitRatio;
            
            [cell setViewData:data];
        }
        
        return cell;
    }//商品名称
    else
    {
        JCHClientDetailAnalyseCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHClientDetailProductNameCell"];
        if (cell == nil) {
            cell = [[[JCHClientDetailAnalyseCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JCHClientDetailProductNameCell" isReturned:_isReturned] autorelease];
            cell -> _bottomLine.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row % 2 == 1) {
            cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (_isReturned) {
            CustomProductReturnReportRecord4Cocoa *customProductReturnReportRecord = self.productNameDataSource[indexPath.row];
            
            JCHClientDetailAnalyseCategoryCellData *data = [[[JCHClientDetailAnalyseCategoryCellData alloc] init] autorelease];
            data.productName = customProductReturnReportRecord.productName;
            NSString *countString = [NSString stringFromCount:customProductReturnReportRecord.totalSaleCount unitDigital:customProductReturnReportRecord.unitDigitsCount];
            data.categoryCount = [NSString stringWithFormat:@"数量:%@%@", countString, customProductReturnReportRecord.productUnit];
            data.totalAmount = customProductReturnReportRecord.totalSaleAmount;
            //data.profitAmount = customProductReportRecord.totalProfitAmount;
            data.profitRate = customProductReturnReportRecord.amountRatio;
            [cell setViewData:data];
        } else {
            CustomProductReportRecord4Cocoa *customProductReportRecord = self.productNameDataSource[indexPath.row];
            
            JCHClientDetailAnalyseCategoryCellData *data = [[[JCHClientDetailAnalyseCategoryCellData alloc] init] autorelease];
            data.productName = customProductReportRecord.productName;
            NSString *countString = [NSString stringFromCount:customProductReportRecord.totalSaleCount unitDigital:customProductReportRecord.unitDigitsCount];
            data.categoryCount = [NSString stringWithFormat:@"数量:%@%@", countString, customProductReportRecord.productUnit];
            data.totalAmount = customProductReportRecord.totalSaleAmount;
            data.profitAmount = customProductReportRecord.totalProfitAmount;
            data.profitRate = customProductReportRecord.profitRatio;
            [cell setViewData:data];
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect sectionViewFrame = CGRectMake(0, 0, kScreenWidth, 30);
    if (iPhone4) {
        sectionViewFrame = CGRectMake(0, 0, kScreenWidth, 25);
    }
    
    if (tableView == _manifestTableView) {
        return nil;
    } else if (tableView == _productCategoryTableView) {
        return [[[JCHClientDetailAnalyseCategorySectionView alloc] initWithFrame:sectionViewFrame returned:_isReturned] autorelease];;
    } else {
        return [[[JCHClientDetailAnalyseCategorySectionView alloc] initWithFrame:sectionViewFrame returned:_isReturned] autorelease];
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _manifestTableView) {
        return 0;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _manifestTableView) {
        return 100;
    } else {
        return iPhone4 ? 40 : 53;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _manifestTableView) {
        ManifestRecord4Cocoa *manifestRecord = self.manifestDataSource[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(handlePushToManifestDetail:)]) {
            [self.delegate handlePushToManifestDetail:manifestRecord];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        return;
    }
}

@end
