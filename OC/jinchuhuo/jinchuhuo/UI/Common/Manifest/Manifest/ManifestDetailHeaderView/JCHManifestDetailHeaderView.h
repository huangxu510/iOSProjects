//
//  JCHManifestDetailHeaderView.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"

@interface JCHManifestDetailHeaderViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *manifestID;
@property (retain, nonatomic, readwrite) NSString *manifestDate;
@property (retain, nonatomic, readwrite) NSString *manifestBuyer;
@property (retain, nonatomic, readwrite) NSString *manifestSeller;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (retain, nonatomic, readwrite) NSString *manifestOperator;
@property (retain, nonatomic, readwrite) NSString *manifestWarehouseInfo;


//盘点单单品个数
@property (assign, nonatomic, readwrite) NSInteger productCount;

//盘赢单品个数
@property (assign, nonatomic, readwrite) NSInteger increaseSKUCount;

//盘赢数量
@property (assign, nonatomic, readwrite) CGFloat increaseCount;

//盘亏单品个数
@property (assign, nonatomic, readwrite) NSInteger decreaseSKUCount;

//盘亏数量
@property (assign, nonatomic, readwrite) CGFloat decreaseCount;

//移库单 总数量
@property (assign, nonatomic, readwrite) CGFloat totalCount;

@end

@interface JCHManifestDetailHeaderView : UIView

@property (nonatomic, assign) CGFloat viewHeight;

- (id)initWithType:(NSInteger)manifestType;
- (void)setViewData:(JCHManifestDetailHeaderViewData *)viewData;

@end
