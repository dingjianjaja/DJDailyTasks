//
//  DJBluetoothSetVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/16.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#define TRANSFER_SERVICE_UUID @"c1e14e3c-2286-46ed-be2f-6794a8cdc961"
#define TRANSFER_CHARACTERISTIC_UUID @"c1e14e3c-2286-46ed-be2f-6794a8cdc922"

#import "DJBluetoothSetVC.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface DJBluetoothSetVC ()<CBPeripheralDelegate,CBCentralManagerDelegate>

@property (nonatomic, retain)CBMutableCharacteristic *transferCharacteristic;
@property (nonatomic, retain)CBPeripheral *peripheral;
@property (nonatomic, retain)CBPeripheralManager *peripheralManager;
@property (nonatomic, retain)CBCentralManager *central;
@property (nonatomic, retain)NSMutableArray *peripheraNames;

@property (nonatomic, retain)NSData *transData;

@end

@implementation DJBluetoothSetVC

#pragma mark -- lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"蓝牙数据传输";
    
    [self setBlueToothClient];
}

#pragma mark -- privateMethod
- (void)setBluetoothService{
    // 创建Peripheral，也就是我们的Server:
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    // 生成Service以备添加到Peripheral当中:
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
    // 生成characteristics以备添加到Service当中:
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];

    // 建立Peripheral，Server，characteristics三者之间的关系并开始广播服务:
    //建立关系
    transferService.characteristics = @[self.transferCharacteristic];
    [self.peripheralManager addService:transferService];
    //开始广播
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}

- (void)setBlueToothClient{
    // 创建我们的Central，也就是client:
    _central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    // 扫描可用的Peripheral:
//    [self.central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
//    options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
}

#pragma mark -- actions

- (IBAction)writeDataAction:(UIButton *)sender {
    [self.peripheral writeValue:self.transData forCharacteristic:self.transferCharacteristic type:CBCharacteristicWriteWithResponse];
    //第一个参数是已连接的蓝牙设备； 第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入 需要注意的是特征的属性是否支持写数据

}
#pragma mark -- delegate



#pragma mark -- centralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    // 蓝牙可用，开始扫描外设
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙可用");

        //在中心管理者成功开启之后再进行一些操作
        //搜索扫描外设
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        // [self.centralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
        [central scanForPeripheralsWithServices:nil options:nil];
    }

    if(central.state == CBManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
    }
    if (central.state == CBManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
    }
    if (central.state == CBManagerStateUnknown) {
        NSLog(@"蓝牙当前状态不明确");
    }
    if (central.state == CBManagerStateUnauthorized) {
        NSLog(@"蓝牙未被授权");
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@====",peripheral.name);


    if ([peripheral.name hasPrefix:@"dingjianjaja"]) {
        //在这里对外设携带的广播数据进行进一步的处理
        if ([self.peripheraNames containsObject:peripheral.name]) {
            //如果数组中包含了就不再添加
            return;
        }
        //添加到外设名字数组中
        [self.peripheraNames addObject:peripheral.name];
        //标记外设，让它的生命周期与控制器的一致
        self.peripheral = peripheral;
        // 可以根据外设名字来过滤外设

         [central connectPeripheral:peripheral options:nil];

    }

    // 连接外设
//     [central connectPeripheral:peripheral options:nil];

}


/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接成功之后，可以进行服务和特性的发现。 停止中心管理设备的扫描动作，要不然在你和已经连接好的外设进行数据沟通时，如果又有一个外设进行广播且符合你的连接条件，那么你的iOS设备也会去连接这个设备（因为iOS BLE4.0是支持一对多连接的），导致数据的混乱。

    //停止扫描动作
    [self.central stopScan];

    // 设置外设的代理
    peripheral.delegate = self;

    // 根据UUID来寻找服务

    // [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];

    //外设发现服务，传nil代表不过滤，一次性读出外设的所有服务
    [peripheral discoverServices:nil];

    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
}


/** 连接失败的回调 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
}

//丢失连接 掉线

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {

    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];

}

#pragma mark peripheralDelegate
/** 发现服务 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    // 遍历出外设中所有的服务

    for (CBService *service in peripheral.services) {

         NSLog(@"所有的服务：%@",service);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }

    }

    // 这里仅有一个服务，所以直接获取

//    CBService *service = peripheral.services.lastObject;

    // 根据UUID寻找服务中的特征

    // [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];

    // [peripheral discoverCharacteristics:@[service.UUID] forService:service];

//    [peripheral discoverCharacteristics:nil forService:service];

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"didDiscoverCharacteristicsForService:::%@",service);
    for (CBCharacteristic * characteristic in service.characteristics)
      {
        NSLog(@"characteristic:%@",characteristic);
          if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
              
          }
      }
}




- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdateValueForCharacteristic::::%@",characteristic);
//     if (characteristic == @"你要的特征的UUID或者是你已经找到的特征") {
//
//     //characteristic.value就是你要的数据
//
//     }

    if ([peripheral.name hasPrefix:@"TEAMOSA"]){

    NSData *data = characteristic.value;

//    NSString *value = [self hexadecimalString:data];

    // NSLog(@"characteristic(读取到的): %@, data : %@, value : %@", characteristic, data, value);

    }

    // 拿到外设发送过来的数据
     NSData *data = characteristic.value;
     NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataStr);
}


// 写入回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success(写入成功) : %@", characteristic);
}

#pragma mark -- lazyloading
- (NSMutableArray *)peripheraNames{
    if (!_peripheraNames) {
        _peripheraNames = [NSMutableArray array];
    }
    return _peripheraNames;
}

- (CBMutableCharacteristic *)transferCharacteristic{
    if (!_transferCharacteristic) {
        _transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    }
    return _transferCharacteristic;
}


@end
