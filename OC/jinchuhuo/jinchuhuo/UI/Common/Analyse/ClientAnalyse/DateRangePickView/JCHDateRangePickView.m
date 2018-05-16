//
//  JCHDateRangePickView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDateRangePickView.h"
#import "CommonHeader.h"

@implementation DateRangeTitleButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = contentRect.size.height - 7;
    CGFloat height = 7;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return contentRect;
}

@end

@interface JCHDateRangePickView ()

@property (nonatomic, retain) UIView *maskView;
@property (nonatomic, retain) UIButton *currentSelectButton;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *beginTimeTitle;
@property (nonatomic, retain) NSString *endTimeTitle;

@end

@implementation JCHDateRangePickView
{
    UIDatePicker *_datePicker;
    DateRangeTitleButton *_startTimeButton;
    DateRangeTitleButton *_endTimeButton;
    UIView *_maskView;
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
               beginTimeTitle:(NSString *)beginTimeTitle
                 endTimeTitle:(NSString *)endTimeTitle
{
    self.title = title;
    self.beginTimeTitle = beginTimeTitle;
    self.endTimeTitle = endTimeTitle;
    
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kDateRangePickViewHeight);
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.currentSelectButton = nil;
    self.defaultStartTime = nil;
    self.defaultEndTime = nil;
    self.maskView = nil;
    self.title = nil;
    self.beginTimeTitle = nil;
    self.endTimeTitle = nil;
    
    [super dealloc];
}

- (UIWindow *)keyWindow
{
    return [UIApplication sharedApplication].windows[0];
}

- (void)createUI
{
    CGFloat titleLabelHeight = 50.0f;
    CGFloat startTimeTitleLabelHeight = 30.0f;
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"设置统计周期"
                                               font:JCHFont(16)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    titleLabel.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    
    
    UIButton *closeButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(hideView)
                                                  title:nil
                                             titleColor:nil
                                        backgroundColor:nil];
    [closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
    [self addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:52.0f]);
    }];
    
    UIButton *commitButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(commit)
                                                  title:@"完成"
                                             titleColor:JCHColorMainBody
                                        backgroundColor:nil];
    [self addSubview:commitButton];
    
    [commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
        make.width.mas_equalTo(60);
    }];
    
    UILabel *startTimeTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"起始日期"
                                                        font:JCHFont(14)
                                                   textColor:JCHColorAuxiliary
                                                      aligin:NSTextAlignmentCenter];
    startTimeTitleLabel.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:startTimeTitleLabel];
    
    [startTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(startTimeTitleLabelHeight);
    }];
    
    UILabel *endTimeTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"截至日期"
                                                      font:JCHFont(14)
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    endTimeTitleLabel.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:endTimeTitleLabel];
    
    [endTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self.mas_centerX);
        make.top.height.equalTo(startTimeTitleLabel);
    }];

    _startTimeButton = [[[DateRangeTitleButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 2, kStandardItemHeight)] autorelease];
    [_startTimeButton setTitle:@"2016-07-15" forState:UIControlStateNormal];
    _startTimeButton.titleLabel.font = JCHFont(14.0);
    [_startTimeButton addTarget:self action:@selector(selectTimeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_startTimeButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    [_startTimeButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    [_startTimeButton setImage:[UIImage imageNamed:@"addgoods_keyboard_focus"] forState:UIControlStateSelected];
    [self addSubview:_startTimeButton];
    
    [_startTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(startTimeTitleLabel);
        make.top.equalTo(startTimeTitleLabel.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _endTimeButton = [[[DateRangeTitleButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 2, kStandardItemHeight)] autorelease];
    _endTimeButton.titleLabel.font = JCHFont(14.0);
    [_endTimeButton addTarget:self action:@selector(selectTimeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_endTimeButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    [_endTimeButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    [_endTimeButton setImage:[UIImage imageNamed:@"addgoods_keyboard_focus"] forState:UIControlStateSelected];
    [self addSubview:_endTimeButton];
    
    [_endTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(endTimeTitleLabel);
        make.top.height.equalTo(_startTimeButton);
    }];
    
    _datePicker = [[[UIDatePicker alloc] init] autorelease];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self
                    action:@selector(dateChanged:)
          forControlEvents:UIControlEventValueChanged];
    [self addSubview:_datePicker];
    
    [_datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(_startTimeButton.mas_bottom);
    }];
    
    [_datePicker addSeparateLineWithMasonryTop:YES bottom:NO];
    
    UIView *separateLine = [[[UIView alloc] init] autorelease];
    separateLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:separateLine];
    
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(startTimeTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    separateLine = [[[UIView alloc] init] autorelease];
    separateLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:separateLine];
    
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(startTimeTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    if (self.title) {
        titleLabel.text = self.title;
    }
    
    if (self.beginTimeTitle) {
        startTimeTitleLabel.text = self.beginTimeTitle;
    }
    
    if (self.endTimeTitle) {
        endTimeTitleLabel.text = self.endTimeTitle;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
}

- (void)selectTimeButtonClick:(UIButton *)sender
{
    self.currentSelectButton.selected = NO;
    self.currentSelectButton = sender;
    self.currentSelectButton.selected = YES;
    
    NSString *currentTime = self.currentSelectButton.currentTitle;
    NSDateFormatter *dateFormatter = [self getDateFormat];
    NSDate *date = [dateFormatter dateFromString:currentTime];
    [_datePicker setDate:date animated:YES];
}

- (NSDateFormatter *)getDateFormat
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    if (self.datePickerMode == UIDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (self.datePickerMode == UIDatePickerModeTime) {
        [dateFormatter setDateFormat:@"hh:mm"];
    }
    return dateFormatter;
}

- (void)dateChanged:(UIDatePicker *)sender
{
    NSDateFormatter *dateFormatter = [self getDateFormat];
    NSString *dateStr = [dateFormatter stringFromDate:sender.date];
    
    [self.currentSelectButton setTitle:dateStr forState:UIControlStateNormal];
}

- (void)showView
{
    [[self keyWindow] addSubview:self];
    self.maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)] autorelease];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    [[self keyWindow] addSubview:self.maskView];
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)] autorelease];
    [self.maskView addGestureRecognizer:tap];
    
    if (self.defaultStartTime) {
        NSDateFormatter *dateFormatter = [self getDateFormat];
        NSDate *date = [dateFormatter dateFromString:self.defaultStartTime];
        [_datePicker setDate:date];
    }
    
    
    self.currentSelectButton = _startTimeButton;
    self.currentSelectButton.selected = YES;
    
    [self.superview bringSubviewToFront:self];
    CGRect frame = self.frame;
    frame.origin.y -= frame.size.height;
    
    CGRect maskFrame = self.maskView.frame;
    maskFrame.size.height = kScreenHeight;
    self.maskView.frame = maskFrame;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.maskView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideView
{
    CGRect frame = self.frame;
    frame.origin.y += frame.size.height;
    
    CGRect maskFrame = self.maskView.frame;
    maskFrame.size.height = 0;
    self.maskView.frame = maskFrame;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.maskView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(dateRangePickViewDidHide)]) {
            [self.delegate dateRangePickViewDidHide];
        }
    }];
}

