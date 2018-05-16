//
//  JCHCreateManifestWarehouseSelectView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHCreateManifestWarehouseSelectView : UIView

@property (nonatomic, copy) void(^selectWarehouse)(void);
@property (nonatomic, retain) NSString *sourceWarehouse;
@property (nonatomic, retain) NSString *destinationWarehouse;

@end
