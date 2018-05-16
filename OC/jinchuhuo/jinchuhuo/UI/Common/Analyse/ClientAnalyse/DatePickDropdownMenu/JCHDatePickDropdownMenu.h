//
//  JCHDatePickDropdownMenu.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHDatePickDropdownMenuDelegate <NSObject>

- (void)datePickDropdownMenuDidHideSelectRow:(NSInteger)row;

@optional
- (void)datePickDropdownMenuWillShow;
- (void)datePickDropdownMenuDidShow;
- (void)datePickDropdownMenuDidHide;

@end

@interface JCHDatePickDropdownMenu : UIView

@property (nonatomic, assign) id <JCHDatePickDropdownMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) NSInteger defaultRow;
@property (nonatomic, retain) UIColor *textColor;

- (instancetype)initWithFrame:(CGRect)frame controllerView:(UIView *)controllerView;
- (void)setTitle:(NSString *)title;
- (NSString *)startTime;
- (NSString *)endTime;
- (NSString *)dateRange;

@end
