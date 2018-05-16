//
//  JCHPrinterTemplateView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPrinterTemplateView.h"
#import "CommonHeader.h"

@implementation JCHPrinterTemplateViewData

- (void)dealloc
{
    self.title = nil;
    self.imageName = nil;
    
    [super dealloc];
}

@end

@implementation JCHPrinterTemplateView
{
    UILabel *_titleLabel;
    UIImageView *_imageView;
    UIButton *_selectButton;
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
    CGFloat titleLabelHeight = 40;
    CGFloat selectButtonWidth = 50;
    
    _selectButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(selectPrintTemplate)
                                         title:@""
                                    titleColor:JCHColorMainBody
                               backgroundColor:[UIColor whiteColor]];
    [_selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self addSubview:_selectButton];
    
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(selectButtonWidth);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(_selectButton.mas_left).offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _imageView = [[[UIImageView alloc] init] autorelease];
    _imageView.backgroundColor = JCHColorBlueButton;
    [self addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
    }];
    
    
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPrintTemplate)] autorelease];
    [self addGestureRecognizer:tap];
}

- (void)selectPrintTemplate
{
    if (self.selectBlock) {
        self.selectBlock();
    }
    self.selected = !self.selected;
}

- (void)setViewData:(JCHPrinterTemplateViewData *)data
{
    _imageView.image = [UIImage imageNamed:data.imageName];
    _titleLabel.text = data.title;
}

- (BOOL)selected
{
    return _selectButton.selected;
}

- (void)setSelected:(BOOL)selected
{
    _selectButton.selected = selected;
}

@end
