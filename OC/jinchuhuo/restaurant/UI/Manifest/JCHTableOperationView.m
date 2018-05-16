//
//  JCHTableOperationView.m
//  jinchuhuo
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTableOperationView.h"
#import "CommonHeader.h"
#import "JCHSizeUtility.h"


@interface JCHTableOperationView ()
{
    UIView *contentView;
    JCHButton *cancelTableButton;
    JCHButton *reserveTableButton;
    JCHButton *chooseDishButton;
    JCHButton *changeTableButton;
    JCHButton *changeManifestButton;
    UIImageView *arrowImageView;
    
    UIView *seperatorViewArray[3];
    
    CGFloat currnetContentOffset;
    NSInteger currentCellIndex;
    CGFloat currentLeftOffset;
}
@end


@implementation JCHTableOperationView

- (id)initWithFrame:(CGRect)frame
      contentOffset:(CGFloat)contentOffset
          cellIndex:(NSInteger)cellIndex
         leftOffset:(CGFloat)leftOffset
{
    self = [super initWithFrame:frame];
    if (self) {
        currnetContentOffset = contentOffset;
        currentCellIndex = cellIndex;
        currentLeftOffset = leftOffset;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    UIColor *buttonColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    UIColor *textColor = JCHColorMainBody;
    UIFont *bottonFont = JCHFont(13.0);
    CGFloat labelVerticalOffset = -8.0;
    
    contentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    
    cancelTableButton = [JCHUIFactory createJCHButton:CGRectZero
                                               target:self
                                               action:@selector(handleCancelTable:)
                                                title:@"撤台"
                                           titleColor:textColor
                                      backgroundColor:buttonColor];
    [contentView addSubview:cancelTableButton];
    [cancelTableButton setImage:[UIImage imageNamed:@"table_1"]
                       forState:UIControlStateNormal];
    cancelTableButton.titleLabel.font = bottonFont;
    cancelTableButton.layer.cornerRadius = 0;
    cancelTableButton.labelVerticalOffset = labelVerticalOffset;
    
    chooseDishButton = [JCHUIFactory createJCHButton:CGRectZero
                                              target:self
                                              action:@selector(handleChooseDish:)
                                               title:@"点菜"
                                          titleColor:textColor
                                     backgroundColor:buttonColor];
    [contentView addSubview:chooseDishButton];
    [chooseDishButton setImage:[UIImage imageNamed:@"table_3"]
                      forState:UIControlStateNormal];
    chooseDishButton.titleLabel.font = bottonFont;
    chooseDishButton.layer.cornerRadius = 0;
    chooseDishButton.labelVerticalOffset = labelVerticalOffset;
    
    changeTableButton = [JCHUIFactory createJCHButton:CGRectZero
                                               target:self
                                               action:@selector(handleChangeTable:)
                                                title:@"换台"
                                           titleColor:textColor
                                      backgroundColor:buttonColor];
    [contentView addSubview:changeTableButton];
    [changeTableButton setImage:[UIImage imageNamed:@"table_4"]
                       forState:UIControlStateNormal];
    changeTableButton.titleLabel.font = bottonFont;
    changeTableButton.layer.cornerRadius = 0;
    changeTableButton.labelVerticalOffset = labelVerticalOffset;
    
    changeManifestButton = [JCHUIFactory createJCHButton:CGRectZero
                                                  target:self
                                                  action:@selector(handleChangeManifest:)
                                                   title:@"改单"
                                              titleColor:textColor
                                         backgroundColor:buttonColor];
    [contentView addSubview:changeManifestButton];
    [changeManifestButton setImage:[UIImage imageNamed:@"table_5"]
                          forState:UIControlStateNormal];
    changeManifestButton.titleLabel.font = bottonFont;
    changeManifestButton.layer.cornerRadius = 0;
    changeManifestButton.labelVerticalOffset = labelVerticalOffset;
    
    for (size_t i = 0; i < 3; ++i) {
        UIView *seperatorView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
        [contentView addSubview:seperatorView];
        seperatorView.backgroundColor = [UIColor lightGrayColor];
        seperatorViewArray[i] = seperatorView;
    }


    arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"open_table_arrow.png"]] autorelease];
    [contentView addSubview:arrowImageView];

    
    self.clipsToBounds = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIButton *buttonArray[] = {
                                cancelTableButton,
                                chooseDishButton,
                                changeTableButton,
                                changeManifestButton
                            };
    

    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:65.0];
    CGFloat buttonHeight = buttonWidth;
    
    for (size_t i = 0; i < sizeof(buttonArray) / sizeof(buttonArray[0]); ++i) {
        UIButton *theButton = buttonArray[i];
        [theButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView.mas_top);
            make.height.mas_equalTo(buttonHeight);
            make.width.mas_equalTo(buttonWidth);
            make.left.equalTo(contentView).with.offset((buttonWidth + kSeparateLineWidth) * i);
        }];
    }
    
    for (size_t i = 0; i < 3; ++i) {
        UIView *theLine = seperatorViewArray[i];
        UIButton *theButton = buttonArray[i];
        [theLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(theButton.mas_top).with.offset(14);
            make.bottom.equalTo(theButton.mas_bottom).with.offset(-14);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.left.equalTo(theButton.mas_right);
        }];
    }
    
    CGFloat xPos = 0.0;
    CGFloat cellWidth = (kScreenWidth - currentLeftOffset) / 4;
    NSInteger showArrowAtButtonIndex = currentCellIndex % 4;
    xPos = currentLeftOffset + (showArrowAtButtonIndex * cellWidth) + (cellWidth - buttonWidth) / 2 - showArrowAtButtonIndex * buttonWidth;
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(xPos);
        make.width.mas_equalTo(buttonWidth * 4 + kSeparateLineWidth * 4);
        make.top.equalTo(self.mas_top).with.offset(currnetContentOffset);
        make.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *bottomButton = buttonArray[showArrowAtButtonIndex];
    
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView.mas_top);
        make.centerX.equalTo(bottomButton.mas_centerX);
        make.height.mas_equalTo(8);
        make.width.mas_equalTo(16);
    }];
}

#pragma mark -
#pragma mark 撤台
- (void)handleCancelTable:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleCancelTable:)]) {
        [self.delegate handleCancelTable:currentCellIndex];
    }
}

#pragma mark -
#pragma mark 预订
- (void)handleReserveTable:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleReserveTable:)]) {
        [self.delegate handleReserveTable:currentCellIndex];
    }
}

#pragma mark -
#pragma mark 点菜
- (void)handleChooseDish:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleChooseDish:)]) {
        [self.delegate handleChooseDish:currentCellIndex];
    }
}

#pragma mark -
#pragma mark 换台
- (void)handleChangeTable:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleChangeTable:)]) {
        [self.delegate handleChangeTable:currentCellIndex];
    }
}

#pragma mark -
#pragma mark 改单
- (void)handleChangeManifest:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleChangeManifest:)]) {
        [self.delegate handleChangeManifest:currentCellIndex];
    }
}

@end
