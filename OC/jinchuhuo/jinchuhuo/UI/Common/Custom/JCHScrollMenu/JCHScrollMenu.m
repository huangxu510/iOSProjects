//
//  JCHScrollMenu.m
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHScrollMenu.h"
#import "CommonHeader.h"

@interface JCHScrollMenu ()
{
    UIView *bottomIndicatorView;
    NSInteger currentButtonIndex;
    UIView *bottomSeperateLine;
}

@property (retain, nonatomic, readwrite) NSArray<NSString *> *titlesArray;
@property (retain, nonatomic, readwrite) NSMutableArray<UIButton *> *buttonsArray;
@end

@implementation JCHScrollMenu

- (id)initWithFrame:(CGRect)frame menuTitles:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titlesArray = titles;
        currentButtonIndex = 0;
        self.buttonsArray = [[[NSMutableArray alloc] init] autorelease];
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [self.titlesArray release];
    [self.buttonsArray release];
    
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSInteger i = 0; i < self.buttonsArray.count; ++i) {
        UIButton *button = self.buttonsArray[i];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.width.equalTo(self).with.multipliedBy(1.0/self.buttonsArray.count);
            if (0 == i) {
                make.left.equalTo(self.mas_left);
            } else {
                make.left.equalTo(self.buttonsArray[i - 1].mas_right);
            }
        }];
    }
    
    const CGFloat bottomViewHeight = 2;
    [bottomIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.buttonsArray[0].mas_centerX);
        make.height.mas_equalTo(bottomViewHeight);
        make.width.mas_equalTo(30.0);
    }];
    
    self.buttonsArray[0].titleLabel.textColor = JCHColorHeaderBackground;
    
    [bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.width.equalTo(self);
    }];
    
    return;
}

- (void)createUI
{
    UIColor *textColor = JCHColorMainBody;
    for (NSInteger i = 0; i < self.titlesArray.count; ++i) {
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleClickMenu:)
                                                title:self.titlesArray[i]
                                           titleColor:textColor
                                      backgroundColor:[UIColor whiteColor]];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:button];
        
        [self.buttonsArray addObject:button];
    }
    
    bottomIndicatorView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:bottomIndicatorView];
    bottomIndicatorView.backgroundColor = JCHColorHeaderBackground;
    
    if (1 == self.titlesArray.count) {
        bottomIndicatorView.hidden = YES;
    }
    
    bottomSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self addSubview:bottomSeperateLine];
    
    return;
}

- (void)handleClickMenu:(UIButton *)button
{
    if (currentButtonIndex == button.tag) {
        return;
    } else {
        currentButtonIndex = button.tag;
    }
    
    CGPoint indicatorCenter = bottomIndicatorView.center;
    indicatorCenter.x = button.center.x;
    
    [UIView animateWithDuration:0.25 animations:^{
        bottomIndicatorView.center = indicatorCenter;
    }];
    
    if (self.delegate) {
        [self.delegate performSelector:@selector(handleClickScrollMenu:)
                            withObject:@(button.tag)];
    }
}


@end
