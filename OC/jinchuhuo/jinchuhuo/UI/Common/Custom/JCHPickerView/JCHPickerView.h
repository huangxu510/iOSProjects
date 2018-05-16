//
//  JCHPickerView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHPickerView;

@protocol JCHPickerViewDelegate <NSObject>
@optional
- (void)pickerViewWillShow:(JCHPickerView *)pickerView;
- (void)pickerViewDidShow:(JCHPickerView *)pickerView;
- (void)pickerViewWillHide:(JCHPickerView *)pickerView;
- (void)pickerViewDidHide:(JCHPickerView *)pickerView;

@end

enum
{
    kJCHPickerViewHeight = 280,
    kJCHPickerViewRowHeight = 45,
};

@interface JCHPickerView : UIView

@property (assign, nonatomic, readwrite) id<UIPickerViewDataSource> dataSource;
@property (assign, nonatomic, readwrite) id<UIPickerViewDelegate, JCHPickerViewDelegate> delegate;
@property (retain, nonatomic, readwrite) UIPickerView *pickerView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title showInView:(UIView *)superView;
- (void)show;
- (void)hide;
- (BOOL)isShow;
- (void)setTitle:(NSString *)title;

@end
