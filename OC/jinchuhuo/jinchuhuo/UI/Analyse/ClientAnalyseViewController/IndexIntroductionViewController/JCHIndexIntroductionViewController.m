//
//  JCHIndexIntroductionViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHIndexIntroductionViewController.h"
#import "JCHIndexIntroductionCell.h"
#import "CommonHeader.h"

@interface JCHIndexIntroductionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *dataSource;

@end

@implementation JCHIndexIntroductionViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"客户指标说明";
        NSArray *titlesArray = @[@"出货总金额 / 出货总单数", @"退货总金额 / 退货单数", @"净出货金额 / 净出货单数", @"开单客户数", @"单均价", @"净赊销金额/单数", @"未收总金额/单数", @"本期货单退货金额/单数", @"毛利总额", @"毛利率", ];
        NSArray *detailsArray = @[@"本期新增出货单金额和对应的货单数量", @"本期新增退货单金额和对应的货单数量(包括退其它日期的货单)", @"从出货总金额中剔除有退货订单的金额", @"本期新增货单中的客户人数", @"出货总金额 / 出货总单数", @"本期新增出货单中，使用赊销结算的总金额(剔除退货金额)", @"净赊销总金额中，目前还未收款的金额/货单数", @"本期新增的出货单，后续做了退单的总金额/单数(不管在什么时候退)", @"净出货金额对应的毛利金额", @"毛利总额 / 净出货金额", ];
        
        NSMutableArray *dataSource = [NSMutableArray array];
        for (NSInteger i = 0; i < titlesArray.count; i++) {
            JCHIndexIntroductionCellData *data = [[[JCHIndexIntroductionCellData alloc] init] autorelease];
            data.title = titlesArray[i];
            data.detail = detailsArray[i];
            data.show = NO;
            data.maxCellHeight = kStandardItemHeight;
            [dataSource addObject:data];
        }
        self.dataSource = dataSource;
    }
    return self;
}

- (void)dealloc
{
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

- (void)createUI
{
    UIView *topInfoView = [[[UIView alloc] init] autorelease];
    topInfoView.backgroundColor = UIColorFromRGB(0xFFFCF4);
    [self.view addSubview:topInfoView];
    
    [topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [topInfoView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    
    UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"注：收付款时，如对货单金额有做减免，货单内商品的汇总金额和订单金额会有偏差，以货单金额为准"
                                              font:JCHFont(12.0f)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    infoLabel.numberOfLines = 0;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [topInfoView addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topInfoView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(topInfoView);
        make.right.equalTo(topInfoView).with.offset(-kStandardLeftMargin);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topInfoView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.tableView registerClass:[JCHIndexIntroductionCell class] forCellReuseIdentifier:@"JCHIndexIntroductionCell"];
    JCHSeparateLineSectionView *header = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    header.frame = CGRectMake(0, 0, kScreenWidth, kStandardSeparateViewHeight);
    self.tableView.tableHeaderView = header;
}

#pragma mark - UITableDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHIndexIntroductionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHIndexIntroductionCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    JCHIndexIntroductionCellData *data = self.dataSource[indexPath.row];
    
    [cell setViewData:data];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHIndexIntroductionCellData *data = self.dataSource[indexPath.row];
    
    if (data.isShow) {
        return data.maxCellHeight;
    } else {
        return kStandardItemHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHIndexIntroductionCellData *data = self.dataSource[indexPath.row];
    JCHIndexIntroductionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (data.isShow) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [cell setDetailLabelHidden:YES];
        data.show = NO;
    } else {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        //cell.selected = YES;
        [cell setDetailLabelHidden:NO];
        data.show = YES;
    }
    
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

@end
