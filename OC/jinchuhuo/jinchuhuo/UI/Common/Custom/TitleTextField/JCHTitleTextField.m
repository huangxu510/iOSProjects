//
//  JCHTitleTextField.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTitleTextField.h"
#import "CommonHeader.h"
#import <Masonry.h>


@implementation JCHTitleTextField
{
    BOOL _isLengthLimitTextField;
}

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                  placeholder:(NSString *)placeholder
                    textColor:(UIColor *)textColor
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:title
                                               font:font
                                          textColor:textColor
                                             aligin:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        
        CGSize fitSize = [self.titleLabel sizeThatFits:CGSizeZero];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.width.mas_equalTo(fitSize.width + 10);
        }];
        
        if (_isLengthLimitTextField) {
            self.textField = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                          placeHolder:@""
                                                            textColor:textColor
                                                               aligin:NSTextAlignmentRight];
        } else {
            self.textField = [JCHUIFactory createTextField:CGRectZero
                                               placeHolder:@""
                                                 textColor:textColor
                                                    aligin:NSTextAlignmentRight];
        }
        
        self.textField.font = font;
        NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : font}] autorelease];
        self.textField.attributedPlaceholder = placeHolder;
        [self addSubview:self.textField];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.left.equalTo(self.titleLabel.mas_right).with.offset(kStandardLeftMargin);
        }];
        
        self.bottomLine = [[[UIView alloc] init] autorelease];
        self.bottomLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:self.bottomLine];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title font:(UIFont *)font placeholder:(NSString *)placeholder textColor:(UIColor *)textColor isLengthLimitTextField:(BOOL)isLengthLimitTextField
{
    _isLengthLimitTextField = isLengthLimitTextField;
   return [self initWithTitle:title font:font placeholder:placeholder textColor:textColor];
}

- (void)dealloc
{
    [self.titleLabel release];
    [self.textField release];
    [self.bottomLine release];
    [self.rightViewText release];
    
    [super dealloc];
}

- (void)setRightViewText:(NSString *)rightViewText
{
    if (_rightViewText != rightViewText) {
        [_rightViewText release];
        _rightViewText = [rightViewText retain];
        
        UILabel *rightView = [JCHUIFactory createLabel:CGRectZero title:rightViewText font:JCHFontStandard textColor:JCHColorMainBody aligin:NSTextAlignmentCenter];
        CGSize fitSize = [rightView sizeThatFits:CGSizeZero];
        rightView.frame = CGRectMake(0, 0, fitSize.width + 5, kStandardItemHeight);
        
        self.textField.rightView = rightView;
        self.textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

@end
