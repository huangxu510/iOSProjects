//
//  JCHFeedbackViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHFeedbackViewController.h"
#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "MXPullDownMenu.h"
#import "JCHNetWorkingUtility.h"
#import "Masonry.h"
#import "JCHSyncStatusManager.h"
#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"

@interface JCHFeedbackViewController () <MXPullDownMenuDelegate, UIAlertViewDelegate>
{
    UIView *contentView;
    
    UILabel *issueTitleLabel;
//    UITextField *issueTextField;
    MXPullDownMenu *issueMenu;
    
    UILabel *contactTitleLabel;
    UITextField *contactTextField;
    
    UILabel *contentTitleLabel;
    UITextView *contentTextView;
    
    UIButton *sendFeedbackButton;
    NSInteger feedbackType;
}

@property (nonatomic, retain, readwrite) NSArray *editViews;

@end

@implementation JCHFeedbackViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"反映问题";
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self adjustTextView];
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    feedbackType = 1;
    
    UIFont *titleLabelFont = [UIFont jchSystemFontOfSize:16.0f];
    UIColor *titleLabelColor = JCHColorAuxiliary;
    
    // UIFont *textFieldFont = titleLabelFont;
//    UIColor *textFieldColor = JCHColorMainBody;
    
    UIColor *textFieldBorderColor = [UIColor clearColor];
    const CGFloat textFieldBorderWidth = kSeparateLineWidth;
    
    const CGFloat verticalOffset = 26;
    const CGFloat titleLabelWidth = 93;
    const CGFloat titleLabelHeight = 40;
    const CGFloat textFieldCornerRadius = 5.0f;
    
    CGFloat curretnkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:17.0f];
    CGFloat currentVerticalOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:verticalOffset];
    CGFloat currentTitleLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:titleLabelWidth];
    CGFloat currentTitleLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:titleLabelHeight];
    const CGFloat contentViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:21.0f];
    const CGFloat contentViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:279.0f];
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    
    {
        contentView = [[[UIView alloc] init] autorelease];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:contentView];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(contentViewTopOffset);
            make.height.mas_equalTo(contentViewHeight);
            make.left.mas_equalTo(self.view.mas_left);
            make.right.mas_equalTo(self.view.mas_right);
        }];
    }
    
    // 问题类型
    {
        issueTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"问题类型"
                                               font:titleLabelFont
                                          textColor:titleLabelColor
                                             aligin:NSTextAlignmentLeft];
        [self.view addSubview:issueTitleLabel];
        
        [issueTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(curretnkStandardLeftMargin);
            make.top.equalTo(contentView).with.offset(currentVerticalOffset / 2);
            make.width.mas_equalTo(currentTitleLabelWidth);
            make.height.mas_equalTo(currentTitleLabelHeight);
        }];
        
        
        NSArray *issueList = @[@[@"问题报修", @"界面缺陷", @"操作不爽", @"其他问题"]];
        issueMenu = [[[MXPullDownMenu alloc] initWithArray:issueList selectedColor:[UIColor greenColor] titleLabelHeight:currentTitleLabelHeight] autorelease];
        issueMenu.delegate = self;

        [self.view addSubview:issueMenu];
        
        CGFloat issueMenuLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
        CGFloat issueMenuTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:1.0f];
        [issueMenu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(issueTitleLabel.mas_right).with.offset(-issueMenuLeftOffset);
            make.right.equalTo(self.view.mas_right).with.offset(-curretnkStandardLeftMargin);
            make.height.mas_equalTo(currentTitleLabelHeight);
            make.top.equalTo(issueTitleLabel.mas_top).with.offset(-issueMenuTopOffset);
        }];
    }
    
    // 联系方式
    {
        contactTitleLabel = [JCHUIFactory createLabel:CGRectZero title:@"联系方式"
                                                 font:titleLabelFont
                                            textColor:titleLabelColor
                                               aligin:NSTextAlignmentLeft];
        [self.view addSubview:contactTitleLabel];
        
        [contactTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(curretnkStandardLeftMargin);
            make.top.equalTo(issueTitleLabel.mas_bottom).with.offset(currentVerticalOffset);
            make.width.mas_equalTo(currentTitleLabelWidth);
            make.height.mas_equalTo(currentTitleLabelHeight);
        }];
        
        
        contactTextField = [JCHUIFactory createTextField:CGRectZero placeHolder:@"请输入内容"
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentLeft];
        contactTextField.layer.cornerRadius = textFieldCornerRadius;
        contactTextField.layer.borderColor = textFieldBorderColor.CGColor;
        contactTextField.layer.borderWidth = textFieldBorderWidth;
        contactTextField.clearsOnBeginEditing = YES;
        contactTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        contactTextField.font = titleLabelFont;
        contactTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
        [self.view addSubview:contactTextField];
        
        [contactTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contactTitleLabel.mas_right);
            make.right.equalTo(self.view.mas_right).with.offset(-curretnkStandardLeftMargin);
            make.height.mas_equalTo(currentTitleLabelHeight);
            make.top.equalTo(contactTitleLabel.mas_top);
        }];
    }
    
    // 备注
    {
        contentTitleLabel = [JCHUIFactory createLabel:CGRectZero title:@"反馈内容"
                                                font:titleLabelFont
                                           textColor:titleLabelColor
                                              aligin:NSTextAlignmentLeft];
        [self.view addSubview:contentTitleLabel];
        
        [contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(curretnkStandardLeftMargin);
            make.top.equalTo(contactTitleLabel.mas_bottom).with.offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:24.0f]);
            make.width.mas_equalTo(currentTitleLabelWidth);
            make.height.mas_equalTo(currentTitleLabelHeight);
        }];
        
        
        contentTextView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
        [self.view addSubview:contentTextView];
        
        contentTextView.layer.cornerRadius = textFieldCornerRadius;
        contentTextView.layer.borderColor = JCHColorSeparateLine.CGColor;
        contentTextView.layer.borderWidth = textFieldBorderWidth;
        contentTextView.font = titleLabelFont;
        contentTextView.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
        
        [contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentTitleLabel.mas_left);
            make.right.equalTo(self.view.mas_right).with.offset(-curretnkStandardLeftMargin);
            make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:70.0f]);
            make.top.equalTo(contentTitleLabel.mas_bottom);
        }];
    }
    
    // 发送
    {
        sendFeedbackButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleSendContent:)
                                                  title:@"提交"
                                             titleColor:[UIColor whiteColor]
                                        backgroundColor:JCHColorPriceText];
        [self.view addSubview:sendFeedbackButton];
        
        [sendFeedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.equalTo(contentTextView.mas_width);
            make.height.mas_equalTo(currentTitleLabelHeight * 1.3);
            make.top.equalTo(contentView.mas_bottom).with.offset(currentVerticalOffset);
        }];
    }
    
    // 分隔线
    {
        const CGFloat seperatorLineWidth = self.view.frame.size.width - curretnkStandardLeftMargin;
        UIView *seperatorLine = [JCHUIFactory createSeperatorLine:seperatorLineWidth];
        [self.view addSubview:seperatorLine];
        
        [seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(curretnkStandardLeftMargin);
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(issueMenu.mas_bottom).with.offset(currentVerticalOffset / 2);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        seperatorLine = [JCHUIFactory createSeperatorLine:seperatorLineWidth];
        [self.view addSubview:seperatorLine];
        
        [seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(curretnkStandardLeftMargin);
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(contactTextField.mas_bottom).with.offset(currentVerticalOffset / 2);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    // 添加mock数据
//    issueTextField.text = @"操作不流畅";
    contactTextField.text = @"例如手机或固话";
    
    //保存可编辑控件
    self.editViews = @[contactTextField, contentTextView];
    
    return;
}

- (void)handleSendContent:(id)sender
{
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = NO;
    hud.minSize = CGSizeMake(100, 100);
    [hud show:YES];
    

    NSPredicate *telePre = [NSPredicate predicateWithFormat:@"self matches %@", kTelephoneNumberPredicate];
    NSPredicate *phonePre = [NSPredicate predicateWithFormat:@"self matches %@", kPhoneNumberPredicate];
    NSPredicate *emailPre = [NSPredicate predicateWithFormat:@"self matches %@", kEmailPredicate];
    
    BOOL isTelephone = [telePre evaluateWithObject:contactTextField.text];
    BOOL isPhone = [phonePre evaluateWithObject:contactTextField.text];
    BOOL isEmail = [emailPre evaluateWithObject:contactTextField.text];
    
    if ((contentTextView.text.length) < 10 || (contentTextView.text.length > 200))
    {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"输入字数有误" message:@"反馈内容字数应在10到200之间!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [av show];
    }
    else if(!isTelephone && !isPhone && !isEmail)
    {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"联系方式输入有误" message:@"联系方式应为手机、固话或邮箱!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [av show];
    }
    else
    {
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        [JCHNetWorkingUtility submitFeedback:statusManager.userID
                                 contactInfo:contactTextField.text
                                 questionType:feedbackType
                                feedbackInfo:contentTextView.text
                                      result:^(id obj) {
              if (obj == nil) {
                  [hud hide:YES];
                  [MBProgressHUD showHUDWithTitle:@"反馈失败" detail:@"网络繁忙，请稍后再试!" duration:1 mode:MBProgressHUDModeText completion:nil];
              }
              else if ([obj[@"msg"] isEqualToString:@"反馈成功"])
              {
                  [hud hide:YES];
                  [MBProgressHUD showHUDWithTitle:@"反馈成功" detail:nil duration:1 mode:MBProgressHUDModeCustomView completion:^{
                      [self.navigationController popViewControllerAnimated:YES];
                  }];
              }
        }];

//        [self.navigationController popViewControllerAnimated:YES];
    }
    return;
}


//用通知中心调整textView
- (void)adjustTextView
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *rectObj = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [rectObj CGRectValue];
    
    //判断每个输入框是否被键盘遮挡
    for(UIView *editView in self.editViews)
    {
        if([editView isFirstResponder])
        {
            if ([JCHSizeUtility viewIsCoveredByKeyboard:editView.frame KeyboardHeight:keyboardFrame.size.height])
            {
                CGRect viewFrame = self.view.frame;
                viewFrame.origin.y = -(keyboardFrame.size.height - (self.view.frame.size.height + 64 - CGRectGetMaxY(editView.frame)));
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.frame = viewFrame;
                }];
            }
        }
        
    }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 64;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = viewFrame;
    }];
}

- (void)PullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row
{
    NSLog(@"colume = %ld row = %ld", (long)column, (long)row);
    feedbackType = row;
}

@end
