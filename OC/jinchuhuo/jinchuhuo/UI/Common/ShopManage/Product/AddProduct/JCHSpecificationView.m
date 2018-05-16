//
//  JCHSecificationView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSpecificationView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "SKURecord4Cocoa.h"
#import <Masonry.h>

@interface JCHSpecificationView ()
{
    UILabel *_specificationNameLabel;
    UIView *_labelContainerView;
    UIButton *_addButton;
    UIView *_bottomLine;
    CGFloat _specificationLabelWidth;
    CGFloat _addButtonWidth;
}
@property (nonatomic, retain) NSDictionary *data;
@end

@implementation JCHSpecificationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        _labelContainerViewHeight = 44;
        _specificationLabelWidth = 60;
        _addButtonWidth = 53;
        [self createUI];
      
    }
    return self;
}

- (void)dealloc
{
    [self.data release];
    
    [super dealloc];
}

- (void)createUI
{
    _specificationNameLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"添加规格"
                                       font:[UIFont systemFontOfSize:15.0f]
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentLeft];
    
    [self addSubview:_specificationNameLabel];
    
    
    _addButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(addAction)
                                      title:nil
                                 titleColor:nil
                            backgroundColor:[UIColor whiteColor]];
    [_addButton setImage:[UIImage imageNamed:@"btn_setting_goods_add"] forState:UIControlStateNormal];
    [self addSubview:_addButton];
    
    _labelContainerView = [[[UIView alloc] init] autorelease];
    [self addSubview:_labelContainerView];
    
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
    
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

                            
    [_addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.mas_equalTo(_addButtonWidth);
        make.height.mas_equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    [_labelContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_specificationNameLabel.mas_right);
        make.right.equalTo(_addButton.mas_left).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(_labelContainerViewHeight);
    }];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_specificationNameLabel);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)addAction
{
    if ([self.delegate respondsToSelector:@selector(specificationViewAddItem:)]) {
        [self.delegate specificationViewAddItem:self];
    }
}

- (void)setLabelData:(NSDictionary *)data
{
    self.data = data;
    
    if ([[self.data allKeys] count] > 0) {
        _specificationNameLabel.text = [_data allKeys][0];
        
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]};
        CGSize size = CGSizeMake(1000, 44);
        CGRect resultFrame = [_specificationNameLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        _specificationLabelWidth = MAX(resultFrame.size.width, 40);
        [_specificationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_specificationLabelWidth);
        }];
    }
    else
    {
        _specificationNameLabel.text = @"添加规格";
    }
    
    [_labelContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createLabels];
}

- (void)createLabels
{
    UIFont *titleFont = [UIFont systemFontOfSize:15.0f];
    CGRect previousFrame = CGRectZero;
    
    CGFloat labelHeight = 24;
    CGSize size = CGSizeMake(1000, labelHeight);
    NSDictionary *attr = @{NSFontAttributeName : titleFont};
    const CGFloat widthOffset = 10;
    const CGFloat heightOffset = 10;
    CGFloat labelContainerViewWidth = kScreenWidth - _specificationLabelWidth - _addButtonWidth;
    
    _labelContainerViewHeight = 2 * heightOffset + labelHeight;

    NSArray *allValues = [self.data allValues][0];
    for (NSInteger i = 0; i < [allValues count]; i++)
    {
        
        NSString *labelText = [allValues[i] skuValue];
       
        
    
        UILabel *label = [JCHUIFactory createLabel:CGRectZero
                                             title:labelText
                                              font:titleFont
                                         textColor:JCHColorAuxiliary
                                            aligin:NSTextAlignmentCenter];
  
        label.backgroundColor = JCHColorGlobalBackground;
        label.layer.cornerRadius = labelHeight / 2;
        label.clipsToBounds = YES;
        [_labelContainerView addSubview:label];
        
        
        CGRect resultFrame = [labelText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        if (resultFrame.size.width < 30) {
            resultFrame.size.width = 30;
        }
        CGFloat currentLableWidth = (NSInteger)((resultFrame.size.width + 2 * widthOffset) + 0.5);
        CGFloat currentLabelHeight = labelHeight;
        if (i == 0) {
            label.frame = CGRectMake(widthOffset, heightOffset, currentLableWidth, currentLabelHeight);
        }
        else
        {
            if ((previousFrame.origin.x + previousFrame.size.width + currentLableWidth + 2 * widthOffset) > labelContainerViewWidth) {
                previousFrame.origin.x = widthOffset;
                previousFrame.origin.y += heightOffset + currentLabelHeight;
                previousFrame.size.width = currentLableWidth;
                label.frame = previousFrame;
                _labelContainerViewHeight += heightOffset + currentLabelHeight;
            }
            else
            {
                previousFrame.origin.x += widthOffset + previousFrame.size.width;
                previousFrame.size.width = currentLableWidth;
                label.frame = previousFrame;
            }
        }
        
        previousFrame = label.frame;
    }

    
//    [self setNeedsLayout];
}

- (void)hideBottomLine:(BOOL)hidden
{
    _bottomLine.hidden = hidden;
}

@end
