//
//  JCHDateRangePickView.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kDateRangePickViewHeight = 340,
};

@class JCHDateRangePickView;

@protocol JCHDateRangePickViewDelegate <NSObject>

- (void)dateRangePickViewSelectDateRange:(JCHDateRangePickView *)dateRangePickView
                           withStartTime:(NSString *)startTime
                                 endTime:(NSString *)endTime;
@optional
- (void)dateRangePickViewDidHide;

@end

@interface DateRangeTitleButton : UIButton

@end

@interface JCHDateRangePickView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
               beginTimeTitle:(NSString *)beginTimeTitle
                 endTimeTitle:(NSString *)endTimeTitle;

@property (nonatomic, assign) id <JCHDateRangePickViewDelegate> delegate;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

@property (nonatomic, retain) NSString *defaultStartTime;
@property (nonatomic, retain) NSString *defaultEndTime;

- (void)showView;

@end
