//
//  SEPrinterManager.h
//  SEBLEPrinter
//
//  Created by Harvey on 16/5/5.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "SEBLEConst.h"
#import "HLPrinter.h"

@interface SEPrinterManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *connectedPerpherals;    /**< 当前连接的外设 */

#pragma mark - bluetooth method

+ (instancetype)sharedInstance;

/**
 *  上次连接的蓝牙外设的UUIDString
 *
 *  @return UUIDString,没有时返回nil
 */
+ (NSString *)UUIDStringForLastPeripheral;

/**
 *  蓝牙外设是否已连接
 *
 *  @return YES/NO
 */
- (BOOL)isConnected;

/**
 *  开始扫描蓝牙外设
 *  @param timeout 扫描超时时间,设置为0时表示一直扫描
 */
- (void)startScanPerpheralTimeout:(NSTimeInterval)timeout;

/**
 *  开始扫描蓝牙外设，block方式返回结果
 *  @param timeout 扫描超时时间，设置为0时表示一直扫描
 *  @param success 扫描成功的回调
 *  @param failure 扫描失败的回调
 */
- (void)startScanPerpheralTimeout:(NSTimeInterval)timeout Success:(SEScanPerpheralSuccess)success failure:(SEScanPerpheralFailure)failure;

/**
 *  停止扫描蓝牙外设
 */
- (void)stopScan;

/**
 *  连接蓝牙外设,连接成功后会停止扫描蓝牙外设
 *
 *  @param peripheral 蓝牙外设
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/**
 *  连接蓝牙外设，连接成功后会停止扫描蓝牙外设，block方式返回结果
 *
 *  @param peripheral 要连接的蓝牙外设
 *  @param completion 完成后的回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(SEConnectCompletion)completion;

/**
 *  完整操作，包括连接、扫描服务、扫描特性、扫描描述
 *
 *  @param peripheral 要连接的蓝牙外设
 *  @param completion 完成后的回调
 */
- (void)fullOptionPeripheral:(CBPeripheral *)peripheral completion:(SEFullOptionCompletion)completion;

/**
 *  取消某个蓝牙外设的连接
 *
 *  @param peripheral 蓝牙外设
 */
- (void)cancelPeripheral:(CBPeripheral *)peripheral;

/**
 *  自动连接上次的蓝牙外设
 *
 *  @param timeout
 *  @param completion
 */
- (void)autoConnectLastPeripheralTimeout:(NSTimeInterval)timeout completion:(SEConnectCompletion)completion;

/**
 *  设置断开连接的block
 *
 *  @param disconnectBlock
 */
- (void)setDisconnect:(SEDisconnect)disconnectBlock;

/**
 *  打印自己组装的数据
 *
 *  @param data
 *  @param perpheral 设备
 *  @param result 结果
 */
- (void)sendPrintData:(NSData *)data peripheral:(CBPeripheral *)perpheral completion:(SEPrintResult)result;


@end
