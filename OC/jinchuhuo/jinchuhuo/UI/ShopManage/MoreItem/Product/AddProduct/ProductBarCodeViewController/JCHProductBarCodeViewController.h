//
//  JCHProductBarCodeViewController.h
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHAddMainAuxiliaryUnitViewController.h"


enum ProductBarCodeType
{
    kProductBarCodeRecordForWithSKU,            /*! 多规格 */
    kProductBarCodeRecordForWithoutSKU,         /*! 无规格 */
    kProductBarCodeRecordForMainUnit            /*! 主辅助单位 */
};

@interface ProductBarCodeRecord : NSObject
@property (retain, nonatomic, readwrite) id recordUUID;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productBarCode;
@property (retain, nonatomic, readwrite) NSString *productBarCodeCopy;
@end



@interface JCHProductBarCodeViewController : JCHBaseViewController

- (id)initWithType:(enum ProductBarCodeType)enumBarCodeType
       productList:(NSArray<ProductBarCodeRecord *> *)productList
          mainUnit:(UnitRecord4Cocoa *)mainUnit
          unitList:(NSArray<ProductUnitRecord *> *)unitList;

@end
