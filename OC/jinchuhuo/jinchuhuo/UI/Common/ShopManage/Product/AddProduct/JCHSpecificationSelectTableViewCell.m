//
//  JCHSpecificationSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSpecificationSelectTableViewCell.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "UIImage+JCHImage.h"
#import <Masonry.h>

@interface JCHSpecificationSelectTableViewCell ()
{
    UILabel *_specificationNameLabel;
    UIView *_buttonContainerView;
    UIView *_bottomLine;
    CGFloat _specificationLabelWidth;
}
@property (nonatomic, retain) NSArray *buttons;

@end
@implementation JCHSpecificationSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.clipsToBounds = YES;
        _buttonContainerViewHeight = 44;
        _specificationLabelWidth = 80;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.selectedData release];
    [self.buttons release];
    [self.data release];
    
    [super dealloc];
}

- (void)createUI
{
    _specificationNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"添加新规格"
                                                   font:[UIFont systemFontOfSize:15.0f]
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentLeft];
    
    [self.contentView addSubview:_specificationNameLabel];
    
    
    
    _buttonContainerView = [[[UIView alloc] init] autorelease];
    [self.contentView addSubview:_buttonContainerView];
    
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:_bottomLine];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_specificationNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(_specificationLabelWidth);
        make.top.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [_buttonContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_specificationNameLabel.mas_right);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(_buttonContainerViewHeight);
    }];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_specificationNameLabel);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setButtonData:(NSDictionary *)data
{
    self.data = data;
    
    if ([[data allKeys] count] > 0) {
        _specificationNameLabel.text = [data allKeys][0];
        
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]};
        CGSize size = CGSizeMake(1000, 44);
        CGRect resultFrame = [_specificationNameLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        _specificationLabelWidth = MAX(resultFrame.size.width + 10, 40) ;
        if (_specificationLabelWidth < 42) {
            _specificationLabelWidth = 42;
        }
        [_specificationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_specificationLabelWidth);
        }];
    }
    else
    {
        _specificationNameLabel.text = @"添加新规格";
    }
    
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createButtons];
}

- (void)createButtons
{
    UIFont *titleFont = [UIFont systemFontOfSize:15.0f];
    CGRect previousFrame = CGRectZero;
    
    CGFloat buttonHeight = 24;
    CGSize size = CGSizeMake(1000, buttonHeight);
    NSDictionary *attr = @{NSFontAttributeName : titleFont};
    const CGFloat widthOffset = 10;
    const CGFloat heightOffset = 10;
    CGFloat buttonContainerViewWidth = kScreenWidth - _specificationLabelWidth - kStandardLeftMargin;
    
    _buttonContainerViewHeight = 2 * heightOffset + buttonHeight;
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i = 0; i < [[self.data allValues][0] count]; i++)
    {
        
        NSString *buttonTitle = [[self.data allValues][0][i] skuValue];
        
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleSelectedItem:)
                                                title:@""
                                           titleColor:JCHColorAuxiliary
                                      backgroundColor:[UIColor whiteColor]];
        
        button.layer.cornerRadius = buttonHeight / 2;
        button.clipsToBounds = YES;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageWithColor:JCHColorGlobalBackground] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.adjustsImageWhenHighlighted = NO;
        button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        button.tag = i;
        [_buttonContainerView addSubview:button];
        [buttons addObject:button];
        
        CGRect resultFrame = [buttonTitle boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        if (resultFrame.size.width < 30) {
            resultFrame.size.width = 30;
        }
        CGFloat currentButtonWidth = resultFrame.size.width + 2 * widthOffset;
        CGFloat currentButtonHeight = buttonHeight;
        
        
        if (i == 0) {
            button.frame = CGRectMake(widthOffset, heightOffset, currentButtonWidth, currentButtonHeight);
        }
        else
        {
            if ((previousFrame.origin.x + previousFrame.size.width + currentButtonWidth + 2 * widthOffset) > buttonContainerViewWidth) {
                previousFrame.origin.x = widthOffset;
                previousFrame.origin.y += heightOffset + currentButtonHeight;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
                _buttonContainerViewHeight += heightOffset + currentButtonHeight;
            }
            else
            {
                previousFrame.origin.x += widthOffset + previousFrame.size.width;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
            }
        }
        
        previousFrame = button.frame;
    }
    
    self.buttons = buttons;
    
    [self setNeedsLayout];
}

- (void)handleSelectedItem:(UIButton *)sender
{
    BOOL unselectSuccess = YES;
    if (sender.selected) {
        if ([self.delegate respondsToSelector:@selector(unselectSKUValue: buttonTag:)]) {
            unselectSuccess = [self.delegate unselectSKUValue:self buttonTag:sender.tag];
        }
    }
    
    if (unselectSuccess) {
        sender.selected = !sender.selected;
        if ([self.delegate respondsToSelector:@selector(cellEndEditing:)]) {
            [self.delegate cellEndEditing:self];
        }
    }
}

- (NSArray *)selectedData
{
    NSMutableArray *selectedData = [NSMutableArray array];
    NSArray *allData = [self.data allValues][0];
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        if (button.selected) {
            [selectedData addObject:allData[i]];
        }
    }
    return [selectedData retain];
}

- (void)setSelectedData:(NSArray *)selectedData
{
    
    NSArray *allData = [self.data allValues][0];
    for (NSInteger i = 0; i < allData.count; i++)
    {
        for (SKUValueRecord4Cocoa *record in selectedData) {
            if ([record.skuValue isEqualToString:[allData[i] skuValue]]) {
                UIButton *button = self.buttons[i];
                button.selected = YES;
                break;
            }
        }
    }
}


@end
