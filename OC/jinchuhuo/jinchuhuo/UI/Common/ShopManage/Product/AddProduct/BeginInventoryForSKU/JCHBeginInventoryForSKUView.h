//
//  JCHBeginInventoryForSKUView.h
//  jinchuhuo
//
//  Created by huangxu on 16/6/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHBeginInventoryForSKUViewData : NSObject

@property (nonatomic, retain) NSString *skuCombine;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) CGFloat count;
@property (nonatomic, assign) NSInteger unitDigital;
@property (nonatomic, retain) NSString *unit;
@property (nonatomic, retain) NSArray *skuUUIDVector;
@property (nonatomic, retain) NSString *goodsSKUUUID;
@property (nonatomic, retain) NSString *unitUUID;
@property (nonatomic, retain) NSString *warehouseUUID;
@property (nonatomic, retain) NSString *warehouseName;
@property (nonatomic, assign) CGFloat copyPrice;
@property (nonatomic, assign) CGFloat copyCount;
@end

@interface JCHBeginInventoryForSKUView : UIView

@property (nonatomic, retain) JCHBeginInventoryForSKUViewData *data;
@property (nonatomic, copy) void(^viewTapBlock)(BOOL expand);
@property (nonatomic, assign, getter=isExpand) BOOL expand;

- (void)setViewData:(JCHBeginInventoryForSKUViewData *)data;
- (void)setBottomLineHidden:(BOOL)hidden;

@end
