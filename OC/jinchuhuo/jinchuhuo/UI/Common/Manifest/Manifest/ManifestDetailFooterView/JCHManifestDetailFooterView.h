//
//  JCHManifestDetailFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"


@interface JCHManifestDetailFooterViewData : NSObject

@property (assign, nonatomic, readwrite) CGFloat manifestAmount;
@property (assign, nonatomic, readwrite) CGFloat manifestDiscount;
@property (assign, nonatomic, readwrite) CGFloat manifestRealPay;
@property (assign, nonatomic, readwrite) CGFloat manifestEraseAmount;
@property (assign, nonatomic, readwrite) CGFloat boxAmount;
@property (assign, nonatomic, readwrite) CGFloat deliveryAmount;
@property (retain, nonatomic, readwrite) NSString *manifestRemark;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (retain, nonatomic, readwrite) NSString *payway;
@property (assign, nonatomic, readwrite) BOOL hasPayed;

@end

@interface JCHManifestDetailFooterView : UIView

@property (nonatomic, assign) CGFloat viewHeight;

- (id)initWithType:(NSInteger)manifestType;
- (void)setViewData:(JCHManifestDetailFooterViewData *)data;

@end