- (void)commit
{
    if ([_startTimeButton.currentTitle isEmptyString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"请选择起始日期"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (!_endTimeButton.currentTitle || [_endTimeButton.currentTitle isEmptyString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"请选择截止日期"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if ([_startTimeButton.currentTitle compare:_endTimeButton.currentTitle] == NSOrderedDescending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"截止时间应大于起始时间"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self hideView];
    if ([self.delegate respondsToSelector:@selector(dateRangePickViewSelectDateRange:withStartTime:endTime:)]) {
        [self.delegate dateRangePickViewSelectDateRange:self withStartTime:_startTimeButton.currentTitle endTime:_endTimeButton.currentTitle];
    }
}


- (void)setDefaultStartTime:(NSString *)defaultStartTime
{
    if (_defaultStartTime != defaultStartTime) {
        [_defaultStartTime release];
        _defaultStartTime = [defaultStartTime retain];
        [_startTimeButton setTitle:defaultStartTime forState:UIControlStateNormal];
    }
}

- (void)setDefaultEndTime:(NSString *)defaultEndTime
{
    if (_defaultEndTime != defaultEndTime) {
        [_defaultEndTime release];
        _defaultEndTime = [defaultEndTime retain];
        [_endTimeButton setTitle:defaultEndTime forState:UIControlStateNormal];
    }
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    _datePickerMode = datePickerMode;
    _datePicker.datePickerMode = datePickerMode;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [self getDateFormat];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    if (!self.defaultStartTime) {
        [_startTimeButton setTitle:dateStr forState:UIControlStateNormal];
    }
    
    if (!self.defaultEndTime) {
        [_endTimeButton setTitle:dateStr forState:UIControlStateNormal];
    }
}


@end
