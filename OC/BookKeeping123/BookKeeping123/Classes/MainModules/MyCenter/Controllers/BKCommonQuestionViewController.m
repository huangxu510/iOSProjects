//
//  BKCommonQuestionViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/19.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCommonQuestionViewController.h"
#import "BKQuestionTableViewCell.h"

@interface BKCommonQuestionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *questionList;

@end

@implementation BKCommonQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"常见问题";
    
    [self setupData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BKQuestionTableViewCell" bundle:nil] forCellReuseIdentifier:@"BKQuestionTableViewCell"];
    self.tableView.mj_header = nil;
    self.tableView.mj_footer = nil;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BKQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BKQuestionTableViewCell"];
    cell.data = self.questionList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BKQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BKQuestionTableViewCell"];
    cell.data = self.questionList[indexPath.row];
    return cell.height;
}

- (void)setupData {
    NSArray *questionArray = @[
                               @"等额本金的含义及计算公式",
                               @"等额本息含义及计算公式",
                               @"等额本金适合的人群",
                               @"等额本息适合的人群",
                               @"等额本金的利弊",
                               @"等额本息的利弊"];
    NSArray *answerArray = @[
                             @"等额本金又称利随本清、等本不等息还款法。贷款人将本金分摊到每个月内，同时付清上一交易日至本次还款日之间的利息。\n这种还款方式相对等额本息而言，总的利息支出较低，但是前期支付的本金和利息较多，还款负担逐月递减。\n计算公式：\n每月还本付息金额=(本金/还款月数)+(本金-累计已还本金)×月利率\n每月本金=总本金/还款月数\n每月利息=(本金-累计已还本金)×月利率\n还款总利息=（还款月数+1）*贷款额*月利率/2\n还款总额=(还款月数+1)*贷款额*月利率/2+贷款额",
                             @"等额本息又称为定期付息，即借款人每月按相等的金额偿还贷款本息，其中每月贷款利息按月初剩余贷款本金计算并逐月结清。\n由于每月的还款额相等，因此，在贷款初期每月的还款中，剔除按月结清的利息后，所还的贷款本金就较少；而在贷款后期因贷款本金不断减少、每月的还款额中贷款利息也不断减少，每月所还的贷款本金就较多。\n计算公式：\n每月还本付息金额=[ 本金 x 月利率 x(1+月利率)贷款月数 ] / [(1+月利率)还款月数 - 1]\n每月利息=剩余本金x贷款月利率\n还款总利息=贷款额*贷款月数*月利率*（1+月利率）贷款月数/【（1+月利率）还款月数 - 1】-贷款额\n还款总额=还款月数*贷款额*月利率*（1+月利率）贷款月数/【（1+月利率）还款月数 - 1】",
                             @"等额本金法因为在前期的还款额度较大，而后逐月递减，所以比较适合在前段时间还款能力强的贷款人，当然一些年纪稍微大一点的人也比较适合这种方式，因为随着年龄增大或退休，收入可能会减少。",
                             @"等额本息每月的还款额度相同，所以比较适宜有正常开支计划的家庭，特别是年青人，而且随着年龄增大或职位升迁，收入会增加，生活水平自然会上升;如果这类人选择本金法的话，前期压力会非常大。",
                             @"等额本金贷款采用的是简单利率方式计算利息。在每期还款的结算时刻，它只对剩余的本金(贷款余额)计息，也就是说未支付的贷款利息不与未支付的贷款余额一起作利息计算，而只有本金才作利息计算。",
                             @"等额本息贷款采用的是复合利率计算。在每期还款的结算时刻，剩余本金所产生的利息要和剩余的本金(贷款余额)一起被计息，也就是说未付的利息也要计息，这好像比“利滚利”还要厉害。在国外，它是公认的适合放贷人利益的贷款方式。"];
    NSMutableArray *questionList = [NSMutableArray array];
    for (NSInteger i = 0; i < questionArray.count; i++) {
        BKQuestionTableViewCellModel *model = [[BKQuestionTableViewCellModel alloc] init];
        model.question = questionArray[i];
        model.answer = answerArray[i];
        [questionList addObject:model];
    }
    self.questionList = questionList;
}


@end
