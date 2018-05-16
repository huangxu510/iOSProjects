//
//  JCHTakeoutDishCharacterLabelEditView.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutDishesCharacterLabelEditView.h"
#import "CommonHeader.h"

@implementation JCHTakeoutDishesCharacterLabelEditView
{
    BOOL _isFooterView;
}

- (instancetype)initWithFrame:(CGRect)frame
                 isFooterView:(BOOL)isFooterView
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFooterView = isFooterView;
        
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.addLabelBlock = nil;
    self.deleteLabelBlock = nil;
    self.labelTextField = nil;
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat pointViewWidth = 8;
    CGFloat deleteButtonWidth = 20;
    
    UIView *pointView = [[[UIView alloc] init] autorelease];
    pointView.backgroundColor = JCHColorMainBody;
    pointView.layer.cornerRadius = pointViewWidth / 2;
    [self addSubview:pointView];
    
    [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
        make.width.height.mas_equalTo(pointViewWidth);
    }];
    
    UIButton *deleteButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleDeleteAction)
                                                  title:@""
                                             titleColor:JCHColorMainBody
                                        backgroundColor:[UIColor whiteColor]];
    [deleteButton setImage:[UIImage imageNamed:@"bt_setting_delete"] forState:UIControlStateNormal];
    [deleteButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self addSubview:deleteButton];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(deleteButtonWidth);
        make.centerY.equalTo(self);
    }];
    
    self.labelTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:@"特性标签" textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    self.labelTextField.font = JCHFont(14);
    [self addSubview:self.labelTextField];
    
    [self.labelTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pointView.mas_right).offset(kStandardLeftMargin);
        make.right.equalTo(deleteButton.mas_left).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self);
    }];
    
    if (_isFooterView) {
        pointView.backgroundColor = JCHColorAuxiliary;
        self.labelTextField.text = @"添加标签";
        self.labelTextField.enabled = NO;
        self.labelTextField.textColor = JCHColorAuxiliary;
        [deleteButton removeTarget:self action:@selector(handleDeleteAction) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton addTarget:self action:@selector(handleAddLabelAction) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setImage:[UIImage imageNamed:@"btn_setting_goods_add"] forState:UIControlStateNormal];
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddLabelAction)] autorelease];
        [self addGestureRecognizer:tap];
    }
}

- (void)handleDeleteAction
{
    if (self.deleteLabelBlock) {
        self.deleteLabelBlock();
    }
}

- (void)handleAddLabelAction
{
    if (self.addLabelBlock) {
        self.addLabelBlock();
    }
}

@end
