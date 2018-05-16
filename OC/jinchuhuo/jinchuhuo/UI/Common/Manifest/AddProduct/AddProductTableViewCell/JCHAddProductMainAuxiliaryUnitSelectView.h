//
//  JCHAddProductMainAuxiliaryUnitSelectView.h
//  jinchuhuo
//
//  Created by huangxu on 16/9/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAddProductMainAuxiliaryUnitSelectViewData : NSObject
@property (assign, nonatomic, readwrite) BOOL isMainUint;
@property (retain, nonatomic, readwrite) NSString *productMainUnit;
@property (retain, nonatomic, readwrite) NSString *productAuxiliaryUnit;
@property (assign, nonatomic, readwrite) CGFloat scale;
@property (retain, nonatomic, readwrite) NSString *productInventoryCount;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *productCount;

//是否盘点过
@property (assign, nonatomic, readwrite) BOOL afterManifestInventoryChecked;


//如果是主单位就表示主单位的uuid，辅单位就表示辅单位的uuid
@property (retain, nonatomic, readwrite) NSString *unitUUID;
@end

@interface JCHAddProductMainAuxiliaryUnitSelectView : UIControl

@property (nonatomic, copy) void(^addProductBlock)(void);
@property (nonatomic, copy) void(^increaseProductCountBlock)(NSString *);
@property (nonatomic, copy) void(^decreaseProductCountBlock)(NSString *);

- (void)setViewData:(JCHAddProductMainAuxiliaryUnitSelectViewData *)data;

@end
