//
//  JCHClientAnalyseTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientAnalyseTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHClientAnalyseTableViewCellData

- (void)dealloc
{
    self.name = nil;
    self.customUUID = nil;
    
    [super dealloc];
}

@end

@interface JCHClientAnalyseTableViewCell ()

@property (nonatomic, retain) JCHClientAnalyseTableViewCellData *data;

@end

@implementation JCHClientAnalyseTableViewCell
{
    UILabel *_rigntLabel;
    UILabel *_leftLabel;
    UIView *_progressView;
    UIView *_progressBackgroundView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.arrowImageView.hidden = NO;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.data = nil;
    [super dealloc];
}

- (void)createUI
{
    const CGFloat leftLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:55.0f];
    const CGFloat rightLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:60.0f];
    
    _rigntLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(13.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentRight];
    _rigntLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_rigntLabel];
    
    [_rigntLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(rightLabelWidth);
        make.top.bottom.equalTo(self.contentView);
    }];
    

    _leftLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:JCHFont(13.0)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    //_leftLabel.adjustsFontSizeToFitWidth = YES;
    _leftLabel.numberOfLines = 0;
    [self.contentView addSubview:_leftLabel];
    
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(leftLabelWidth);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    _progressBackgroundView = [[[UIView alloc] init] autorelease];
    _progressBackgroundView.backgroundColor = UIColorFromRGB(0xd4e4f8);
    _progressBackgroundView.layer.cornerRadius = 4.5;
    _progressBackgroundView.clipsToBounds = YES;
    [self.contentView addSubview:_progressBackgroundView];
    
    [_progressBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_rigntLabel.mas_left).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(9);
    }];
    
    _progressView = [[[UIView alloc] init] autorelease];
    _progressView.backgroundColor = UIColorFromRGB(0x69a4f1);
    _progressView.layer.cornerRadius = 4.5;
    _progressView.clipsToBounds = YES;
    [_progressBackgroundView addSubview:_progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(_progressBackgroundView);
        make.width.mas_equalTo(_progressBackgroundView).multipliedBy(0);
    }];
}


- (void)setViewData:(JCHClientAnalyseTableViewCellData *)data
{
    self.data = data;
    _leftLabel.text = data.name;
    
    if (data.numberType == kJCHClientAnalyseTableViewCellDataNumberTypeAmount) {
        _rigntLabel.text = [NSString stringWithFormat:@"¥%.2f", data.rightAmount];
    } else if (data.numberType == kJCHClientAnalyseTableViewCellDataNumberTypeCount){
        _rigntLabel.text = [NSString stringWithFormat:@"%ld单", (NSInteger)data.rightAmount];
    } else {
        _rigntLabel.text = [NSString stringWithFormat:@"%.2f%%", data.rightAmount * 100];
    }
    [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(_progressBackgroundView);
        make.width.mas_equalTo(_progressBackgroundView).multipliedBy(data.percentage > 0 ? data.percentage : 0);
    }];
}

- (void)startAnimation
{
    [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(_progressBackgroundView);
        make.width.mas_equalTo(0);
    }];
    
    if (self.data.percentage > 0) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(_progressBackgroundView);
                make.width.mas_equalTo(_progressBackgroundView).multipliedBy(self.data.percentage > 0 ? self.data.percentage : 0);
            }];
            
            [UIView animateWithDuration:1.5 animations:^{
                [_progressView.superview layoutIfNeeded];
            }];
        });
    }
}



@end
