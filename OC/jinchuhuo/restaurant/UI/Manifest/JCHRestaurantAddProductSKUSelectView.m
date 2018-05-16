//
//  JCHRestaurantAddProductSKUSelectView.m
//  jinchuhuo
//
//  Created by apple on 2017/2/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantAddProductSKUSelectView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "SKURecord4Cocoa.h"
#import "UIImage+JCHImage.h"
#import <Masonry.h>

@interface JCHRestaurantAddProductSKUSelectView ()
{
    UILabel *_skuTypeNameLabel;
    UIView *_buttonContainerView;
    UIImageView *_brokenLineView;
    CGFloat _nameLabelHeight;
}
@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, retain) NSDictionary *skuData;
@property (nonatomic, retain) NSDictionary *propertyData;
@end

@implementation JCHRestaurantAddProductSKUSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewHeight = 0;
        _nameLabelHeight = 30;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.buttons release];
    self.skuData = nil;
    self.propertyData = nil;
    
    [super dealloc];
}

- (void)createUI
{
    _skuTypeNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"添加新规格"
                                             font:[UIFont systemFontOfSize:13.0f]
                                        textColor:JCHColorAuxiliary
                                           aligin:NSTextAlignmentLeft];
    
    [self addSubview:_skuTypeNameLabel];
    
    
    _buttonContainerView = [[[UIView alloc] init] autorelease];
    [self addSubview:_buttonContainerView];
    
    _brokenLineView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [self addSubview:_brokenLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_skuTypeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(5);
        make.height.mas_equalTo(_nameLabelHeight);
        make.left.equalTo(self).with.offset(10);
        make.right.equalTo(self).with.offset(-10);
    }];
    
    [_buttonContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self).with.offset(-10);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(self.viewHeight - _nameLabelHeight);
    }];
    
    
    [_brokenLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuTypeNameLabel);
        make.right.equalTo(_skuTypeNameLabel);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

/**
 *      data ->   @{skuTypeName : @[skuValueRecord, ...]}
 */
- (void)setButtonSKUData:(NSDictionary *)data
{
    self.skuData = data;
    
    if ([[data allKeys] count] > 0) {
        _skuTypeNameLabel.text = [data allKeys][0];
    }
    
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *allValues = [self.skuData allValues].firstObject;
    NSMutableArray *titles = [NSMutableArray array];
    for (SKUValueRecord4Cocoa *skuValuesRecord in allValues) {
        [titles addObject:skuValuesRecord.skuValue];
    }
    [self createButtons:titles];
}



/**
    data -> @{@"propertyName" : @"",
                    @"values" : @[]}
 */
- (void)setButtonPropertyData:(NSDictionary *)data
{
    if (!data) {
        return;
    }
    self.propertyData = data;
    NSString *propertyName = data[@"propertyName"];
    NSArray *values = data[@"values"];
    _skuTypeNameLabel.text = propertyName;
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createButtons:values];
}

- (void)createButtons:(NSArray *)titles
{
    UIFont *titleFont = [UIFont systemFontOfSize:15.0f];
    CGRect previousFrame = CGRectZero;
    
    CGFloat buttonHeight = 24;
    CGSize size = CGSizeMake(1000, buttonHeight);
    NSDictionary *attr = @{NSFontAttributeName : titleFont};
    const CGFloat widthOffset = 10;
    const CGFloat heightOffset = 10;
    CGFloat buttonContainerViewWidth = self.frame.size.width;
    
    CGFloat buttonContainerViewHeight = 2 * heightOffset + buttonHeight;
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++)
    {
        
        NSString *buttonTitle = titles[i];
        
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleSelectedItem:)
                                                title:@""
                                           titleColor:JCHColorAuxiliary
                                      backgroundColor:[UIColor whiteColor]];
        
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        // [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x69a4f1)] forState:UIControlStateSelected];
        // [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf3f3f3)] forState:UIControlStateNormal];
        [button setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
        button.adjustsImageWhenHighlighted = NO;
        button.layer.borderWidth = kSeparateLineWidth;
        button.layer.borderColor = JCHColorAuxiliary.CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_buttonContainerView addSubview:button];
        [buttons addObject:button];
        
        if ((titles.count == 1) && self.autoSelectIfOneSKUValue) {
            [self handleSelectedItem:button];
        }
        
        CGRect resultFrame = [buttonTitle boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        if (resultFrame.size.width < 30) {
            resultFrame.size.width = 30;
        }
        
        resultFrame.size.width += 15;
        
        button.layer.cornerRadius = buttonHeight / 2;
        CGFloat currentButtonWidth = resultFrame.size.width + 2 * widthOffset;
        CGFloat currentButtonHeight = buttonHeight;
        
        
        if (i == 0) {
            button.frame = CGRectMake(widthOffset, heightOffset / 2, currentButtonWidth, currentButtonHeight);
        }
        else
        {
            if ((previousFrame.origin.x + previousFrame.size.width + currentButtonWidth + 2 * widthOffset) > buttonContainerViewWidth) {
                previousFrame.origin.x = widthOffset;
                previousFrame.origin.y += heightOffset + currentButtonHeight;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
                buttonContainerViewHeight += heightOffset / 2 + currentButtonHeight;
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
    self.viewHeight = buttonContainerViewHeight + _nameLabelHeight;
    [self setNeedsLayout];
}

- (void)handleSelectedItem:(UIButton *)sender
{
    for (UIButton *button in _buttons) {
        if (button != sender) {
            button.selected = NO;
            button.layer.borderColor = JCHColorAuxiliary.CGColor;
        } else {
            button.selected = YES;
            button.layer.borderColor = JCHColorHeaderBackground.CGColor;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(clickSKUItemButton:)]) {
        [self.delegate clickSKUItemButton:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(viewEndEditing:)]) {
        [self.delegate viewEndEditing:self];
    }
}

- (NSArray *)selectedSKUData
{
    NSMutableArray *selectedData = [NSMutableArray array];
    

    NSArray *allData = [self.skuData allValues][0];
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        if (button.selected) {
            [selectedData addObject:allData[i]];
        }
    }
    
    
    return [selectedData retain];
}

- (NSString *)selectedPropertyData
{
    NSArray *allData = self.propertyData[@"values"];
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        if (button.selected) {
            return allData[i];
        }
    }
    return @"";
}

- (void)selectButtons:(NSArray *)skuValueUUIDs
{
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        SKUValueRecord4Cocoa *skuValueRecord = [self.skuData allValues][0][i];
        if ([skuValueUUIDs containsObject:skuValueRecord.skuValueUUID]) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
}

- (void)deselectAllButtons
{
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        button.selected = NO;
    }
}

- (void)unselectData
{
    for (UIButton *button in _buttonContainerView.subviews) {
        button.selected = NO;
    }
}


- (void)setBrokenLineViewHidden:(BOOL)hidden
{
    _brokenLineView.hidden = hidden;
}

@end
