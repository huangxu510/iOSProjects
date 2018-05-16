//
//  CommonHeader.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUISizeSettings.h"
#import "JCHFinanceCalculateUtility.h"
#import "JCHCommonMacros.h"

//Custom View
#import "JCHTitleTextField.h"
#import "JCHArrowTapView.h"
#import "JCHTextView.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHPickerView.h"
#import "JCHTitleDetailLabel.h"
#import "JCHPlaceholderView.h"
#import "JCHPreventEnventTransferView.h"
#import "JCHCollectionViewFlowLayout.h"
#import "JCHLengthLimitTextField.h"
#import "JCHTableViewItemModel.h"
#import "JCHSwitchLabelView.h"


//Utility
#import "JCHSizeUtility.h"
#import "JCHFinanceCalculateUtility.h"
#import "JCHDisplayNameUtility.h"
#import "JCHKeyboardUtility.h"
#import "JCHImageUtility.h"
#import "JCHManifestUtility.h"
#import "JCHTransactionUtility.h"
#import "JCHSavingCardUtility.h"
#import "JCHAudioUtility.h"
#import "JCHPerimissionUtility.h"
#import "JCHRepairDataUtility.h"

//category
#import "UIFont+JCHFont.h"
#import "MBProgressHUD+JCHHud.h"
#import "UIView+JCHView.h"
#import "NSString+JCHString.h"
#import "UIImage+JCHImage.h"
#import "NSObject+JCHObject.h"
#import "UIButton+EnlargeTouchArea.h"
#import "AppDelegate+JCHAppDelegate.h"
#import "UITextField+JCHTextField.h"
#import "UINavigationController+JCHNav.h"


//Singleton
#import "JCHSyncStatusManager.h"
#import "JCHLocationManager.h"
#import "JCHBluetoothManager.h"
#import "ServiceFactory.h"
#import "JCHManifestMemoryStorage.h"
#import "AppDelegate.h"
#import "JCHAddedServiceManager.h"
#import "JCHPerformanceTestManager.h"
#import "JCHDataSyncManager.h"
#import "JCHNetworkingManager.h"
#import "JCHTakeoutManager.h"
#import "JCHAccountBookManager.h"


//数据常量
#import "JCHDataConstant.h"
#import "JCHTakeoutDataConstant.h"
#import "JCHServiceResponseNotification.h"
#import "JCHServiceResponseSettings.h"
#import "JCHSyncServerSettings.h"
#import "DataChangeNotification.h"

//三方库
#import <AFNetworking.h>
#import <Masonry.h>
#import <MSWeakTimer.h>
#import <IQKeyboardManager.h>

// 账本相关设置
#import "JCHBookSettings.h"

#endif /* CommonHeader_h */
