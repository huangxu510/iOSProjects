//
//  JCHInitialInventoryViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInitialInventoryViewController.h"
#import "JCHInitialInventorySecionView.h"
#import "JCHInitialInventoryTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "ServiceFactory.h"
#import "SKURecord4Cocoa.h"
#import <Masonry.h>

@interface JCHInitialInventoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *_goodsSKUUUID;
    UITableView *_contentTableView;
}
@property (nonatomic, retain) NSMutableArray *dataSource;
@end

@implementation JCHInitialInventoryViewController

- (instancetype)initWithGoodsSKUUUID:(NSString *)goodsSKUUUID
{
    self = [super init];
    if (self) {
        _goodsSKUUUID = goodsSKUUUID;
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self.dataSource release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"我们已经根据商品的规格列出了一下单品,输入数量和成本即可完成"
                                               font:[UIFont systemFontOfSize:15.0f]
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
    CGFloat labelWidth = kScreenWidth - 2 * kStandardLeftMargin;
    CGFloat labelHeight = [titleLabel.text boundingRectWithSize:CGSizeMake(labelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size.height;
    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, labelHeight + 33)] autorelease];
    [tableHeaderView addSubview:titleLabel];
     [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(tableHeaderView).with.offset(kStandardLeftMargin);
         make.right.equalTo(tableHeaderView).with.offset(-kStandardLeftMargin);
         make.top.equalTo(tableHeaderView).with.offset(kStandardTopMargin);
         make.bottom.equalTo(tableHeaderView).with.offset(-11);
     }];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
}

- (void)loadData
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    [skuService queryGoodsSKU:_goodsSKUUUID skuArray:&record];
    
    NSInteger count = 0;
    NSMutableArray *skuTypeArr = [NSMutableArray array];
    for (NSInteger i = 0; i < record.skuArray.count; i++) {
        if (i == 0) {
            count = 1;
        }
        NSDictionary *dict = record.skuArray[i];
        NSArray *skuValueArr = [dict allValues][0];
        count *= skuValueArr.count;
        [skuTypeArr addObject:skuValueArr];
    }
    
}

- (void)handleSaveRecord
{

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    JCHInitialInventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JCHInitialInventoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return  nil;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[JCHInitialInventorySecionView alloc] init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

@end
