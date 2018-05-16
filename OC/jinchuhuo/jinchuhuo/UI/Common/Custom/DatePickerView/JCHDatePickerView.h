//
//  JCHDatePickerView.h
//  jinchuhuo
//
//  Created by apple on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class JCHDatePickerView;
@protocol JCHDatePickerViewDelegate <NSObject>

@optional
- (void)handleDateChanged:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate;
- (void)handleDatePickerViewDidHide:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate;
- (void)handleDatePickerViewWillHide:(JCHDatePickerView *)datePicker;
@end

@interface JCHDatePickerView : UIView

@property (assign, nonatomic, readwrite) id<JCHDatePickerViewDelegate> delegate;
@property (assign, nonatomic) UIDatePickerMode datePickerMode;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)show;
- (void)hide;
- (BOOL)isShow;

@end
