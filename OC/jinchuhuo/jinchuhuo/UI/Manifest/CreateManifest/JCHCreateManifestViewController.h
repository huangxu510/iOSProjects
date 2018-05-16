//
//  JCHCreateManifestViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHCreateManifestHeaderView.h"
#import "JCHCreateManifestFooterView.h"
#import "JCHManifestType.h"
#import "JCHDatePickerView.h"
#import "ProductRecord4Cocoa.h"
#import <SWTableViewCell.h>


@interface JCHCreateManifestViewController : JCHBaseViewController<JCHCreateManifestHeaderViewDelegate,
                                                                    JCHCreateManifestFooterViewDelegate,
                                                                    UITableViewDataSource,
                                                                    UITableViewDelegate,
                                                                    SWTableViewCellDelegate,
                                                                    UIAlertViewDelegate,
                                                                    JCHDatePickerViewDelegate,
                                                                    UIGestureRecognizerDelegate>
//扫码页面用来盘点是否是最新扫到的商品
@property (nonatomic, retain) NSString *lastEditedProductUUID;

//! @brief @{productNameUUID : InventoryDetailRecord4Cocoa}
@property (retain, nonatomic, readwrite) NSMutableDictionary *inventoryMap;

- (void)changeUIForScanCodeViewController;
- (void)loadData;
- (void)showKeyboard:(NSInteger)rowIndex;

// 扫码拼装单扫到主单位商品调用
- (void)showAssemblingKeyboard:(ProductRecord4Cocoa *)productRecord;

@end
