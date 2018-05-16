//
//  JCHProductSalePriceViewController.h
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHAddMainAuxiliaryUnitViewController.h"


enum ProductSalePriceType
{
    kProductSalePriceForWithSKU,            /*! 多规格 */
    kProductSalePriceForWithoutSKU,         /*! 无规格 */
    kProductSalePriceForMainUnit            /*! 主辅助单位 */
};

@interface ProductSalePriceRecord : NSObject
@property (retain, nonatomic, readwrite) id recordUUID;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *productPriceCopy;
@end



@interface JCHProductSalePriceViewController : JCHBaseViewController

- (id)initWithType:(enum ProductSalePriceType)enumPriceType
       productList:(NSArray<ProductSalePriceRecord *> *)productList
          mainUnit:(UnitRecord4Cocoa *)mainUnit
          unitList:(NSArray<ProductUnitRecord *> *)unitList;

@end
