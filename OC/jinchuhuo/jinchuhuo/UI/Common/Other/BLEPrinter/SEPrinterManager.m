//
//  SEPrinterManager.m
//  SEBLEPrinter
//
//  Created by Harvey on 16/5/5.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "SEPrinterManager.h"

#define kSECharacter    @"character"
#define kSEType         @"type"

// 发送数据时，需要分段的长度，部分打印机一次发送数据过长就会乱码，需要分段发送。这个长度值不同的打印机可能不一样，你需要调试设置一个合适的值（最好是偶数）
#define kLimitLength    80

@interface SEPrinterManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (copy, nonatomic)   SEScanPerpheralSuccess             scanPerpheralSuccess;  /**< 扫描设备成功的回调 */
@property (copy, nonatomic)   SEScanPerpheralFailure             scanPerpheralFailure;  /**< 扫描设备失败的回调 */
@property (copy, nonatomic)   SEConnectCompletion                connectCompletion;    /**< 连接完成的回调 */
@property (copy, nonatomic)   SEFullOptionCompletion             optionCompletion;    /**< 连接、扫描、搜索 */

@property (copy, nonatomic)   SEDisconnect                       disconnectBlock;    /**< 断开连接的回调 */

@property (strong, nonatomic)   SEPrintResult                   printResult;  /**< 打印结果的回调 */

@property (strong, nonatomic)   CBCentralManager            *centralManager;        /**< 中心管理器 */
@property (strong, nonatomic)   NSMutableArray              *perpherals;  /**< 搜索到的蓝牙设备列表 */

@property (strong, nonatomic)     NSMutableArray              *connectedPerpherals;    /**< 当前连接的外设 */
//@property (strong, nonatomic)   NSMutableArray              *writeChatacters;  /**< 可写入数据的特性 */

@property (strong, nonatomic) NSMutableDictionary *writeCharacteristicForPerpheral;

@property (assign, nonatomic)   NSTimeInterval              timeout;  /**< 默认超时时间 */

@property (strong, nonatomic)   HLPrinter            *printer;  /**< 打印器 */

@property (assign, nonatomic)   BOOL             autoConnect;  /**< 自动连接上次的外设 */


@end

static SEPrinterManager *instance = nil;

@implementation SEPrinterManager

+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (NSString *)UUIDStringForLastPeripheral
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UUIDString = [userDefaults objectForKey:@"peripheral"];
    return UUIDString;
}

- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        instance.perpherals = [[NSMutableArray alloc] init];
        instance.writeCharacteristicForPerpheral = [NSMutableDictionary dictionary];
        instance.connectedPerpherals = [[NSMutableArray alloc] init];
        instance.timeout = 30;
        [instance resetBLEModel];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

#pragma mark - bluetooth method
- (void)setTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
    
    if (_timeout > 0) {
        [self performSelector:@selector(timeoutAction) withObject:nil afterDelay:timeout];
    }
}

- (void)timeoutAction
{
    [_centralManager stopScan];
    if (_perpherals.count == 0) {
        //分发错误信息

        if (_scanPerpheralFailure) {
            _scanPerpheralFailure(SEScanErrorTimeout);
        }
    } else {

        if (_scanPerpheralSuccess) {
            _scanPerpheralSuccess(_perpherals,YES);
        }
    }
}

- (BOOL)isConnected
{
    if (_connectedPerpherals.count == 0) {
        return NO;
    }
    
//    if (_connectedPerpheral.state != CBPeripheralStateConnected && _connectedPerpheral.state != CBPeripheralStateConnecting) {
//        return NO;
//    }
    
    return YES;
}

- (void)resetBLEModel
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    [_perpherals removeAllObjects];
    [_connectedPerpherals removeAllObjects];
}

- (void)startScanPerpheralTimeout:(NSTimeInterval)timeout
{
    self.timeout = timeout;
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        return;
    }
    
    [self resetBLEModel];
}

- (void)startScanPerpheralTimeout:(NSTimeInterval)timeout Success:(SEScanPerpheralSuccess)success failure:(SEScanPerpheralFailure)failure
{
    [_perpherals removeAllObjects];
    self.timeout = timeout;
    _scanPerpheralSuccess = success;
    _scanPerpheralFailure = failure;
    
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        return;
    }
    
    [self resetBLEModel];
}

- (void)stopScan
{
    _scanPerpheralSuccess = nil;
    _scanPerpheralFailure = nil;
    [_centralManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [_centralManager connectPeripheral:peripheral options:nil];
    peripheral.delegate = self;
}

- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(SEConnectCompletion)completion
{
    _connectCompletion = completion;
    [self connectPeripheral:peripheral];
}

- (void)fullOptionPeripheral:(CBPeripheral *)peripheral completion:(SEFullOptionCompletion)completion
{
    _optionCompletion = completion;
    [self connectPeripheral:peripheral];
}

- (void)cancelPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return;
    }
    [_centralManager cancelPeripheralConnection:peripheral];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"peripheral"];
    [userDefaults synchronize];
}

- (void)autoConnectLastPeripheralTimeout:(NSTimeInterval)timeout completion:(SEConnectCompletion)completion
{
    self.timeout = timeout;
    
    _autoConnect = YES;
    
    _connectCompletion = completion;
    
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)setDisconnect:(SEDisconnect)disconnectBlock
{
    _disconnectBlock = disconnectBlock;
}

