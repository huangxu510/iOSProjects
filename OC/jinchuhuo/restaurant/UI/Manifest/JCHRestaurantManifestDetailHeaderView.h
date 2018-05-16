//
//  JCHRestaurantManifestDetailHeaderView.h
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"

@interface JCHRestaurantManifestDetailHeaderViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *deskNumber;
@property (assign, nonatomic, readwrite) NSInteger personCount;
@property (assign, nonatomic, readwrite) NSInteger dishesCount;
@property (retain, nonatomic, readwrite) NSString *manifestDate;
@property (retain, nonatomic, readwrite) NSString *usedTime;
@property (retain, nonatomic, readwrite) NSString *manifestOperator;
@property (retain, nonatomic, readwrite) NSString *remark;
@property (assign, nonatomic, readwrite) BOOL hasFinished;

@end

@interface JCHRestaurantManifestDetailHeaderView : UIView

@property (nonatomic, assign) CGFloat viewHeight;

- (id)initWithType:(NSInteger)manifestType;
- (void)setViewData:(JCHRestaurantManifestDetailHeaderViewData *)viewData;

@end
