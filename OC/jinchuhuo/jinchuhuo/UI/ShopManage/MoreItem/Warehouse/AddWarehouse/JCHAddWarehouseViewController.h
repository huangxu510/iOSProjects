//
//  JCHAddWarehouseViewController.h
//  jinchuhuo
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

enum WarehouseMode
{
    kAddWarehouse = 0,
    kModifyWarehouse = 1
};

@interface JCHAddWarehouseViewController : JCHBaseViewController

- (id)initWithWarehouseID:(NSString *)warehouseID controllerMode:(enum WarehouseMode)mode;

@end
