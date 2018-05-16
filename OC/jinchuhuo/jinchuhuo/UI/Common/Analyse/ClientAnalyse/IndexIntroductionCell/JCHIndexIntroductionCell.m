//
//  JCHIndexIntroductionCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHIndexIntroductionCell.h"
#import "CommonHeader.h"

@implementation JCHIndexIntroductionCellData

- (void)dealloc
{
    self.title = nil;
    self.detail = nil;
    
    [super dealloc];
}

@end

@implementation JCHIndexIntroductionCell
{
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UIImageView *_arrowImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat arrowImageViewWidth = 18.0f;
        
        self.clipsToBounds = YES;
        _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(15)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
            make.height.mas_equalTo(kStandardItemHeight);
            make.top.equalTo(self.contentView);
            make.right.equalTo(self.contentView).with.offset(-(arrowImageViewWidth + 2 * kStandardLeftMargin));
        }];
        
        _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beginInventory_btn_open"]] autorelease];
        [self.contentView addSubview:_arrowImageView];
        
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
            make.width.height.mas_equalTo(arrowImageViewWidth);
            make.centerY.equalTo(_titleLabel);
        }];
        
        _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(13)
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentLeft];
        _detailLabel.numberOfLines = 0;
        _detailLabel.hidden = YES;
        [self.contentView addSubview:_detailLabel];
        
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom);
            make.left.right.equalTo(_titleLabel);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setViewData:(JCHIndexIntroductionCellData *)data
{
    _titleLabel.text = data.title;
    _detailLabel.text = data.detail;
    CGFloat arrowImageViewWidth = 18.0f;
    
    CGFloat labelWidth = kScreenWidth - 3 * kStandardLeftMargin - arrowImageViewWidth;
    CGRect fitFrame = [data.detail boundingRectWithSize:CGSizeMake(labelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _detailLabel.font} context:nil];
    //CGSize fitSize = [_detailLabel sizeThatFits:CGSizeZero];
    [_detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(fitFrame.size.height + 5);
    }];
    
    data.maxCellHeight = kStandardItemHeight + 15 + fitFrame.size.height;
}

- (void)setDetailLabelHidden:(BOOL)hidden
{
    _detailLabel.hidden = hidden;
    if (hidden) {
        _arrowImageView.image = [UIImage imageNamed:@"beginInventory_btn_open"];
    } else {
        _arrowImageView.image = [UIImage imageNamed:@"beginInventory_btn_close"];
    }
}

@end
