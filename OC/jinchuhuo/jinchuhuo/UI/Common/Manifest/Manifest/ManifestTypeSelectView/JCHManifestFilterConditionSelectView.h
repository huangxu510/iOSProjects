//
//  JCHManifestTypeSelectView.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kJCHManifestSeletedTypeAll            = -1,
    kJCHManifestSeletedTypePurchase       = 0,
    kJCHManifestSeletedTypeShipment       = 1,
    kJCHManifestSeletedTypePurchaseReject = 2,
    kJCHManifestSeletedTypeShipmentReject = 3,
};

enum
{
    kJCHManifestPayWayAll                 = -1,
    kJCHManifestPayWayCash                = 0,
    kJCHManifestPayWayOnAccount           = 1,
    kJCHManifestPayWayWeiXin              = 2,
};

enum
{
    kJCHManifestPayStatusAll              = -1,
    kJCHManifestPayStatusHasnotReceived    = 0,
    kJCHManifestPayStatusHasReceived       = 1,
    kJCHManifestPayStatusHasnotPaid        = 2,
    kJCHManifestPayStatusHasPaid           = 3,
};

@interface JCHManifestFilterConditionSelectView : UIView

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, assign) NSInteger selectedTag;

@end
