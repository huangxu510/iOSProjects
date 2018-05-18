//
//  BKCalculateResultTableViewCell.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/18.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculateResultTableViewCell.h"

@implementation BKCalculateResultTableViewCellModel
@end

@interface BKCalculateResultTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
@implementation BKCalculateResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(BKCalculateResultTableViewCellModel *)data {
    _data = data;
    _titleLabel.text = [data.title stringByAppendingString:@":"];
    _detailLabel.text = data.detail;
    _detailLabel.textColor = data.detailColor;
}

@end
