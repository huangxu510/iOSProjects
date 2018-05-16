//
//  JCHAddProductComponentViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//



#import "JCHBaseViewController.h"
#import "ProductRecord4Cocoa.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHAddProductSKUListView.h"
#import "JCHAddProductMainAuxiliaryUnitSelectView.h"
#import "JCHAddProductTableViewCell.h"

typedef NS_ENUM(NSInteger, JCHAddProductChildViewControllerType) {
    kJCHAddProductChildViewControllerTypeDefault = 0,
    kJCHAddProductChildViewControllerTypeLeftMenu,
};


@interface JCHAddProductChildViewController : JCHBaseViewController

@property (nonatomic, retain) NSArray *categoryList;
@property (nonatomic, retain) NSString *selectCategory;
@property (nonatomic, retain) NSDictionary *productCategoryToProductListMap;
@property (nonatomic, retain) NSDictionary *inventoryMap;
@property (nonatomic, retain) NSArray *allGoodsSKURecordArray;


- (instancetype)initWithType:(JCHAddProductChildViewControllerType)type;
- (void)reloadData:(BOOL)layoutIfNeeded;
- (void)expandProduct:(ProductRecord4Cocoa *)productRecord unitUUID:(NSString *)unitUUID;

//该方法作为类方法以便 createManifestViewController 和 扫码开单页面调用
+ (NSString *)keyboardViewEditingChanged:(NSString *)editText
                       skuListView:(JCHAddProductSKUListView *)skuListView
                      keyboardView:(JCHSettleAccountsKeyboardView *)keyboardView;
+ (void)keyboardViewOKButtonClick:(JCHAddProductSKUListView *)skuListView;



//设置ProductItemRecord的Price  cellForRow里面用
- (void)setProductItemRecordPrice:(ProductRecord4Cocoa *)productRecord
                         viewData:(JCHAddProductMainAuxiliaryUnitSelectViewData *)viewData;

//设置cellData里面的price count
- (void)setCellDataPriceAndInventoryCount:(JCHAddProductTableViewCellData *)cellData
                            productRecord:(ProductRecord4Cocoa *)productRecord;

//得到主辅单位的viewData
- (NSArray *)getMainAuxiliaryViewData:(ProductRecord4Cocoa *)productRecord unitList:(NSArray *)unitList;

+ (ManifestTransactionDetail *)createManifestTransactionDetail:(ProductRecord4Cocoa *)productRecord;

@end
