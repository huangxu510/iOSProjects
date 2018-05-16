//
//  JCHAnalysesPurchaseTableView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalysesPurchaseTableView.h"
#import "JCHTradeDateTableSectionView.h"
#import "JCHProductCategoryTableSectionView.h"
#import "JCHProductNameTableSectionView.h"
#import "JCHProfitTableSectionView.h"
#import "JCHProfitTableViewCell.h"
#import "JCHTradeDateTableViewCell.h"
#import "JCHProductCategoryTableViewCell.h"
#import "JCHProductNameTableViewCell.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "ReportData4Cocoa.h"
#import "NSString+JCHString.h"
#import <Masonry.h>

@interface JCHAnalysesPurchaseTableView () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    UIButton *_tradeDateButton;
    UIButton *_productCategoryButton;
    UIButton *_productNameButton;
    UIView *_indexView;
    UITableView *_tradeDateTableView;
    UITableView *_productCategoryTableView;
    UITableView *_productNameTableView;
    UIScrollView *_tableScrollView;
    CGFloat _previousOffsetX;
    JCHAnalyseType _enumAnalyseType;
}
@end

@implementation JCHAnalysesPurchaseTableView

- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        _previousOffsetX = 0;
        _enumAnalyseType = type;
    }
    return self;
}

- (void)dealloc
{
    [self.productCategoryDataSource release];
    [self.productNameDataSource release];
    [self.tradeDateDataSource release];
    
    [super dealloc];
}

