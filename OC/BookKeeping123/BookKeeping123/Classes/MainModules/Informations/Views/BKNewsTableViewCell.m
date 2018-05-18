//
//  BKNewsTableViewCell.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKNewsTableViewCell.h"

@interface BKNewsTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint; // 139


@end


@implementation BKNewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setData:(BKNewsModel *)data {
    _data = data;
    
    self.titleLabel.text = data.title;
    
    NSURL *url = [NSURL URLWithString:data.pic];
    [self.picImageView sd_setImageWithURL:url placeholderImage:IMG(@"es_hold_2")];
}
@end
