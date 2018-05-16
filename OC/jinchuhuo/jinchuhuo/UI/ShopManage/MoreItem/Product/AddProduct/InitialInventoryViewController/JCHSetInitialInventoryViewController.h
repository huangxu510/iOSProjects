//
//  JCHSetInitialInventoryViewController.h
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHBeginInventoryForSKUView.h"
#import "JCHAddMainAuxiliaryUnitViewController.h"


enum SetInitialInventoryType
{
    kInitialInventoryForWithSKU,            /*! 多规格 */
    kInitialInventoryForWithoutSKU,         /*! 无规格 */
    kInitialInventoryForMainUnit            /*! 主辅助单位 */
};

enum SetInitialInventoryOperation
{
    kInitialInventoryCreate = 0,            /*! 创建期初库存 */
    kInitialInventoryModify = 1,            /*! 修改期初库存 */
};


@interface JCHSetInitialInventoryViewController : JCHBaseViewController

- (id)initWithType:(enum SetInitialInventoryType)enumInventoryType
          mainUnit:(UnitRecord4Cocoa *)mainUnit
     inventoryList:(NSArray<JCHBeginInventoryForSKUViewData *> *)inventoryList
          unitList:(NSArray<ProductUnitRecord *> *)unitList
     operationType:(enum SetInitialInventoryOperation)operationType;

@end
