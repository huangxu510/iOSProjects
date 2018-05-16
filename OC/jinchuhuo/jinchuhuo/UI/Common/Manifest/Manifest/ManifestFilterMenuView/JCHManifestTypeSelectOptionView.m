//
//  JCHManifestTypeSelectOptionView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHManifestTypeSelectOptionView.h"
#import "CommonHeader.h"

@interface JCHManifestTypeSelectOptionView()

@property (nonatomic, retain) UIButton *selectedButton;

@end

@implementation JCHManifestTypeSelectOptionView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                   dataSource:(NSArray *)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        CGFloat titleLabelHeight = 25;
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:title
                                                   font:[UIFont jchBoldSystemFontOfSize:12]
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentLeft];
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(self);
            make.height.mas_equalTo(titleLabelHeight);
            make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin);
        }];
        
        
        CGFloat buttonHorizontalGap = kStandardLeftMargin;
        CGFloat buttonVerticalGap = 8;
        CGFloat buttonHeight = 30.0f;
        CGFloat buttonWidth = (kScreenWidth - 5 * buttonHorizontalGap) / 4;
        
        CGFloat viewHeight = titleLabelHeight;
        for (NSInteger i = 0; i < dataSource.count; i++) {
            CGFloat buttonX = i % 4 * buttonWidth + (i % 4 + 1) * buttonHorizontalGap;
            CGFloat buttonY = i / 4 * buttonHeight + (i / 4) * buttonVerticalGap + titleLabelHeight;
            UIButton *button = [JCHUIFactory createButton:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)
                                                   target:self
                                                   action:@selector(buttonClick:)
                                                    title:dataSource[i]
                                               titleColor:JCHColorMainBody
                                          backgroundColor:[UIColor whiteColor]];
            button.tag = i - 1;
            button.titleLabel.font = JCHFont(13.0);
            button.layer.borderWidth = kSeparateLineWidth;
            button.layer.borderColor = JCHColorSeparateLine.CGColor;
            [button setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
            [self addSubview:button];
            
            viewHeight = CGRectGetMaxY(button.frame);
        }
        viewHeight += buttonVerticalGap;
        
        _viewHeight = viewHeight;
    }
    return self;
}

- (void)dealloc
{
    self.buttonClick = nil;
    [super dealloc];
}

- (void)buttonClick:(UIButton *)sender
{
    if (sender == self.selectedButton) {
        return;
    }
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    _index = sender.tag;
    sender.selected = YES;
    
    if (self.buttonClick) {
        self.buttonClick(sender);
    }
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            if (subView.tag == index) {
                self.selectedButton.selected = NO;
                self.selectedButton = (UIButton *)subView;
                self.selectedButton.selected = YES;
            }
        }
    }
}

- (void)cancleSelect
{
    self.index = -2;
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
}

@end
