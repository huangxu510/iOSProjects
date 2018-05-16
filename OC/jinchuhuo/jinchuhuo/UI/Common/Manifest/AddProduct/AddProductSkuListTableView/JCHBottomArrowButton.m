//
//  JCHBottomArrowButton.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBottomArrowButton.h"
#import "CommonHeader.h"

@interface JCHBottomArrowButton ()

@property (nonatomic, retain) NSMutableArray *titleColors;
@property (nonatomic, retain) NSMutableArray *backgroundColors;
@property (nonatomic, retain) NSMutableArray *titles;

@end

@implementation JCHBottomArrowButton
{
    UIView *_bottomLine;
    UIImageView *_arrowImageView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleColors = [NSMutableArray array];
        self.backgroundColors = [NSMutableArray array];
        self.titles = [NSMutableArray array];
        
        for (NSInteger i = 0; i <= UIControlStateSelected; i++) {
            [self.titleColors addObject:JCHColorMainBody];
            [self.backgroundColors addObject:[UIColor whiteColor]];
            [self.titles addObject:@""];
        }
        
        [self setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
        [self setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
        [self setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
        [self setBackgroundColor:UIColorFromRGB(0xfffbf2) forState:UIControlStateSelected];
        
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:JCHFont(14.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.35);
        }];
        
        self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@""
                                                font:JCHFont(9.0)
                                           textColor:JCHColorAuxiliary
                                              aligin:NSTextAlignmentCenter];
        [self addSubview:self.detailLabel];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.left.right.equalTo(self.titleLabel);
            make.height.mas_equalTo(self).multipliedBy(0.3);
        }];
        
        _bottomLine = [[[UIView alloc] init] autorelease];
        _bottomLine.backgroundColor = JCHColorHeaderBackground;
        _bottomLine.hidden = YES;
        [self addSubview:_bottomLine];
        
        
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(2);
        }];
        
        _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_focus"]] autorelease];
        _arrowImageView.hidden = YES;
        _arrowImageView.contentMode = UIViewContentModeBottom;
        [self addSubview:_arrowImageView];
        
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(_bottomLine);
            make.height.mas_equalTo(7);
        }];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)dealloc
{
    self.titleLabel = nil;
    self.detailLabel = nil;
    
    [super dealloc];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    if (state > UIControlStateSelected) {
        return;
    }
    
    [self.titleColors replaceObjectAtIndex:state withObject:color];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    if (state > UIControlStateSelected) {
        return;
    }
    
    [self.backgroundColors replaceObjectAtIndex:state withObject:backgroundColor];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    if (state > UIControlStateSelected) {
        return;
    }
    
    [self.titles replaceObjectAtIndex:state withObject:title];
}



- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    
    self.titleLabel.tag = tag;
}

- (void)setDetailLabelHidden:(BOOL)detailLabelHidden
{
    if (_detailLabelHidden != detailLabelHidden) {
        _detailLabelHidden = detailLabelHidden;
        self.detailLabel.hidden = detailLabelHidden;
        
        if (detailLabelHidden) {
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.centerY.equalTo(self.mas_centerY);
                make.height.mas_equalTo(self.mas_height).multipliedBy(0.3);
            }];
        } else {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.bottom.equalTo(self.mas_centerY);
                make.height.mas_equalTo(self.mas_height).multipliedBy(0.3);
            }];
        }
    }
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        _bottomLine.hidden = NO;
        [self bringSubviewToFront:_bottomLine];
        _arrowImageView.hidden = NO;
        self.titleLabel.textColor = self.titleColors[UIControlStateSelected];
        self.backgroundColor = self.backgroundColors[UIControlStateSelected];
    } else {
        _bottomLine.hidden = YES;
        [self sendSubviewToBack:_bottomLine];
        _arrowImageView.hidden = YES;
        self.titleLabel.textColor = self.enabled ? self.titleColors[UIControlStateNormal] : self.titleColors[UIControlStateDisabled];
        self.backgroundColor = self.backgroundColors[UIControlStateNormal];
    }
}


- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        self.titleLabel.textColor = self.titleColors[UIControlStateNormal];
        self.backgroundColor = self.backgroundColors[UIControlStateNormal];
    } else {
        self.titleLabel.textColor = self.titleColors[UIControlStateDisabled];
        self.backgroundColor = self.backgroundColors[UIControlStateDisabled];
    }
}

//- (void)setHighlighted:(BOOL)highlighted
//{
//    [super setHighlighted:highlighted];
//    
//    if (highlighted) {
//        self.titleLabel.textColor = self.titleColors[UIControlStateHighlighted];
//        self.backgroundColor = self.backgroundColors[UIControlStateHighlighted];
//    } else {
//        self.titleLabel.textColor = self.titleColors[UIControlStateNormal];
//        self.backgroundColor = self.backgroundColors[UIControlStateNormal];
//    }
//}

@end