- (void)createUI
{
    const CGFloat buttonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:40];
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    UIColor *titleColor = JCHColorMainBody;
    
    _tradeDateButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleButtonClick:)
                                            title:@"交易日期"
                                       titleColor:JCHColorMainBody
                                  backgroundColor:nil];
    [_tradeDateButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _tradeDateButton.titleLabel.font = titleFont;
    [self addSubview:_tradeDateButton];
    
    _tradeDateButton.selected = YES;
    
    _productCategoryButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                           action:@selector(handleButtonClick:)
                                            title:@"商品分类"
                                       titleColor:titleColor
                                  backgroundColor:nil];
    [_productCategoryButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _productCategoryButton.titleLabel.font = titleFont;
    [self addSubview:_productCategoryButton];
    
    _productNameButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleButtonClick:)
                                            title:@"商品名称"
                                       titleColor:titleColor
                                  backgroundColor:nil];
    [_productNameButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _productNameButton.titleLabel.font = titleFont;
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
    
    _tradeDateTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttonHeight, kWidth, kHeight - buttonHeight) style:UITableViewStylePlain] autorelease];
    _tradeDateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tradeDateTableView.delegate = self;
    _tradeDateTableView.dataSource = self;
    _tradeDateTableView.bounces = YES;
    [_tableScrollView addSubview:_tradeDateTableView];
    
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
    
    [_tradeDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(self);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    [_productCategoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_tradeDateButton.mas_right);
        make.width.equalTo(_tradeDateButton);
        make.top.equalTo(_tradeDateButton);
        make.height.equalTo(_tradeDateButton);
    }];
    
    [_productNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productCategoryButton.mas_right);
        make.width.equalTo(_productCategoryButton);
        make.top.equalTo(_productCategoryButton);
        make.height.equalTo(_productCategoryButton);
    }];
    
    [_indexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(_tradeDateButton);
        make.height.mas_equalTo(2);
        make.bottom.equalTo(_tradeDateButton);
    }];
    
    [_tableScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tradeDateButton.mas_bottom);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    
    _tradeDateTableView.frame = CGRectMake(0, 0, kWidth, kHeight - buttonHeight);
    _productCategoryTableView.frame = CGRectMake(kWidth, 0, kWidth, kHeight - buttonHeight);
    _productNameTableView.frame = CGRectMake(2 * kWidth, 0, kWidth, kHeight - buttonHeight);
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)handleButtonClick:(UIButton *)button
{
    if (button == _tradeDateButton) {
        NSLog(@"tradeDate");
        [self changeSelectedButton:_tradeDateButton];
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
            [self changeSelectedButton:_tradeDateButton];
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
    _tradeDateButton.selected = NO;
    _productCategoryButton.selected = NO;;
    _productNameButton.selected = NO;
    selectedButton.selected = YES;
}

- (void)reloadData
{
    [_tradeDateTableView reloadData];
    [_productCategoryTableView reloadData];
    [_productNameTableView reloadData];
}

#pragma mark - UITableViewDelegate
-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tradeDateTableView) {
        return self.tradeDateDataSource.count;
    }
    else if (tableView == _productCategoryTableView)
    {
        return self.productCategoryDataSource.count;
    }
    return self.productNameDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_enumAnalyseType == kJCHAnalyseProfit)
    {
        if (tableView == _tradeDateTableView) {
            JCHProfitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitTradeDateCell"];
            if (cell == nil) {
                cell = [[[JCHProfitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profitTradeDateCell"] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            JCHProfitTableViewCellData *data = [[[JCHProfitTableViewCellData alloc] init] autorelease];
            ProfitAmountReportData4Cocoa *reportData = self.tradeDateDataSource[indexPath.row];
            
            
            data.productCategory = [NSString stringFromSeconds:reportData.timestamp dateStringType:kJCHDateStringType1]; //@"2015-10-28";
            data.productSaleAmount = [NSString stringWithFormat:@"%.2f", reportData.totalAmount];
            data.productProfitAmount = [NSString stringWithFormat:@"%.2f", reportData.totalProfit];
            data.productProfitRate = [NSString stringWithFormat:@"%.2f%%", reportData.profitRate * 100];
            
            [cell setData:data];
            
            return cell;
        }
        else if (tableView == _productCategoryTableView)
        {
            JCHProfitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitProductCategoryCell"];
            if (cell == nil) {
                cell = [[[JCHProfitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profitProductCategoryCell"] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            JCHProfitTableViewCellData *data = [[[JCHProfitTableViewCellData alloc] init] autorelease];
            ProfitCategoryReportData4Cocoa *reportData = self.productCategoryDataSource[indexPath.row];
            
            data.productCategory = reportData.categoryName;
            data.productSaleAmount = [NSString stringWithFormat:@"%.2f", reportData.totalAmount];
            data.productProfitAmount = [NSString stringWithFormat:@"%.2f", reportData.totalProfit];
            data.productProfitRate = [NSString stringWithFormat:@"%.2f%%", reportData.profitRate * 100];
            
            [cell setData:data];
            
            return cell;
        }
        else
        {
            JCHProfitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitProductNameCell"];
            if (cell == nil) {
                cell = [[[JCHProfitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profitProductNameCell"] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            JCHProfitTableViewCellData *data = [[[JCHProfitTableViewCellData alloc] init] autorelease];
            ProfitProductReportData4Cocoa *reportData = self.productNameDataSource[indexPath.row];
            
            data.productCategory = reportData.productName;
            data.productSaleAmount = [NSString stringWithFormat:@"%.2f", reportData.totalAmount];
            data.productProfitAmount = [NSString stringWithFormat:@"%.2f", reportData.totalProfit];
            data.productProfitRate = [NSString stringWithFormat:@"%.2f%%", reportData.profitRate * 100];
            
            [cell setData:data];
            
            return cell;
        }

    }
    else
    {
        if (tableView == _tradeDateTableView) {
            JCHTradeDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tradeDateCell"];
            if (cell == nil) {
                cell = [[[JCHTradeDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tradeDateCell"] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            
            JCHTradeDateTableViewCellData *data = [[[JCHTradeDateTableViewCellData alloc] init] autorelease];
            PurchaseShipmentAmountReportData4Cocoa *reportData = self.tradeDateDataSource[indexPath.row];
            
            
            data.productDate = [NSString stringFromSeconds:reportData.timestamp dateStringType:kJCHDateStringType1];
            data.productPurchaseAmount = [NSString stringWithFormat:@"¥ %.2f", reportData.totalAmount];
            [cell setData:data];
            
            return cell;
        }
        else if (tableView == _productCategoryTableView)
        {
            JCHProductCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productCategoryCell"];
            if (cell == nil) {
                cell = [[[JCHProductCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"productCategoryCell"] autorelease];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            JCHProductCategoryTableViewCellData *data = [[[JCHProductCategoryTableViewCellData alloc] init] autorelease];
            PurchaseShipmentCategoryReportData4Cocoa *reportData = self.productCategoryDataSource[indexPath.row];
            data.productCategory = reportData.categoryName;
            data.productPurchaseAmount = [NSString stringWithFormat:@"¥ %.2f", reportData.totalAmount];
            data.productCount = [NSString stringWithFormat:@"%.0f", reportData.totalCount];
            [cell setData:data];
            
            return cell;
        }
        else
        {
            JCHProductNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productNameCell"];
            if (cell == nil) {
                cell = [[[JCHProductNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"productNameCell"] autorelease];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row % 2 == 1) {
                cell.backgroundColor = RGBColor(248, 248, 248, 1);
            }
            else
            {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
            JCHProductNameTableViewCellData *data = [[[JCHProductNameTableViewCellData alloc] init] autorelease];
            PurchaseShipmentProductReportData4Cocoa *reportData = self.productNameDataSource[indexPath.row];
            data.productName= [NSString stringWithFormat:@"%@/%@", reportData.productName, reportData.productUnit];
            data.productPurchaseAmount = [NSString stringWithFormat:@"¥ %.2f", reportData.totalAmount];
            
            data.productCount = [NSString stringFromCount:reportData.totalCount unitDigital:reportData.unitDigitCount];
           
            [cell setData:data];
            
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect sectionViewFrame = CGRectMake(0, 0, kScreenWidth, 30);
    if (iPhone4) {
        sectionViewFrame = CGRectMake(0, 0, kScreenWidth, 25);
    }
    if (_enumAnalyseType == kJCHAnalyseProfit) {
        
        
        if (tableView == _tradeDateTableView) {
            return [[[JCHProfitTableSectionView alloc] initWithFrame:sectionViewFrame tableViewType:kJCHProfitTableViewTypeTradeDate] autorelease];
        }
        else if (tableView == _productCategoryTableView)
        {
            return [[[JCHProfitTableSectionView alloc] initWithFrame:sectionViewFrame tableViewType:kJCHProfitTableViewTypeProductCategory] autorelease];
        }
        else
        {
            return [[[JCHProfitTableSectionView alloc] initWithFrame:sectionViewFrame tableViewType:kJCHProfitTableViewTypeProductName] autorelease];
        }
    }
    else
    {
        if (tableView == _tradeDateTableView) {
            return [[[JCHTradeDateTableSectionView alloc] initWithFrame:sectionViewFrame anasyseType:_enumAnalyseType] autorelease];
        }
        else if (tableView == _productCategoryTableView)
        {
            return [[[JCHProductCategoryTableSectionView alloc] initWithFrame:sectionViewFrame anasyseType:_enumAnalyseType] autorelease];
        }
        else
        {
            return [[[JCHProductNameTableSectionView alloc] initWithFrame:sectionViewFrame anasyseType:_enumAnalyseType] autorelease];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return iPhone4 ? 25 : 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return iPhone4 ? 30 : 35;
}

@end
