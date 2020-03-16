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

@interface DJBluetoothSetVC ()<CBPeripheralDelegate,CBCentralManagerDelegate,CBPeripheralManagerDelegate,UITextViewDelegate>

@property (nonatomic, retain)CBMutableCharacteristic *transferCharacteristic;
@property (nonatomic, retain)CBPeripheral *peripheral;
@property (nonatomic, retain)CBPeripheralManager *peripheralManager;
@property (nonatomic, retain)CBCentralManager *central;
@property (nonatomic, retain)NSMutableArray *peripheraNames;

@property (nonatomic, retain)NSData *transData;
@property (weak, nonatomic) IBOutlet UITextView *msgTextV;

@end

@implementation DJBluetoothSetVC

#pragma mark -- lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"蓝牙数据传输";
}

#pragma mark -- privateMethod


#pragma mark -- actions
// 接收者
- (IBAction)receiveAction:(UIButton *)sender {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
}

// 发送者
- (IBAction)setSender:(UIButton *)sender {
    
    _central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (IBAction)writeDataAction:(UIButton *)sender {
//    [self.peripheral writeValue:self.transData forCharacteristic:self.transferCharacteristic type:CBCharacteristicWriteWithResponse];
    //第一个参数是已连接的蓝牙设备； 第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入 需要注意的是特征的属性是否支持写数据
    
    [self.peripheralManager updateValue:self.transData forCharacteristic:self.transferCharacteristic onSubscribedCentrals:@[]];
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
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
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
    
    // 链接外设
    [self.central connectPeripheral:peripheral options:nil];
    self.peripheral = peripheral;



}


/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接成功之后，可以进行服务和特性的发现。
    //停止扫描动作
    [self.central stopScan];

    // 设置外设的代理
    peripheral.delegate = self;

    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    
    
    // 连接成功之后查找可用的Service：
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
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
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务:%@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    
    
    //找到Service之后，进一步查找可用的Characteristics并订阅:
    //查找Characteristics

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"didDiscoverCharacteristicsForService:::%@",service);
    for (CBCharacteristic * characteristic in service.characteristics)
      {
        NSLog(@"characteristic:%@",characteristic);
          if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
              //订阅
              [peripheral setNotifyValue:YES forCharacteristic:characteristic];
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
    self.msgTextV.text = dataStr;
    NSLog(@"%@",dataStr);
}


// 写入回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success(写入成功) : %@", characteristic);
}

#pragma mark -- textViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    self.transData = [textView.text dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
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





- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙状态开启");

        // 生成Service以备添加到Peripheral当中:
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        //生成characteristics以备添加到Service当中:
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
        
        // 建立Peripheral，Server，characteristics三者之间的关系并开始广播服务:
        //建立关系
        transferService.characteristics = @[self.transferCharacteristic];
        [self.peripheralManager addService:transferService];
        //开始广播
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
}






- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return CGSizeMake(100, 100);
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
    
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return YES;
}

- (void)updateFocusIfNeeded {
    
}

@end
