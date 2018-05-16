//
//  JCHDishesCharacterEditView.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutDishesCharacterEditView.h"
#import "JCHTakeoutDishesCharacterLabelEditView.h"
#import "CommonHeader.h"

@interface JCHTakeoutDishesCharacterEditView ()


@end

@implementation JCHTakeoutDishesCharacterEditView
{
    UIView *_middleLabelContainerView;
    JCHTakeoutDishesCharacterLabelEditView *_footerView;
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
    self.characterTitleTextField = nil;
    self.delectCharacterBlock = nil;
    self.updateViewHeightBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat deleteButtonWidth = 20;
    
    UIButton *deleteButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleDeleteCharacter)
                                                  title:@""
                                             titleColor:JCHColorMainBody
                                        backgroundColor:nil];
    [deleteButton setImage:[UIImage imageNamed:@"bt_setting_delete"] forState:UIControlStateNormal];
    [deleteButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self addSubview:deleteButton];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(deleteButtonWidth);
        make.top.equalTo(self).offset((kStandardItemHeight - deleteButtonWidth) / 2);
    }];
    
    self.characterTitleTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:@"特性名称" textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    [self addSubview:self.characterTitleTextField];
    
    [self.characterTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(deleteButton.mas_left).offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    seprateLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:seprateLine];
    
    [seprateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(self);
        make.bottom.equalTo(self.characterTitleTextField);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _middleLabelContainerView = [[[UIView alloc] init] autorelease];
    [self addSubview:_middleLabelContainerView];
    
    [_middleLabelContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(self);
        make.top.equalTo(self.characterTitleTextField.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    _footerView = [[[JCHTakeoutDishesCharacterLabelEditView alloc] initWithFrame:CGRectZero isFooterView:YES] autorelease];
    
    WeakSelf;
    [_footerView setAddLabelBlock:^{
        [weakSelf handleAddLabel:nil];
    }];

    [self addSubview:_footerView];
    
    [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_middleLabelContainerView);
        make.top.equalTo(_middleLabelContainerView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    self.viewHeight =  2 * kStandardItemHeight;
}

- (void)handleAddLabel:(NSString *)text
{
    WeakSelf;
    JCHTakeoutDishesCharacterLabelEditView *label = [[[JCHTakeoutDishesCharacterLabelEditView alloc] initWithFrame:CGRectZero isFooterView:NO] autorelease];
    if (text == nil) {
        [label.labelTextField becomeFirstResponder];
    } else {
        label.labelTextField.text = text;
    }
    
    label.tag = _middleLabelContainerView.subviews.count;
    label.deleteLabelBlock = ^{
        [weakSelf handleDeleteLabel:label];
    };

    [label addSeparateLineWithMasonryTop:NO bottom:YES];
    [_middleLabelContainerView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_middleLabelContainerView);
        make.top.equalTo(_middleLabelContainerView).offset(label.tag * kStandardItemHeight);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [_middleLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_middleLabelContainerView.subviews.count * kStandardItemHeight);
    }];
    
    
    self.viewHeight = (_middleLabelContainerView.subviews.count + 2) * kStandardItemHeight;
    
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.viewHeight);
//    }];
    
    if (self.updateViewHeightBlock) {
        self.updateViewHeightBlock(self);
    }
}

- (void)handleDeleteLabel:(JCHTakeoutDishesCharacterLabelEditView *)label
{
    [label removeFromSuperview];
    
    for (NSInteger i = 0; i < _middleLabelContainerView.subviews.count; i++) {
        JCHTakeoutDishesCharacterLabelEditView *subView = _middleLabelContainerView.subviews[i];
        subView.tag = i;
        [subView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_middleLabelContainerView).offset(i * kStandardItemHeight);
        }];
    }
    
    [_middleLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_middleLabelContainerView.subviews.count * kStandardItemHeight);
    }];
    
    self.viewHeight = (_middleLabelContainerView.subviews.count + 2) * kStandardItemHeight;
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.viewHeight);
    }];
    
    if (self.updateViewHeightBlock) {
        self.updateViewHeightBlock(self);
    }
}

- (void)handleDeleteCharacter
{
    if (self.delectCharacterBlock) {
        self.delectCharacterBlock(self);
    }
}

- (NSDictionary *)getData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *labels = [NSMutableArray array];
    for (NSInteger i = 0; i < _middleLabelContainerView.subviews.count; i++) {
        JCHTakeoutDishesCharacterLabelEditView *subView = _middleLabelContainerView.subviews[i];
        if (![subView.labelTextField.text isEmptyString]) {
            [labels addObject:subView.labelTextField.text];
        }
    }

    [dict setObject:labels forKey:@"values"];
    [dict setObject:self.characterTitleTextField.text forKeyedSubscript:@"propertyName"];
    
    return dict;
}

- (void)setData:(NSDictionary *)data
{
    NSString *title = data[@"propertyName"];
    self.characterTitleTextField.text = title;
    NSArray *values = data[@"values"];
    for (NSString *label in values) {
        [self handleAddLabel:label];
    }
}

@end
