//
//  JCHAddSpecificationFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddSKUValueFooterView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import <Masonry.h>

@implementation JCHAddSKUValueFooterView
{
    UILabel *_titleLabel;
    UIImageView *_addImageView;
    UIButton *_addButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"添加属性"
                                       font:[UIFont systemFontOfSize:16]
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_titleLabel];
    
    
    
    _addImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_setting_goods_add"]] autorelease];
    [self addSubview:_addImageView];

    
    _addButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handleAddAttribute)
                                               title:nil
                                          titleColor:JCHColorAuxiliary
                                     backgroundColor:[UIColor clearColor]];
    [self addSubview:_addButton];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [_addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(23);
        make.centerY.equalTo(self);
    }];
    
    [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)handleAddAttribute
{
    if ([self.delegate respondsToSelector:@selector(addItem)]) {
        [self.delegate addItem];
    }
}

- (void)setTitleName:(NSString *)name
{
    _titleLabel.text = name;
}

@end
