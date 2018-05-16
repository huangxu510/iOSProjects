//
//  JCHCreateManifestHeaderView.h
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHDatePickerView.h"

@interface JCHCreateManifestHeaderViewData : NSObject
@property (retain, nonatomic, readwrite) NSString *orderID;
@property (retain, nonatomic, readwrite) NSString *orderDate;
@end

@protocol JCHCreateManifestHeaderViewDelegate <NSObject>

@optional

- (void)handleChooseDate;

@end

@interface JCHCreateManifestHeaderView : UIView<UIPickerViewDelegate>

@property (assign, nonatomic, readwrite) id<JCHCreateManifestHeaderViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
   isCommonManifest:(BOOL)isCommonManifest;

- (void)setData:(JCHCreateManifestHeaderViewData *)data;
- (void)setOrderDate:(NSString *)orderDate;
- (NSString *)getOrderDate;


@end
