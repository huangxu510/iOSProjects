//
//  JCHBluetoothDeviceTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/6/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHBluetoothDeviceTableViewCell : JCHBaseTableViewCell

@property (nonatomic, copy) void (^disconnectBlock)(void);

- (void)setTitle:(NSString *)title;
- (void)setDisconnectButtonHidden:(BOOL)hidden;

@end