- (void)sendPrintData:(NSData *)data peripheral:(CBPeripheral *)perpheral completion:(SEPrintResult)result
{
    if (self.connectedPerpherals.count == 0) {
        if (result) {
            result(nil,NO,@"未连接蓝牙设备");
        }
        return;
    }
    
    if ([[_writeCharacteristicForPerpheral objectForKey:perpheral] count] == 0) {
        if (result) {
           result(perpheral,NO,@"该蓝牙设备不能写入数据");
        }
        return;
    }
    
    
    NSDictionary *dict = nil;
    
    if ([perpheral.name containsString:@"SGT"]) {
        dict = [[_writeCharacteristicForPerpheral objectForKey:perpheral] firstObject];
    } else {
        dict = [[_writeCharacteristicForPerpheral objectForKey:perpheral] lastObject];
    }
    
    // 如果kLimitLength 小于等于0，则表示不用分段发送
    if (kLimitLength <= 0) {
        _printResult = result;
        [perpheral writeValue:data forCharacteristic:dict[kSECharacter] type:[dict[kSEType] integerValue]];
    } else {
        if (data.length <= kLimitLength) {
            _printResult = result;
            [perpheral writeValue:data forCharacteristic:dict[kSECharacter] type:[dict[kSEType] integerValue]];
        } else {
            NSInteger index = 0;
            for (index = 0; index < data.length - kLimitLength; index += kLimitLength) {
                NSData *subData = [data subdataWithRange:NSMakeRange(index, kLimitLength)];
                [perpheral writeValue:subData forCharacteristic:dict[kSECharacter] type:[dict[kSEType] integerValue]];
            }
            _printResult = result;
            NSData *leftData = [data subdataWithRange:NSMakeRange(index, data.length - index)];
            if (leftData) {
                [perpheral writeValue:leftData forCharacteristic:dict[kSECharacter] type:[dict[kSEType] integerValue]];
            }
        }
    }
    
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        if (_scanPerpheralFailure) {
            _scanPerpheralFailure((SEScanError)central.state);
        }
        
    } else {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name.length <= 0) {
        return ;
    }
    if (_perpherals.count == 0) {
        [_perpherals addObject:peripheral];
    } else {
        BOOL isExist = NO;
        for (int i = 0; i < _perpherals.count; i++) {
            CBPeripheral *per = [_perpherals objectAtIndex:i];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                [_perpherals replaceObjectAtIndex:i withObject:peripheral];
            }
        }
        
        if (!isExist) {
            [_perpherals addObject:peripheral];
        }
    }
    
    if (_scanPerpheralSuccess) {
        _scanPerpheralSuccess(_perpherals,NO);
    }
    
    if (_autoConnect) {
        NSString *UUIDString = [SEPrinterManager UUIDStringForLastPeripheral];
        
        if ([peripheral.identifier.UUIDString isEqualToString:UUIDString]) {
            [_centralManager connectPeripheral:peripheral options:nil];
            peripheral.delegate = self;
        }
    }
}

#pragma mark ---------------- 连接外设成功和失败的代理 ---------------
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [_connectedPerpherals addObject:peripheral];
    [_writeCharacteristicForPerpheral setObject:[NSMutableArray array] forKey:peripheral];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:peripheral.identifier.UUIDString forKey:@"peripheral"];
    [userDefaults synchronize];
    
    
    if (_connectCompletion) {
        _connectCompletion(peripheral,nil);
    }
    
    if (_optionCompletion) {
        _optionCompletion(SEOptionStageConnection,peripheral,nil);
    }
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if (_connectCompletion) {
        _connectCompletion(peripheral,error);
    }
    
    if (_optionCompletion) {
        _optionCompletion(SEOptionStageConnection, peripheral,error);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [_connectedPerpherals removeObject:peripheral];
    [_writeCharacteristicForPerpheral removeObjectForKey:peripheral];
    
    if (_disconnectBlock) {
        _disconnectBlock(peripheral,error);
    }
}

#pragma mark ---------------- 发现服务的代理 -----------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error) {
        if (_optionCompletion) {
            _optionCompletion(SEOptionStageSeekServices,peripheral,error);
        }
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    if (_optionCompletion) {
        _optionCompletion(SEOptionStageSeekServices,peripheral,nil);
    }
}

#pragma mark ---------------- 服务特性的代理 --------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (error) {
        if ([service isEqual:peripheral.services.lastObject]) {
            
            if ([[_writeCharacteristicForPerpheral objectForKey:peripheral] count] > 0) {
                if (_optionCompletion) {
                    _optionCompletion(SEOptionStageSeekCharacteristics,peripheral,nil);
                }
            } else {
                if (_optionCompletion) {
                    _optionCompletion(SEOptionStageSeekCharacteristics,peripheral,error);
                }
            }
        }
        return;
    }
    
    for (CBCharacteristic *character in service.characteristics) {
        CBCharacteristicProperties properties = character.properties;
        //如果我们需要回调，则就不要使用没有返回的特性来写入数据
        
        if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
            NSDictionary *dict = @{kSECharacter:character,kSEType:@(CBCharacteristicWriteWithoutResponse)};
            NSMutableArray *characteristicArray = [_writeCharacteristicForPerpheral objectForKey:peripheral];
            [characteristicArray addObject:dict];
            [_writeCharacteristicForPerpheral setObject:characteristicArray forKey:peripheral];
        }
    }
    
    if ([service isEqual:peripheral.services.lastObject]) {
        if (_optionCompletion) {
            _optionCompletion(SEOptionStageSeekCharacteristics,peripheral,nil);
        }
    }
}

#pragma mark ---------------- 写入数据的回调 --------------------
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (!_printResult) {
        return;
    }
    
    if (error) {
        _printResult(peripheral,NO,@"发送失败");
    } else {
        _printResult(peripheral,YES,@"已成功发送至蓝牙设备");
    }
}


@end
