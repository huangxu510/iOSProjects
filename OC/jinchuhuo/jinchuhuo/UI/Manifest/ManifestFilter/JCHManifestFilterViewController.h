//
//  JCHManifestFilterViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

#define kManifestDateStartKey   @"manifestDateStartKey"
#define kManifestDateEndKey     @"manifestDateEndKey"
#define kManifestTimeStartKey   @"manifestTimeStartKey"
#define kManifestTimeEndKey     @"manifestTimeEndKey"
#define kManifestAmountStartKey @"manifestAmountStartKey"
#define kManifestAmountEndKey   @"manifestAmountEndKey"
#define kManifestTypeKey        @"manifestTypeKey"
#define kManifestPayWayKey      @"manifestPayWayKey"
#define kManifestPayStatusKey   @"manifestPayStatusKey"

@interface JCHManifestFilterViewController : JCHBaseViewController

@property (nonatomic, copy) void(^sendValueBlock)(BOOL needReloadData);
@property (nonatomic, retain) NSDictionary *manifestFilterCondition;

@end
