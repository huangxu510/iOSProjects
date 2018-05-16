//
//  JCHTakeoutBindingTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutBindingTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHTakeoutBindingTableViewCellData

- (void)dealloc
{
    self.title = nil;
    self.imageName = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutBindingTableViewCell

{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UIButton *_rightButton;
}

- (void)dealloc
{
    self.bindingAction = nil;
    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat imageViewWidth = 50;
    CGFloat buttonWidth = 60;
    CGFloat buttonheight = 30;
    
    _iconImageView = [[[UIImageView alloc] init] autorelease];
    [self.contentView addSubview:_iconImageView];
    
    [_iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.and.height.mas_equalTo(imageViewWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    _rightButton = [JCHUIFactory createButton:CGRectZero
                                       target:self
                                       action:@selector(handleButtonAction)
                                        title:@""
                                   titleColor:JCHColorBlueButton backgroundColor:[UIColor whiteColor]];
    _rightButton.titleLabel.font = [UIFont jchSystemFontOfSize:14.0f];
    _rightButton.layer.cornerRadius = 4;
    _rightButton.clipsToBounds = YES;
    _rightButton.layer.borderColor = JCHColorBlueButton.CGColor;
    _rightButton.layer.borderWidth = 1;
    [_rightButton setTitleColor:JCHColorBlueButton forState:UIControlStateNormal];
    [_rightButton setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
    [_rightButton setTitle:@"已绑定" forState:UIControlStateDisabled];
    [_rightButton setTitle:@"绑定" forState:UIControlStateNormal];
    
    [self.contentView addSubview:_rightButton];
    
    [_rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonheight);
        make.centerY.equalTo(self.contentView);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont jchSystemFontOfSize:17.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_rightButton).with.offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
    }];
}

- (void)handleButtonAction
{
    if (self.bindingAction) {
        self.bindingAction();
    }
}

- (void)setCellData:(JCHTakeoutBindingTableViewCellData *)data
{
    _iconImageView.image = [UIImage imageNamed:data.imageName];
    _titleLabel.text = data.title;
    
    if (data.bindingStatus) {
        _rightButton.enabled = NO;
        _rightButton.layer.borderColor = JCHColorAuxiliary.CGColor;
    } else {
        _rightButton.enabled = YES;
        _rightButton.layer.borderColor = JCHColorBlueButton.CGColor;
    }
}

@end
