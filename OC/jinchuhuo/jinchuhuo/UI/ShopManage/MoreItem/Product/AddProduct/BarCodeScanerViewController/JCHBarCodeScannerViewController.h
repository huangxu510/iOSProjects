//
//  JCHBarCodeScannerViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHAddProductRecordViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^sendBarCodeBlock)(NSString *code);
@interface JCHBarCodeScannerViewController : JCHBaseViewController

@property (nonatomic, retain) NSString *detailInfo;
@property (nonatomic, copy) sendBarCodeBlock barCodeBlock;

//需要扫描二维码的格式
@property (nonatomic, retain) NSArray *metadataObjectTypes;

- (id)initWithController:(UIViewController *)controller;

@end
