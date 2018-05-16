//
//  JCHAddSpecificationTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddSKUValueTableViewCell.h"
#import "JCHInputAccessoryView.h"
#import "JCHUISizeSettings.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHAddSKUValueTableViewCell
{
    UIButton *_deleteButton;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.attributeNameTextField release];
    [self.deleteAction release];
    
    [super dealloc];
}

- (void)createUI
{
    _deleteButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(delete)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [_deleteButton setImage:[UIImage imageNamed:@"bt_setting_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    
    
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    
    self.attributeNameTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:@"如“XL”或“红色”"
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentLeft];

    self.attributeNameTextField.font = [UIFont systemFontOfSize:15.0f];
    self.attributeNameTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [self.contentView addSubview:self.attributeNameTextField];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat deleteButtonWidth = 23;
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(deleteButtonWidth);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    [self.attributeNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(_deleteButton).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)delete
{
    if (self.deleteAction) {
        self.deleteAction();
    }
}

@end




