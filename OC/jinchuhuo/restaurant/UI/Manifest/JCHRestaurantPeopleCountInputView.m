//
//  JCHRestaurantPeopleCountInputView.m
//  jinchuhuo
//
//  Created by apple on 2017/2/7.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantPeopleCountInputView.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHTitleDetailLabel.h"
#import "CommonHeader.h"

@interface JCHRestaurantPeopleCountInputView()<JCHSettleAccountsKeyboardViewDelegate>
{
    UILabel *topTipsLabel;
    JCHTitleDetailLabel *countLabel;
    JCHSettleAccountsKeyboardView *keyboardView;
}

@property (retain, nonatomic, readwrite) NSString *inputText;

@end

@implementation JCHRestaurantPeopleCountInputView

- (id)initWithFrame:(CGRect)frame tableName:(NSString *)tableName
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI:tableName];
    }
    
    return self;
}

- (void)dealloc
{
    self.inputText = nil;
    [super dealloc];
}

- (void)createUI:(NSString *)tableName
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handleClickBackgroundView)] autorelease];
    [self addGestureRecognizer:tapGesture];
 
    UIFont *textFont = JCHFont(15.0);
    UIColor *textColor = JCHColorMainBody;
    topTipsLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:[NSString stringWithFormat:@"    当前桌台: %@, 请输入就餐人数", tableName]
                                        font:textFont
                                   textColor:textColor
                                      aligin:NSTextAlignmentLeft];
    [self addSubview:topTipsLabel];
    topTipsLabel.backgroundColor = [UIColor whiteColor];
    
    countLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"请输入就餐人数"
                                                        font:textFont
                                                   textColor:textColor
                                                      detail:@"0"
                                            bottomLineHidden:YES] autorelease];
    [self addSubview:countLabel];
    countLabel.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat keyboardViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:256.0f];
    keyboardView = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, keyboardViewHeight)
                                                          keyboardHeight:keyboardViewHeight
                                                                 topView:nil
                                                  topContainerViewHeight:0] autorelease];
    keyboardView.delegate = self;
    keyboardView.editMode = kJCHSettleAccountsKeyboardViewEditModeCount;
    [self addSubview:keyboardView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [topTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(42);
    }];
    
    
    CGFloat keyboardViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:256.0f];
    [keyboardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(keyboardViewHeight);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.bottom.equalTo(keyboardView.mas_top);
        make.height.mas_equalTo(42);
    }];
}

#pragma mark -
#pragma mark JCHSettleAccountsKeyboardViewDelegate
- (void)keyboardViewOKButtonClick
{
    [self handleClickBackgroundView];
}

- (void)keyboardViewDidHide:(JCHSettleAccountsKeyboardView *)keyboard
{
    [self handleClickBackgroundView];
}

- (NSString *)keyboardViewEditingChanged:(NSString *)editText
{
    if (editText.integerValue >= 100) {
        editText = @"100";
    }
    
    self.inputText = editText;
    countLabel.detailLabel.text = editText;
    
    return editText;
}

- (void)handleClickBackgroundView
{
    if ([self.delegate respondsToSelector:@selector(countInputViewDidHide:)]) {
        [self.delegate countInputViewDidHide:self];
    }
}

- (NSString *)getInputString
{
    return self.inputText;
}

@end
