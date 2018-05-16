//
//  JCHRestaurantManifestDetailFooterView.h
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"


@interface JCHRestaurantManifestDetailFooterViewData : NSObject

@property (assign, nonatomic, readwrite) CGFloat manifestAmount;
@property (assign, nonatomic, readwrite) CGFloat manifestDiscount;
@property (assign, nonatomic, readwrite) CGFloat manifestRealPay;
@property (assign, nonatomic, readwrite) CGFloat manifestEraseAmount;
@property (retain, nonatomic, readwrite) NSString *manifestRemark;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (retain, nonatomic, readwrite) NSString *payway;
@property (assign, nonatomic, readwrite) BOOL hasPayed;

@end

@interface JCHRestaurantManifestDetailFooterView : UIView

@property (nonatomic, assign) CGFloat viewHeight;

- (id)initWithType:(NSInteger)manifestType;
- (void)setViewData:(JCHRestaurantManifestDetailFooterViewData *)data;

@end
