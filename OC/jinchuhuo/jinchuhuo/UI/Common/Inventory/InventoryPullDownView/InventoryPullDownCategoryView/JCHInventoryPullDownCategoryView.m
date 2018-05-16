//
//  JCHInventoryPullDownCategoryView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInventoryPullDownCategoryView.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "ServiceFactory.h"
#import <Masonry.h>

@interface JCHInventoryPullDownCategoryView ()
{
    UIView *_contentView;
    NSInteger _currentSelectButtonTag;
    CGFloat _contentViewHeight;
}

@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) NSArray *categoryData;
@property (nonatomic, retain) UIButton *selectedButton;
@end

@implementation JCHInventoryPullDownCategoryView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttons = [NSMutableArray array];
        _currentSelectButtonTag = 0;
        _contentViewHeight = 0;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.buttons release];
    [self.categoryData release];
    [self.selectedButton release];
    
    [super dealloc];
}

- (void)createUI
{
    _contentView = [[[UIView alloc] init] autorelease];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
}

- (void)selectButton:(NSInteger)index
{
    UIButton *button = self.buttons[index];

    [self.selectedButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    self.selectedButton.backgroundColor = [UIColor whiteColor];
    self.selectedButton.layer.borderWidth = kSeparateLineWidth;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = JCHColorHeaderBackground;
    button.layer.borderWidth = 0;
    
    self.selectedButton = button;
}

- (void)handleButtonClick:(UIButton *)sender
{
    [self.selectedButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    self.selectedButton.backgroundColor = [UIColor whiteColor];
    self.selectedButton.layer.borderWidth = kSeparateLineWidth;
    
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sender.backgroundColor = JCHColorHeaderBackground;
    sender.layer.borderWidth = 0;
    

    self.selectedButton = sender;
    
    if ([self.delegate respondsToSelector:@selector(pullDownView:buttonSelected:)]) {
        [self.delegate pullDownView:self buttonSelected:sender.tag];
    }
}

- (void)setData:(NSArray *)data
{
    self.categoryData = data;
    _currentSelectButtonTag = 0;
    //移除所有button
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.buttons removeAllObjects];
    [self createButtons];
}

- (void)createButtons
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    CGRect previousFrame = CGRectZero;
    
    CGFloat buttonHeight = 30;
    CGSize size = CGSizeMake(1000, buttonHeight);
    NSDictionary *attr = @{NSFontAttributeName : titleFont};
    const CGFloat widthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:18];
    const CGFloat heightOffset = 15;
    
    _contentViewHeight = 2 * heightOffset + buttonHeight;
    for (NSInteger i = 0; i <= self.categoryData.count; i++)
    {
        
        NSString *categoreName;
        if (i == 0)
        {
            categoreName = @"全部";
        }
        else
        {
            if ([self.categoryData[0] isKindOfClass:[CategoryRecord4Cocoa class]]) {
                CategoryRecord4Cocoa *categoryRecord = self.categoryData[i - 1];
                categoreName = categoryRecord.categoryName;
            } else if ([self.categoryData[0] isKindOfClass:[UnitRecord4Cocoa class]]) {
                UnitRecord4Cocoa *unitRecord = self.categoryData[i - 1];
                categoreName = unitRecord.unitName;
            }
        }
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleButtonClick:)
                                                title:categoreName
                                           titleColor:JCHColorMainBody
                                      backgroundColor:nil];
        button.titleLabel.font = titleFont;
        button.tag = kCategoryButtonTagBase + i;
        button.layer.borderWidth = kSeparateLineWidth;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.cornerRadius = buttonHeight / 2;
        [_contentView addSubview:button];
        [self.buttons addObject:button];
        
        if (button.tag == kCategoryButtonTagBase) {
            button.backgroundColor = JCHColorHeaderBackground;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.borderWidth = 0;
            self.selectedButton = button;
        }
        else
        {
            //pass
        }

        CGRect resultFrame = [categoreName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        CGFloat currentButtonWidth = resultFrame.size.width + 2 * widthOffset;
        CGFloat currentButtonHeight = buttonHeight;
        if (i == 0) {
            button.frame = CGRectMake(widthOffset / 2, heightOffset, currentButtonWidth, currentButtonHeight);
        }
        else
        {
            if ((previousFrame.origin.x + previousFrame.size.width + currentButtonWidth + 2 * widthOffset) > kScreenWidth) {
                previousFrame.origin.x = widthOffset / 2;
                previousFrame.origin.y += heightOffset + currentButtonHeight;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
                _contentViewHeight += heightOffset + currentButtonHeight;
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
    
    _contentView.frame = CGRectMake(0, 0, kScreenWidth, _contentViewHeight);
    self.maxHeight = _contentViewHeight;
}

- (NSString *)getSelectButtonTitle
{
    return self.selectedButton.currentTitle;
}

@end
