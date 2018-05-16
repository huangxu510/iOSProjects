//
//  JCHAddProcductMainViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHManifestType.h"

@interface ManifestTransactionDetail : NSObject

@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productImageName;
@property (retain, nonatomic, readwrite) NSString *productUnit;
@property (retain, nonatomic, readwrite) NSString *productCount;                    //存储用户输入的数量，小数点后只有两位, 用来显示
@property (assign, nonatomic, readwrite) CGFloat   productCountFloat;               //存储用户输入金额后换算的数量, 用来传值
@property (retain, nonatomic, readwrite) NSString *productTotalAmount;              //存储用户输入的金额，仅用来显示
@property (retain, nonatomic, readwrite) NSString *productInventoryCount;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *productDiscount;
@property (assign, nonatomic, readwrite) NSInteger productAddedTimestamp;
@property (assign, nonatomic, readwrite) NSInteger productUnit_digits;

@property (retain, nonatomic, readwrite) NSString *warehouseUUID;                   // warehouse uuid
@property (retain, nonatomic, readwrite) NSString *transactionUUID;                 // transaction uuid
@property (retain, nonatomic, readwrite) NSString *unitUUID;                        // unit uuid
@property (retain, nonatomic, readwrite) NSString *goodsNameUUID;                   // goods name uuid
@property (retain, nonatomic, readwrite) NSString *goodsCategoryUUID;               // goods category uuid
@property (retain, nonatomic, readwrite) NSArray *skuValueUUIDs;
@property (retain, nonatomic, readwrite) NSString *skuValueCombine;
@property (assign, nonatomic, readwrite) BOOL skuHidenFlag;



//! @brief 盘前平均成本价
@property (retain, nonatomic, readwrite) NSString *averagePriceBefore;

//! @brief 主副单位换算率
@property (assign, nonatomic, readwrite) CGFloat ratio;
@property (assign, nonatomic, readwrite) BOOL isMainUnit;


@property (retain, nonatomic, readwrite) NSString *dishProperty;
@end


@interface JCHAddProductMainViewController : JCHBaseViewController

- (void)updateFooterViewData:(BOOL)animation;

@end
