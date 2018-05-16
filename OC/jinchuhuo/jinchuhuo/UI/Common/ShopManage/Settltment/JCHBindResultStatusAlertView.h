//
//  JCHBindResultStatusAlertView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHBindResultStatusAlertViewData : NSObject

@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *detailText;
@property (nonatomic, retain) NSString *buttonTitle;

@end

@class JCHBindResultStatusAlertView;
@protocol JCHBindResultStatusAlertViewDelegate <NSObject>

- (void)handleButtonClick:(JCHBindResultStatusAlertView *)alertView;

@end

@interface JCHBindResultStatusAlertView : UIView

@property (nonatomic, assign) NSInteger resultStatus;
@property (nonatomic, assign) id <JCHBindResultStatusAlertViewDelegate> delegate;

- (void)setViewData:(JCHBindResultStatusAlertViewData *)data;

@end
