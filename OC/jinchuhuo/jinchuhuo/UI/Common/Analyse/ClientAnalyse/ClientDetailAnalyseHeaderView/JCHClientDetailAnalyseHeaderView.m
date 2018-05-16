//
//  JCHClientDetailAnalyseHeaderView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseHeaderView.h"
#import "CommonHeader.h"

@implementation JCHClientDetailAnalyseHeaderComponentView

- (void)dealloc
{
    self.headImageView = nil;
    self.titleLabel = nil;
    self.detailLabel = nil;
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat headImageViewHeght = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50];
        CGFloat nameLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:30];
        
        self.headImageView = [[[UIImageView alloc] init] autorelease];
        self.headImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.headImageView];
        
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(headImageViewHeght);
        }];
        
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:JCHFont(15)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headImageView);
            make.height.mas_equalTo(nameLabelHeight);
            make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        }];
        
        self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@""
                                                font:JCHFont(13)
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentLeft];
        [self addSubview:self.detailLabel];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.equalTo(_headImageView);
        }];
    }
    return self;
}

@end

@implementation JCHClientDetailAnalyseHeaderViewData

- (void)dealloc
{
    self.headImageName = nil;
    self.name = nil;
    self.dateRange = nil;
    
    [super dealloc];
}

@end

@implementation JCHClientDetailAnalyseHeaderView
{
    JCHClientDetailAnalyseHeaderComponentView *_infoView;
    JCHClientDetailAnalyseHeaderComponentView *_totalManifsetView;
    JCHClientDetailAnalyseHeaderComponentView *_receivableView;
    
    UILabel *_titleLabelForReturnedIndex;
    UILabel *_detailLabelForReturnedIndex;
    
    BOOL _isReturned;
}

- (instancetype)initWithFrame:(CGRect)frame isReturned:(BOOL)isReturned
{
    self = [super initWithFrame:frame];
    if (self) {
        _isReturned = isReturned;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat componentViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:80.0f];
    CGFloat headImageViewHeght = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50];
    
    //姓名 日期
    _infoView = [[[JCHClientDetailAnalyseHeaderComponentView alloc] initWithFrame:CGRectZero] autorelease];
    _infoView.headImageView.layer.cornerRadius = headImageViewHeght / 2;
    _infoView.headImageView.clipsToBounds = YES;
    [self addSubview:_infoView];
    
    [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(componentViewHeight);
    }];
    
    UIView *horizontalLine = [[[UIView alloc] init] autorelease];
    horizontalLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:horizontalLine];
    
    [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_infoView.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    if (_isReturned) {

        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"allbills_analyse"]] autorelease];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.width.height.mas_equalTo(30);
            make.top.equalTo(_infoView.mas_bottom).with.offset((componentViewHeight - 30) / 2);
        }];
        
        _titleLabelForReturnedIndex = [JCHUIFactory createLabel:CGRectZero
                                                          title:@""
                                                           font:JCHFont(13)
                                                      textColor:JCHColorMainBody
                                                         aligin:NSTextAlignmentLeft];
        [self addSubview:_titleLabelForReturnedIndex];
        
        [_titleLabelForReturnedIndex mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).with.offset(kStandardLeftMargin);
            make.top.bottom.equalTo(imageView);
            make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        }];
        
        _detailLabelForReturnedIndex = [JCHUIFactory createLabel:CGRectZero
                                                           title:@""
                                                            font:JCHFont(15)
                                                       textColor:JCHColorMainBody
                                                          aligin:NSTextAlignmentRight];
        [self addSubview:_detailLabelForReturnedIndex];
        
        [_detailLabelForReturnedIndex mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).with.offset(kStandardLeftMargin);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(_titleLabelForReturnedIndex);
        }];
    } else {
        //全部货单信息
        _totalManifsetView = [[[JCHClientDetailAnalyseHeaderComponentView alloc] initWithFrame:CGRectZero] autorelease];
        _totalManifsetView.headImageView.image = [UIImage imageNamed:@"allbills_analyse"];
        _totalManifsetView.titleLabel.text = @"¥0.00";
        _totalManifsetView.detailLabel.text = @"全部货单(0)";
        [_totalManifsetView.headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
        }];
        [self addSubview:_totalManifsetView];
        
        [_totalManifsetView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.height.equalTo(_infoView);
            make.right.equalTo(self.mas_centerX);
            make.top.equalTo(_infoView.mas_bottom);
        }];
        
        //应收货单信息
        _receivableView = [[[JCHClientDetailAnalyseHeaderComponentView alloc] initWithFrame:CGRectZero] autorelease];
        _receivableView.headImageView.image = [UIImage imageNamed:@"receivables_analyse"];
        _receivableView.titleLabel.text = @"¥0.00";
        _receivableView.detailLabel.text = @"应收货单(0)";
        [_receivableView.headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
        }];
        [self addSubview:_receivableView];
        
        [_receivableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_totalManifsetView);
            make.left.equalTo(_totalManifsetView.mas_right);
            make.right.equalTo(self);
        }];
        
        UIView *verticalLine = [[[UIView alloc] init] autorelease];
        verticalLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:verticalLine];
        
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(horizontalLine.mas_bottom);
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
        }];
    }
}

- (void)setViewData:(JCHClientDetailAnalyseHeaderViewData *)data
{
    CGFloat headImageViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:50];
    
    UIImage *headImage = [UIImage imageNamed:data.headImageName];
    if (headImage) {
        _infoView.headImageView.image = headImage;
    } else {
        
        _infoView.headImageView.image = [UIImage imageWithColor:nil
                                                           size:CGSizeMake(headImageViewWidth, headImageViewWidth)
                                                           text:data.name
                                                           font:[UIFont jchSystemFontOfSize:19.0f]];
    }
    _infoView.titleLabel.text = data.name;
    _infoView.detailLabel.text = data.dateRange;
    
    if (_isReturned) {
        _titleLabelForReturnedIndex.text = [NSString stringWithFormat:@"退货货单(%ld)", data.totalCount ];
        _detailLabelForReturnedIndex.text = [NSString stringWithFormat:@"¥%.2f", data.totalAmount];
    } else {
        _totalManifsetView.titleLabel.text = [NSString stringWithFormat:@"¥%.2f", data.totalAmount];
        _totalManifsetView.detailLabel.text = [NSString stringWithFormat:@"全部货单(%ld)", data.totalCount];
        _receivableView.titleLabel.text = [NSString stringWithFormat:@"¥%.2f", data.receivableAmount];
        _receivableView.detailLabel.text = [NSString stringWithFormat:@"应收货单(%ld)", data.receivableCount];
    }
}



@end
