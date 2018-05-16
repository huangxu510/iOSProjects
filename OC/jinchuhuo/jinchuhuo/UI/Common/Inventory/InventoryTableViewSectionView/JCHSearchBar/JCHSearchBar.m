//
//  JCHSearchBar.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSearchBar.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHInputAccessoryView.h"
#import <Masonry.h>

@interface JCHSearchBar () <UITextFieldDelegate>
{
    UIView *_borderView;
    UIImageView *_searchImageView;
    UIButton *_cancelButton;
    UIView *_bottomLine;
}
@end

@implementation JCHSearchBar

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
    [self.textField release];
    [super dealloc];
}

- (void)createUI
{
    UIFont *textFont = [UIFont jchSystemFontOfSize:14.0f];
    _borderView = [[[UIView alloc] init] autorelease];
    _borderView.backgroundColor = UIColorFromRGB(0xf3f3f3);;
    _borderView.layer.cornerRadius = 15;
    _borderView.clipsToBounds = YES;
    [self addSubview:_borderView];
    
    _searchImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inventory_multiselect_search_icon"]] autorelease];
    [self addSubview:_searchImageView];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    self.textField = [JCHUIFactory createTextField:CGRectZero
                                   placeHolder:@""
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.font = textFont;
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [self.textField addTarget:self
                   action:@selector(handleSearchTextChanged:)
         forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:self.textField];
    
    _cancelButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleCancelAction)
                                         title:@"取消"
                                    titleColor:[UIColor grayColor]
                               backgroundColor:nil];
    _cancelButton.titleLabel.font = textFont;
    _cancelButton.titleLabel.textColor = JCHColorAuxiliary;
    [self addSubview:_cancelButton];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self handleLayoutSubviews];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)handleLayoutSubviews
{
    [_borderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (YES == _cancelButton.hidden) {
            make.left.equalTo(self).with.offset(0.8 * kStandardWidthOffset);
            make.right.equalTo(self).with.offset(-0.8 * kStandardWidthOffset);
            make.top.equalTo(self).with.offset(0.7 * kStandardWidthOffset);
            make.centerY.equalTo(self);
        } else {
            make.left.equalTo(self).with.offset(0.8 * kStandardWidthOffset);
            make.right.equalTo(self).with.offset(-6 * kStandardWidthOffset);
            make.top.equalTo(self).with.offset(0.7 * kStandardWidthOffset);
            make.centerY.equalTo(self);
        }
    }];
    
    [_searchImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(1.6 * kStandardWidthOffset);
        make.width.mas_equalTo(1.5 * kStandardWidthOffset);
        make.height.mas_equalTo(1.5 * kStandardWidthOffset);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(3.9 * kStandardWidthOffset);
        make.right.equalTo(_borderView);
        make.top.equalTo(_borderView);
        make.bottom.equalTo(_borderView);
    }];
    
    [_cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_borderView.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(_borderView);
        make.bottom.equalTo(_borderView);
    }];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)handleCancelAction
{
    [self.textField endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

#pragma mark - UITextFieldDelegate
#if 1
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [self.delegate searchBarDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndEditing:)]) {
        [self.delegate searchBarDidEndEditing:self];
    }
}

#endif

- (void)handleSearchTextChanged:(UITextField *)textfield
{
    //NSString *searchText = textfield.text;
    //if ([searchText isEqualToString:@""] && [[UIDevice currentDevice].systemVersion floatValue] < 9.0) return;
    if ([self.delegate respondsToSelector:@selector(searchBarTextChanged:)]) {
        [self.delegate searchBarTextChanged:self];
    }
    [self.textField becomeFirstResponder];
}

- (void)setCancleButtonTitleColor:(UIColor *)cancleButtonTitleColor
{
    if (_cancleButtonTitleColor != cancleButtonTitleColor) {
        [_cancleButtonTitleColor release];
        _cancleButtonTitleColor = [cancleButtonTitleColor retain];
        
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)showCancelButton:(BOOL)showButton
{
    _cancelButton.hidden = !showButton;
    [self handleLayoutSubviews];
}


@end
