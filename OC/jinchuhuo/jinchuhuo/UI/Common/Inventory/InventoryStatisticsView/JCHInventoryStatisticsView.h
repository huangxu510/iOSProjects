//
//  JCHInventoryStatisticsView.h
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHInventoryStatisticsViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *inventoryCount;
@property (retain, nonatomic, readwrite) NSString *shipmentCount;
@property (retain, nonatomic, readwrite) NSString *purchasesCount;

@end

@interface JCHInventoryStatisticsView : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)setViewData:(JCHInventoryStatisticsViewData *)viewData;

@end
