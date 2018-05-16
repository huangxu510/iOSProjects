//
//  JCHManifestFilterMenuView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kManifestDateStartKey   @"manifestDateStartKey"
#define kManifestDateEndKey     @"manifestDateEndKey"
#define kManifestTimeStartKey   @"manifestTimeStartKey"
#define kManifestTimeEndKey     @"manifestTimeEndKey"
#define kManifestAmountStartKey @"manifestAmountStartKey"
#define kManifestAmountEndKey   @"manifestAmountEndKey"
#define kManifestTypeKey        @"manifestTypeKey"
#define kManifestPayWayKey      @"manifestPayWayKey"
#define kManifestPayStatusKey   @"manifestPayStatusKey"

@interface JCHManifestFilterMenuView : UIView

@property (nonatomic, retain) NSMutableDictionary *manifestFilterCondition;

@property (nonatomic, retain) NSString *searchString;

@property (nonatomic, copy) void(^commitBlock)(void);

//该view如果放在tableheader上则要实时更新offsetY
@property (nonatomic, assign) CGFloat offsetY;


- (instancetype)initWithFrame:(CGRect)frame
                    superView:(UIView *)superView;

//重置筛选条件   containManifestType是否重置货单类型
- (void)resetManifestFilterCondition:(BOOL)containManifestType;

@end
