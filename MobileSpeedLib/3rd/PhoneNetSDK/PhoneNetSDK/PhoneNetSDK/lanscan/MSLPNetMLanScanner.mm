//
//  PNetMLanScanner.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "MSLPNetMLanScanner.h"
#import "PReportPingModel.h"
#import "PNetInfoTool.h"
#import "PNetModel.h"
#import "PNetworkCalculator.h"
#import "MSLPNSamplePing.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"

@interface MSLPNetMLanScanner()<PNSamplePingDelegate>
@property (nonatomic,assign) int cursor;
@property (nonatomic,copy) NSArray *ipList;
@property (nonatomic,strong) NSMutableArray *activedIps;
@property (nonatomic,strong) MSLPNSamplePing *samplePing;
@property (nonatomic,assign,getter=isStopLanScan) BOOL stopLanScan;
@end

@implementation MSLPNetMLanScanner


- (NSMutableArray *)activedIps
{
    if (!_activedIps) {
        _activedIps = [NSMutableArray array];
    }
    return _activedIps;
}

- (MSLPNSamplePing *)samplePing
{
    if (!_samplePing) {
        _samplePing = [[MSLPNSamplePing alloc] init];
        _samplePing.delegate = self;
    }
    return _samplePing;
}

- (BOOL)isScanning
{
    return !(self.isStopLanScan);
}

- (instancetype)init
{
    if (self = [super init]) {
        _cursor = 0;
        [self addObserver:self forKeyPath:@"cursor" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}


static MSLPNetMLanScanner *lanScanner_instance = nil;
+ (instancetype)shareInstance
{
    if (!lanScanner_instance) {
        lanScanner_instance = [[MSLPNetMLanScanner alloc] init];
    }
    return lanScanner_instance;
}

- (void)scan
{
    _stopLanScan = NO;
    PNetInfoTool *phoneNetTool = [PNetInfoTool shareInstance];
    [phoneNetTool refreshNetInfo];
    if ([phoneNetTool.pGetNetworkType isEqualToString:@"WIFI"]) {
        PDeviceNetInfo *device = [PDeviceNetInfo deviceNetInfo];
        
        NSString *ip = device.wifiIPV4;
        NSString *netMask = device.wifiNetmask;
        if (ip && netMask) {
            log4cplus_debug("PhoneNetSDK-LanScanner", "now device ip :%s , netMask:%s \n",[ip UTF8String],[netMask UTF8String]);
            _ipList = [PNetworkCalculator getAllHostsForIP:ip andSubnet:netMask];
            if (!_ipList && _ipList.count <= 0) {
                log4cplus_error("PhoneNetSDK-LanScanner", "caculating the ip list in the current LAN failed...\n");
                return;
            }
            log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s begin...",[self.ipList[self.cursor] UTF8String]);
            [self.samplePing startPingIp:self.ipList[self.cursor] packetCount:3];
            self.cursor++;
        }
    }
}

- (void)stop
{
    _stopLanScan = YES;
    if ([_samplePing isPing]) {
        [_samplePing stopPing];
        _activedIps = nil;
        _ipList = nil;
        _cursor = 0;
    }
    
}

#pragma mark - PNSamplePingDelegate
- (void)simplePing:(MSLPNSamplePing *)samplePing didTimeOut:(NSString *)ip
{
    
}

- (void)simplePing:(MSLPNSamplePing *)samplePing receivedPacket:(NSString *)ip
{
    log4cplus_debug("PhoneNetSDK-LanScanner", " %s  active",[ip UTF8String]);
    [self.delegate scanMLan:self activeIp:ip];
}

- (void)simplePing:(MSLPNSamplePing *)samplePing pingError:(NSException *)exception
{
    
}

- (void)simplePing:(MSLPNSamplePing *)samplePing finished:(NSString *)ip
{
    if (self.isStopLanScan) {
        _samplePing = nil;
        return;
    }
    _samplePing = nil;
    _samplePing = [[MSLPNSamplePing alloc] init];
    _samplePing.delegate = self;
    if (self.cursor < self.ipList.count) {
        [_samplePing startPingIp:self.ipList[self.cursor] packetCount:2];
    }
    self.cursor++;
}

- (void)resetPropertys
{
    _cursor = 0;
    _ipList = nil;
    _activedIps = nil;
    log4cplus_debug("PhoneNetSDK-LanScanner", "reseter propertys...\n");
}

#pragma mark - use KVO to observer progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    float newCursor = [[change objectForKey:@"new"] floatValue];
    if ([keyPath isEqualToString:@"cursor"]) {
        float percent = self.ipList.count == 0 ? 0.0f : ((float)newCursor/self.ipList.count);
        [self.delegate scanMlan:self percent:percent];
        log4cplus_debug("PhoneNetSDK-LanScanner", "percent: %f  \n",percent);
        if (newCursor == self.ipList.count) {
            _stopLanScan = YES;
            log4cplus_debug("PhoneNetSDK-LanScanner", "finish MLAN scan...\n");
            [self.delegate finishedScanMlan:self];
            [self resetPropertys];
        }
    }
}
@end
