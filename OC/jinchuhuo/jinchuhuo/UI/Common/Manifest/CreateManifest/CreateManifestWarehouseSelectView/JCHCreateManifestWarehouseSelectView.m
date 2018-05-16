//
//  JCHCreateManifestWarehouseSelectView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCreateManifestWarehouseSelectView.h"
#import "CommonHeader.h"

@implementation JCHCreateManifestWarehouseSelectView
{
    UILabel *_sourceDetailLabel;
    UILabel *_destinationDetaiLabel;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.selectWarehouse = nil;
    self.sourceWarehouse = nil;
    self.destinationWarehouse = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];

    
    [self addSeparateLineWithMasonryTop:YES bottom:YES];
    
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:38];
    UIImageView *arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createManifest_bt_transfer"]] autorelease];
    arrowImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:arrowImageView];
    
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imageViewWidth);
        make.centerX.centerY.equalTo(self);
    }];
    
    UILabel *sourceTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"源仓库"
                                                     font:JCHFont(12.0)
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentLeft];
    [self addSubview:sourceTitleLabel];
    
    CGSize fitSize = [sourceTitleLabel sizeThatFits:CGSizeZero];
    [sourceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(arrowImageView.mas_left).offset(-kStandardLeftMargin);
        make.top.equalTo(self).offset(kStandardLeftMargin / 2);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
    
    _sourceDetailLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"默认仓库"
                                              font:JCHFont(14.0)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:_sourceDetailLabel];
    
    fitSize = [_sourceDetailLabel sizeThatFits:CGSizeZero];
    [_sourceDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-kStandardLeftMargin / 2);
        make.left.right.equalTo(sourceTitleLabel);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
    
    UILabel *destinationTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                         title:@"目标仓库"
                                                          font:JCHFont(12.0)
                                                     textColor:JCHColorAuxiliary
                                                        aligin:NSTextAlignmentRight];
    [self addSubview:destinationTitleLabel];
    
    [destinationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(arrowImageView.mas_right).offset(kStandardLeftMargin);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(sourceTitleLabel);
    }];
    
    _destinationDetaiLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"选择仓库"
                                                  font:JCHFont(14.0)
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentRight];
    [self addSubview:_destinationDetaiLabel];
    
    [_destinationDetaiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(destinationTitleLabel);
        make.top.height.equalTo(_sourceDetailLabel);
    }];
    
    UIControl *control = [[[UIControl alloc] init] autorelease];
    [control addTarget:self action:@selector(handleSelectDestinationWarehouse) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:control];
    
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(arrowImageView.mas_right);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)handleSelectDestinationWarehouse
{
    if (self.selectWarehouse) {
        self.selectWarehouse();
    }
}

- (void)setDestinationWarehouse:(NSString *)destinationWarehouse
{
    if (_destinationWarehouse != destinationWarehouse) {
        [_destinationWarehouse release];
        _destinationWarehouse = [destinationWarehouse retain];
        if (destinationWarehouse && ![destinationWarehouse isEmptyString]) {
            _destinationDetaiLabel.text = destinationWarehouse;
            _destinationDetaiLabel.textColor = JCHColorMainBody;
        } else {
            _destinationDetaiLabel.text = @"选择仓库";
            _destinationDetaiLabel.textColor = JCHColorAuxiliary;
        }
    }
}

- (void)setSourceWarehouse:(NSString *)sourceWarehouse
{
    if (_sourceWarehouse != sourceWarehouse) {
        [_sourceWarehouse release];
        _sourceWarehouse = [sourceWarehouse retain];
        _sourceDetailLabel.text = sourceWarehouse;
    }
}

@end
