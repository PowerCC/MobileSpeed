//
//  TestUtils.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "NSString+Extension.h"
#import "TestUtils.h"
#import "MSLGBDeviceInfo.h"
#import "MSLFCUUID.h"
#import "MSLINTULocationManager.h"
#import "PhonePingService.h"

@interface TestUtils () <MSLGCDAsyncUdpSocketDelegate>
@property (copy, nonatomic) NSString *testHost;
@property (copy, nonatomic) NSString *testPort;
@property (copy, nonatomic) NSString *testDuration;

//@property (strong, nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSString *udpTestString;
@property (assign, nonatomic) NSInteger udpIndex;
@property (assign, nonatomic) NSInteger udpLoss;
@property (strong, nonatomic) NSDate *udpStartDate;
@property (strong, nonatomic) NSDate *udpEndDate;
@property (weak, nonatomic) id<MSLGCDAsyncUdpSocketDelegate> updDelegate;

@property (strong, nonatomic) NSMutableArray *pingResultTextArray;
@property (strong, nonatomic) NSMutableArray *tcpPingResultTextArray;
@property (strong, nonatomic) NSMutableArray *udpResultTextArray;

@property (copy, nonatomic) NSString *appId;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *businessState;

@property (copy, nonatomic) NSString *lastTracertResult;
@end

@implementation TestUtils

static TestUtils *testUtils = nil;
+ (instancetype)getSharedInstance {
    if (testUtils == nil) {
        testUtils = [[TestUtils alloc]init];
        testUtils.speedUpUtils = [[SpeedUpUtils alloc] init];

        testUtils.testHost = defaultIp;
        testUtils.testPort = defaultPort;
        testUtils.testDuration = @"10";

        testUtils.appId = testAppId;
        testUtils.userId = testUserId;
        testUtils.businessId = testBusinessId;
        testUtils.businessState = @"1";
    }

    return testUtils;
}

+ (instancetype)sharedInstance:(NSString *)appId userId:(NSString *)userId businessId:(NSString *)businessId businessState:(NSString *)businessState {
    if (testUtils == nil) {
        testUtils = [[TestUtils alloc]init];
        testUtils.speedUpUtils = [[SpeedUpUtils alloc] init];
    }

    if (testUtils.pingResultTextArray == nil) {
        testUtils.pingResultTextArray = [NSMutableArray arrayWithCapacity:0];
    }

    if (testUtils.tcpPingResultTextArray == nil) {
        testUtils.tcpPingResultTextArray = [NSMutableArray arrayWithCapacity:0];
    }

    if (testUtils.udpResultTextArray == nil) {
        testUtils.udpResultTextArray = [NSMutableArray arrayWithCapacity:0];
    }

    testUtils.testHost = defaultIp;
    testUtils.testPort = defaultPort;
    testUtils.testDuration = @"10";

    testUtils.appId = appId;
    testUtils.userId = userId;
    testUtils.businessId = businessId;
    testUtils.businessState = businessState;

    return testUtils;
}

+ (instancetype)sharedInstance:(NSString *)host port:(NSString *)port duration:(NSString *)duration appId:(NSString *)appId userId:(NSString *)userId businessId:(NSString *)businessId businessState:(NSString *)businessState {
    if (testUtils == nil) {
        testUtils = [[TestUtils alloc]init];
        testUtils.speedUpUtils = [[SpeedUpUtils alloc] init];
    }

    testUtils.pingResultTextArray = [NSMutableArray arrayWithCapacity:0];
    testUtils.tcpPingResultTextArray = [NSMutableArray arrayWithCapacity:0];
    testUtils.udpResultTextArray = [NSMutableArray arrayWithCapacity:0];

    testUtils.testHost = [host stringByReplacingOccurrencesOfString:@" " withString:@""];
    testUtils.testPort = [port stringByReplacingOccurrencesOfString:@" " withString:@""];
    testUtils.testDuration = [duration stringByReplacingOccurrencesOfString:@" " withString:@""];

    testUtils.appId = appId;
    testUtils.userId = userId;
    testUtils.businessId = businessId;
    testUtils.businessState = businessState;

    return testUtils;
}

- (void)getDeviceInfo:(DeviceInfoHandler)infoHandler {
    DeviceInfoModel *infoModel = [DeviceInfoModel shared];
    MSLGBDeviceInfo *deviceInfo = [MSLGBDeviceInfo deviceInfo];

    infoModel.osVer = [NSString stringWithFormat:@"%lu.%lu.%lu", (unsigned long)deviceInfo.osVersion.major, (unsigned long)deviceInfo.osVersion.minor, (unsigned long)deviceInfo.osVersion.patch];
    infoModel.phoneModel = [NSString stringWithFormat:@"%@（%@）", deviceInfo.modelString, deviceInfo.rawSystemInfoString];
    infoModel.mobileNetworkStandard = [NSString stringWithFormat:@"%@%@", [DeviceUtils getDeviceCarrierName], [DeviceUtils getDeviceNetworkName]];
    infoModel.uuid = [MSLFCUUID uuid];

    MSLPhoneNetManager *phoneNetManager = [MSLPhoneNetManager shareInstance];

    if ([phoneNetManager.netGetNetworkInfo.deviceNetInfo.netType isEqual:@"WIFI"]) {
        infoModel.intranetIP = phoneNetManager.netGetNetworkInfo.deviceNetInfo.wifiIPV4;
    } else {
        infoModel.intranetIP = phoneNetManager.netGetNetworkInfo.deviceNetInfo.cellIPV4;
    }

    [_speedUpUtils getAreaInfo:^(SpeedUpAreaInfoModel *_Nullable model, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
        infoModel.publicIP = model.ip;
        infoModel.areaInfo = model;

//        MSLINTULocationManager *locMgr = [MSLINTULocationManager sharedInstance];
//        [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
//                                           timeout:10.0
//                              delayUntilAuthorized:YES
//                                             block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
//                                                 if (status == INTULocationStatusSuccess) {
//                                                     NSString *la = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
//                                                     NSString *lo = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
//                                                     infoModel.latitude = la;
//                                                     infoModel.longitude = lo;
//                                                 } else if (status == INTULocationStatusTimedOut) {
//                                                     infoModel.latitude = @"";
//                                                     infoModel.longitude = @"";
//                                                 } else {
//                                                     infoModel.latitude = @"";
//                                                     infoModel.longitude = @"";
//                                                 }
//
//                                                 if (infoHandler) {
//                                                     infoHandler(infoModel);
//                                                 }
//                                             }];

        if (infoHandler) {
            infoHandler(infoModel);
        }
    }];
}

- (void)formatPingResultText {
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.pingResultTextArray && weakSelf.pingResultTextArray.count > 0) {
            NSMutableArray *lossPacketArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:0];
            NSString *finalPingText = @"";

            for (NSString *pingText in weakSelf.pingResultTextArray) {
                if ([pingText containsString:@"0 bytes form"]) {
                    [lossPacketArray addObject:pingText];
                } else if ([pingText containsString:@"packets transmitted"]) {
                    finalPingText = pingText;
                } else if ([pingText containsString:@"packets transmitted"] == NO) {
                    NSArray *tempArray = [pingText componentsSeparatedByString:@"time="];
                    if (tempArray) {
                        NSString *tempTime = tempArray.lastObject;
                        if (tempTime) {
                            NSString *time = [tempTime stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                            if (time) {
                                [timeArray addObject:time];
                            }
                        }
                    }
                }
            }

            //最大值
            double maxTime = [[timeArray valueForKeyPath:@"@max.doubleValue"] doubleValue];

            //最小值
            double minTime = [[timeArray valueForKeyPath:@"@min.doubleValue"] doubleValue];

            if (finalPingText) {
                NSArray *finalPingTextArray = [finalPingText componentsSeparatedByString:@" , "];
                if (finalPingTextArray && finalPingTextArray.count == 4) {
                    NSString *packets = [finalPingTextArray[0] stringByReplacingOccurrencesOfString:@" packets transmitted" withString:@""];
                    NSString *delay = [finalPingTextArray[2] stringByReplacingOccurrencesOfString:@"delay:" withString:@""];
                    NSString *loss = [finalPingTextArray[1] stringByReplacingOccurrencesOfString:@"loss:" withString:@""];
                    NSString *text1 = [NSString stringWithFormat:@"发包数：%@\n", packets];
                    NSString *text2 = [NSString stringWithFormat:@"平均时延：%@\n", delay];
                    NSString *text3 = [NSString stringWithFormat:@"最高时延：%.3fms\n", maxTime];
                    NSString *text4 = [NSString stringWithFormat:@"最低时延：%.3fms\n", minTime];
                    NSString *text5 = [NSString stringWithFormat:@"丢包次数：%lu\n", (unsigned long)lossPacketArray.count];
                    NSString *text6 = [NSString stringWithFormat:@"丢包率：%@%%\n", loss];

                    NSMutableArray *timeNumberArray = [NSMutableArray arrayWithCapacity:0];
                    for (NSString *t in timeArray) {
                        double n = [t doubleValue];
                        [timeNumberArray addObject:[NSNumber numberWithDouble:n]];
                    }

                    MSLPhoneNetManager *phoneNetManager = [MSLPhoneNetManager shareInstance];

                    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                    params[@"networkType"] = phoneNetManager.netGetNetworkInfo.deviceNetInfo.netType;
                    params[@"totalPacketCount"] = [NSNumber numberWithInteger:[packets integerValue]];
                    params[@"allDelayMillis"] = timeNumberArray;
                    params[@"averageDelayMillis"] = [NSNumber numberWithDouble:[[delay stringByReplacingOccurrencesOfString:@"ms" withString:@""] doubleValue]];
                    params[@"maxDelayMillis"] = [NSNumber numberWithDouble:maxTime];
                    params[@"minDelayMillis"] = [NSNumber numberWithDouble:minTime];
                    params[@"droppedPacketCount"] = [NSNumber numberWithInteger:lossPacketArray.count];
                    params[@"droppedPacketRatio"] = [NSNumber numberWithDouble:[loss doubleValue]];
                    
                    NSString *tracertResult = [NSString stringWithFormat:@"%@%@%@%@%@%@", text1, text2, text3, text4, text5, text6];
                    params[@"tracertResult"] = @[tracertResult];
                    
                    weakSelf.lastTracertResult = tracertResult;

                    NSLog(@"ping params:%@", params);

                    [weakSelf uploadTestResult:@"PING" port:@"" duration:weakSelf.testDuration testParams:params completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                        [weakSelf.pingResultTextArray removeAllObjects];
                    }];
                }
            } else {
                [weakSelf.pingResultTextArray removeAllObjects];
            }
        } else {
            NSLog(@"\nPingResultTextArray Empty\n");
            [weakSelf.pingResultTextArray removeAllObjects];
        }
    });
}

- (void)formatTcpPingResultText {
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.tcpPingResultTextArray && weakSelf.tcpPingResultTextArray.count > 0) {
            NSString *text = weakSelf.tcpPingResultTextArray[weakSelf.tcpPingResultTextArray.count - 1];
            if (text && text.length > 0) {
                if ([text containsString:@"connect failed"] || [text containsString:@"DNS error"]) {
//                    textView.text = @"测试失败，网络连接错误！";
                    [weakSelf.tcpPingResultTextArray removeAllObjects];
                } else {
                    NSArray *pingTextArray = [text componentsSeparatedByString:@"TCP conn "];
                    if (pingTextArray && pingTextArray.count >= 2) {
                        NSArray *resultArray = [pingTextArray[1] componentsSeparatedByString:@",  min/avg/max = "];
                        if (resultArray && resultArray.count >= 2) {
                            NSString *loss = [resultArray[0] stringByReplacingOccurrencesOfString:@"loss=" withString:@""];
                            NSArray *countArray = [resultArray[1] componentsSeparatedByString:@"/"];
                            if (countArray && countArray.count >= 3) {
                                NSString *min = countArray[0];
                                NSString *avg = countArray[1];
                                NSString *max = [countArray[2] stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                                //最大值
                                double maxTime = [max doubleValue];

                                //最小值
                                double minTime = [min doubleValue];

                                NSString *text1 = [NSString stringWithFormat:@"发包数：%lu\n", (unsigned long)weakSelf.tcpPingResultTextArray.count];
                                NSString *text2 = [NSString stringWithFormat:@"平均时延：%@ms\n", avg];
                                NSString *text3 = [NSString stringWithFormat:@"最高时延：%.3fms\n", maxTime];
                                NSString *text4 = [NSString stringWithFormat:@"最低时延：%.3fms\n", minTime];
                                NSString *text5 = [NSString stringWithFormat:@"丢包次数：%@\n", loss];
                                NSString *text6 = [NSString stringWithFormat:@"丢包率：%.f%%\n", ([loss doubleValue] / weakSelf.tcpPingResultTextArray.count * 100)];

                                NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:0];
                                NSArray *tempArray = [text componentsSeparatedByString:@"\n"];
                                for (NSString *delay in tempArray) {
                                    NSArray *tempArray1 = [delay componentsSeparatedByString:@",  "];
                                    if (tempArray1 && tempArray1.count > 1) {
                                        NSString *time = [tempArray1[1] stringByReplacingOccurrencesOfString:@" ms" withString:@""];
                                        [timeArray addObject:time];
                                    }
                                }

                                if (timeArray.count > 1) {
                                    [timeArray removeLastObject];
                                }

                                NSMutableArray *timeNumberArray = [NSMutableArray arrayWithCapacity:0];
                                for (NSString *t in timeArray) {
                                    double n = [t doubleValue];
                                    [timeNumberArray addObject:[NSNumber numberWithDouble:n]];
                                }

                                MSLPhoneNetManager *phoneNetManager = [MSLPhoneNetManager shareInstance];

                                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                params[@"networkType"] = phoneNetManager.netGetNetworkInfo.deviceNetInfo.netType;
                                params[@"totalPacketCount"] = [NSNumber numberWithInteger:weakSelf.tcpPingResultTextArray.count];
                                params[@"allDelayMillis"] = timeNumberArray;
                                params[@"averageDelayMillis"] = [NSNumber numberWithDouble:[avg doubleValue]];
                                params[@"maxDelayMillis"] = [NSNumber numberWithDouble:maxTime];
                                params[@"minDelayMillis"] = [NSNumber numberWithDouble:minTime];
                                params[@"droppedPacketCount"] = [NSNumber numberWithDouble:[loss doubleValue]];
                                params[@"droppedPacketRatio"] = [NSNumber numberWithInteger:([loss doubleValue] / weakSelf.tcpPingResultTextArray.count * 100)];
                                
                                NSString *tracertResult = [NSString stringWithFormat:@"%@%@%@%@%@%@", text1, text2, text3, text4, text5, text6];
                                params[@"tracertResult"] = @[tracertResult];
                                
                                weakSelf.lastTracertResult = tracertResult;

                                NSLog(@"tcpping params:%@", params);

                                [weakSelf uploadTestResult:@"PING" port:weakSelf.testPort duration:weakSelf.testDuration testParams:params completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                                    [weakSelf.tcpPingResultTextArray removeAllObjects];
                                }];
                            } else {
                                [weakSelf.tcpPingResultTextArray removeAllObjects];
                            }
                        } else {
                            [weakSelf.tcpPingResultTextArray removeAllObjects];
                        }
                    } else {
                        [weakSelf.tcpPingResultTextArray removeAllObjects];
                    }
                }
            } else {
                [weakSelf.tcpPingResultTextArray removeAllObjects];
            }
        } else {
            NSLog(@"\nTcpPingResultTextArray Empty\n");
            [weakSelf.tcpPingResultTextArray removeAllObjects];
        }
    });
}

- (void)formatUdpResultText {
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.udpResultTextArray && weakSelf.udpResultTextArray.count > 0) {
            NSMutableArray *lossPacketArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:0];

            for (NSString *pingText in weakSelf.udpResultTextArray) {
                if ([pingText containsString:@"0 bytes form"]) {
                    [lossPacketArray addObject:pingText];
                } else if ([pingText containsString:@"packets transmitted"] == NO) {
                    NSArray *tempArray = [pingText componentsSeparatedByString:@"time="];
                    if (tempArray) {
                        NSString *tempTime = tempArray.lastObject;
                        if (tempTime) {
                            NSString *time = [tempTime stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                            if (time) {
                                [timeArray addObject:time];
                            }
                        }
                    }
                }
            }

            //最大值
            double maxTime = [[timeArray valueForKeyPath:@"@max.doubleValue"] doubleValue];

            //最小值
            double minTime = [[timeArray valueForKeyPath:@"@min.doubleValue"] doubleValue];

            NSString *finalPingText = weakSelf.udpResultTextArray.lastObject;
            if (finalPingText) {
                NSArray *finalPingTextArray = [finalPingText componentsSeparatedByString:@" , "];
                if (finalPingTextArray && finalPingTextArray.count == 4) {
                    NSString *packets = [finalPingTextArray[0] stringByReplacingOccurrencesOfString:@" packets transmitted" withString:@""];
                    NSString *delay = [finalPingTextArray[2] stringByReplacingOccurrencesOfString:@"delay:" withString:@""];
                    NSString *loss = [finalPingTextArray[1] stringByReplacingOccurrencesOfString:@"loss:" withString:@""];
                    NSString *text1 = [NSString stringWithFormat:@"发包数：%@\n", packets];
                    NSString *text2 = [NSString stringWithFormat:@"平均时延：%@\n", delay];
                    NSString *text3 = [NSString stringWithFormat:@"最高时延：%.3fms\n", maxTime];
                    NSString *text4 = [NSString stringWithFormat:@"最低时延：%.3fms\n", minTime];
                    NSString *text5 = [NSString stringWithFormat:@"丢包次数：%lu\n", (unsigned long)lossPacketArray.count];
                    NSString *text6 = [NSString stringWithFormat:@"丢包率：%@%%\n", loss];

                    NSMutableArray *timeNumberArray = [NSMutableArray arrayWithCapacity:0];
                    for (NSString *t in timeArray) {
                        double n = [t doubleValue];
                        [timeNumberArray addObject:[NSNumber numberWithDouble:n]];
                    }

                    MSLPhoneNetManager *phoneNetManager = [MSLPhoneNetManager shareInstance];

                    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                    params[@"networkType"] = phoneNetManager.netGetNetworkInfo.deviceNetInfo.netType;
                    params[@"totalPacketCount"] = [NSNumber numberWithInteger:[packets integerValue]];
                    params[@"allDelayMillis"] = timeNumberArray;
                    params[@"averageDelayMillis"] = [NSNumber numberWithDouble:[[delay stringByReplacingOccurrencesOfString:@"ms" withString:@""] doubleValue]];
                    params[@"maxDelayMillis"] = [NSNumber numberWithDouble:maxTime];
                    params[@"minDelayMillis"] = [NSNumber numberWithDouble:minTime];
                    params[@"droppedPacketCount"] = [NSNumber numberWithInteger:lossPacketArray.count];
                    params[@"droppedPacketRatio"] = [NSNumber numberWithDouble:[loss doubleValue]];
                    
                    NSString *tracertResult = [NSString stringWithFormat:@"%@%@%@%@%@%@", text1, text2, text3, text4, text5, text6];
                    params[@"tracertResult"] = @[tracertResult];
                    
                    weakSelf.lastTracertResult = tracertResult;

                    NSLog(@"udp params:%@", params);

                    [weakSelf uploadTestResult:@"UDP" port:weakSelf.testPort duration:weakSelf.testDuration testParams:params completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                        weakSelf.udpIndex = 0;
                        weakSelf.udpLoss = 0;
                        [weakSelf.udpResultTextArray removeAllObjects];
                    }];
                }
            } else {
                weakSelf.udpIndex = 0;
                weakSelf.udpLoss = 0;
                [weakSelf.udpResultTextArray removeAllObjects];
            }
        } else {
            NSLog(@"\nUdpResultTextArray Empty\n");
            [weakSelf.udpResultTextArray removeAllObjects];
        }
    });
}

- (void)ping:(NSUInteger)count state:(NSString *)state complete:(NetPingResultHandler _Nonnull)complete {
    self.businessState = state;
    [[PhonePingService shareInstance] startPingHost:self.testHost packetCount:count resultHandler:^(NSString *_Nullable pingres) {
        [self.pingResultTextArray addObject:pingres];
        if (complete) {
            complete(pingres);
        }
    }];
}

- (void)stopPing {
    if ([[PhonePingService shareInstance] uIsPing]) {
        [[PhonePingService shareInstance] uStopPing];
    }

    NSLog(@"\nPingResultTextArray Count:%lu\n", (unsigned long)_pingResultTextArray.count);

    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self formatPingResultText];
    });
}

- (void)tcpPing:(NSUInteger)count state:(NSString *)state complete:(MSLPNTcpPingHandler _Nonnull)complete {
    self.businessState = state;
    NSInteger port = [self.testPort integerValue];
    _tcpPing = [MSLPNTcpPing start:self.testHost port:port count:count complete:^(NSMutableString *result) {
        [self.tcpPingResultTextArray addObject:result];
        complete(result);
    }];
}

- (void)stopTcpPing {
    if (_tcpPing) {
        [_tcpPing stopTcpPing];
    }

    NSLog(@"\nTcpPingResultTextArray Count:%lu\n", (unsigned long)_tcpPingResultTextArray.count);

    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self formatTcpPingResultText];
    });
}

- (void)httpDownloadFile:(NSString *)fileUrl state:(NSString *)state progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    self.businessState = state;

    if (_speedUpUtils == nil) {
        _speedUpUtils = [[SpeedUpUtils alloc] init];
    }

    _downloadTask = [_speedUpUtils downloadFile:fileUrl progress:downloadProgressBlock completionHandler:completionHandler];
}

- (void)stopHttpDownloadFile {
    if (_downloadTask) {
        [_downloadTask cancel];
    }
}

- (void)udpTest:(id<MSLGCDAsyncUdpSocketDelegate>)aDelegate state:(NSString *)state {
    NSInteger port = [self.testPort integerValue];
    _udpStartDate = [NSDate date];
    _updDelegate = aDelegate;

    self.businessState = state;

    if (_udpSocket == nil) {
        _udpSocket = [[MSLGCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

        NSError *error = nil;

        [_udpSocket bindToPort:port error:&error];
        if (error) {//监听错误打印错误信息
            NSLog(@"error:%@", error);
        } else {//监听成功则开始接收信息
            [_udpSocket beginReceiving:&error];
        }
    }

    [_udpSocket sendData:[@"test" dataUsingEncoding:NSUTF8StringEncoding] toHost:_testHost port:port withTimeout:-1 tag:0];
}

- (void)stopUdpTest {
    [_udpSocket pauseReceiving];
    NSLog(@"\nUdpResultTextArray Count:%lu\n", (unsigned long)_udpResultTextArray.count);
    [self formatUdpResultText];
}

- (void)trace:(TracerouteStepCallback)stepCallback finish:(TracerouteFinishCallback)finish {
    _traceroute = [Traceroute startTracerouteWithHost:_testHost port:_testPort queue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0) stepCallback:stepCallback finish:finish];
}

- (void)stopTrace {
    _traceroute.maxTtl = 0;
}

- (void)uploadTestResult:(NSString *_Nonnull)method port:(NSString *)port duration:(NSString *)duration testParams:(NSDictionary *)testPrarms completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler {
    if (_speedUpUtils) {
        DeviceInfoModel *infoModel = [DeviceInfoModel shared];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"appId"] = self.appId;
        params[@"duration"] = duration;
        params[@"ispId"] = infoModel.areaInfo.ispId;
//        params[@"latitude"] = infoModel.latitude;
//        params[@"longitude"] = infoModel.longitude;
        params[@"msgId"] = [MSLTools uuidString];
        params[@"privateIp"] = infoModel.intranetIP;
        params[@"publicIp"] = infoModel.publicIP;
        params[@"serverPort"] = port;
        params[@"testMethod"] = method;
        params[@"userId"] = self.userId;
        params[@"businessId"] = self.businessId;
        params[@"businessState"] = self.businessState;
        [params addEntriesFromDictionary:testPrarms];

        [_speedUpUtils doRequest:tracertReportUrl method:@"POST" paramsDic:params completionHandler:completionHandler];
    }
}

- (void) qosReport:(NSString *)partnerId
           reqType:(NSString *)reqType
            reqUrl:(NSString *)reqUrl
            mobile:(NSString *)mobile
          publicip:(NSString *)publicip
         privateip:(NSString *)privateip
          areacode:(NSString *)areacode
          response:(NSURLResponse *_Nullable)response
    responseObject:(id _Nullable)responseObject
             error:(NSError *_Nullable)error {
    NSDictionary *resultDic = responseObject;

    NSString *result = @"";
    NSString *msg = @"";
    SpeedUpCancelTecentGamesQoSModel *model = nil;

    if (resultDic) {
        model = [[SpeedUpCancelTecentGamesQoSModel alloc] initWithDictionary:resultDic error:nil];
    }

    if (model && model.ResultCode) {
        result = model.ResultCode;
    }

    if (model && model.ResultMessage) {
        msg = model.ResultMessage;
    }

    if (error != nil) {
        msg = error.description;
    }

    // 构建qosReport参数
    NSDictionary *qosParamsDic = @{ @"userid": partnerId,
                                    @"reqType": reqType,
                                    @"reqUrl": reqUrl,
                                    @"mobile": mobile,
                                    @"terminal": @"iOS",
                                    @"publicip": publicip,
                                    @"privateip": privateip,
                                    @"areacode": areacode,
                                    @"result": result,
                                    @"msg": msg };

    [_speedUpUtils doRequest:qosReportUrl method:@"POST" paramsDic:qosParamsDic completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"response: %@ responseObject: %@", response, responseObject);
        }
    }];
}

- (void)  speedUp:(NSString *_Nonnull)partnerId
        serviceId:(NSString *_Nonnull)serviceId
    destAddresses:(NSArray *_Nonnull)destAddresses
    qosSreamSpeed:(QosSreamSpeed *_Nonnull)qosSreamSpeed
       intranetIp:(NSString *_Nonnull)intranetIp
         publicIp:(NSString *_Nonnull)publicIp
            ispId:(NSString *_Nonnull)ispId
         areaCode:(NSString *_Nonnull)areaCode
           mobile:(NSString *_Nonnull)mobile
              res:(nullable void (^)(SpeedUpApplyTecentGamesQoSModel *qoModel))res {
    MSLPhoneNetManager *phoneNetManager = [MSLPhoneNetManager shareInstance];
    if ([phoneNetManager.netGetNetworkInfo.deviceNetInfo.netType isEqualToString:@"WIFI"]) {
        SpeedUpApplyTecentGamesQoSModel *model = [[SpeedUpApplyTecentGamesQoSModel alloc] init];
        model.ResultCode = @"-994";
        model.ResultMessage = @"WIFI环境不支持加速";
        res(model);
    } else if ([ispId integerValue] <= 0) {
        SpeedUpApplyTecentGamesQoSModel *model = [[SpeedUpApplyTecentGamesQoSModel alloc] init];
        model.ResultCode = @"0";
        model.ResultMessage = @"网络运营商不支持4G加速";
        res(model);
    } else if ([ispId isEqualToString:@"1"] && [areaCode isEqualToString:@"440000"]) {
        WeakSelf;

        // 广东移动 Token
        NSString *url = _speedUpUtils.areaInfoModel ? _speedUpUtils.areaInfoModel.guangdongTokenUrl : @"";
        NSString *decryptUrl = [NSString decryptData:url key:kVPNDecrypt_KEY];
        NSLog(@"decryptUrl = %@", decryptUrl);

        [_speedUpUtils getToken:decryptUrl res:^(NSString *_Nonnull token, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
            [weakSelf qosReport:partnerId reqType:@"token" reqUrl:url mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];

            [weakSelf.speedUpUtils applyTecentGamesQoS:partnerId
                                             serviceId:serviceId
                                         destAddresses:destAddresses
                                         qosSreamSpeed:qosSreamSpeed
                                            intranetIp:intranetIp
                                              publicIp:publicIp
                                                 token:token
                                   applyTecentGamesQoS:^(SpeedUpApplyTecentGamesQoSModel *_Nullable model, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
                                       [weakSelf qosReport:partnerId reqType:@"qosapply" reqUrl:applyUrl mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];
                                       res(model);
                                   }];
        }];
    } else if ([ispId isEqualToString:@"2"]) {
        WeakSelf;

        // 电信 Token
        NSString *url = _speedUpUtils.areaInfoModel ? _speedUpUtils.areaInfoModel.tokenUrl : @"";
        NSString *decryptUrl = [NSString decryptData:url key:kVPNDecrypt_KEY];
        NSLog(@"decryptUrl = %@", decryptUrl);

        [_speedUpUtils getToken:decryptUrl res:^(NSString *_Nonnull token, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
            [weakSelf qosReport:partnerId reqType:@"token" reqUrl:url mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];

            [weakSelf.speedUpUtils applyTecentGamesQoS:partnerId
                                             serviceId:serviceId
                                         destAddresses:destAddresses
                                         qosSreamSpeed:qosSreamSpeed
                                            intranetIp:intranetIp
                                              publicIp:publicIp
                                                 token:token
                                   applyTecentGamesQoS:^(SpeedUpApplyTecentGamesQoSModel *_Nullable model, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
                                       [weakSelf qosReport:partnerId reqType:@"qosapply" reqUrl:applyUrl mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];
                                       res(model);
                                   }];
        }];
    } else {
        WeakSelf;

        // 直接调用加速
        [_speedUpUtils applyTecentGamesQoS:partnerId
                                 serviceId:serviceId
                             destAddresses:destAddresses
                             qosSreamSpeed:qosSreamSpeed
                                intranetIp:intranetIp
                                  publicIp:publicIp
                                     token:@""
                       applyTecentGamesQoS:^(SpeedUpApplyTecentGamesQoSModel *_Nullable model, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
                           [weakSelf qosReport:partnerId reqType:@"qosapply" reqUrl:applyUrl mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];
                           res(model);
                       }];
    }
}

- (void)cancalSpeedUp:(NSString *_Nonnull)correlationId
            partnerId:(NSString *_Nonnull)partnerId
           intranetIp:(NSString *_Nonnull)intranetIp
             publicIp:(NSString *_Nonnull)publicIp
             areaCode:(NSString *_Nonnull)areaCode
               mobile:(NSString *_Nonnull)mobile
                  res:(nullable void (^)(SpeedUpCancelTecentGamesQoSModel *qoModel))res
{
    if (_speedUpUtils) {
        WeakSelf;
        // 取消加速
        [_speedUpUtils cancelTecentGamesQoS:correlationId
                                  partnerId:partnerId
                                   publicIp:publicIp
                       cancelTecentGamesQoS:^(SpeedUpCancelTecentGamesQoSModel *_Nullable model, NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error) {
                           [weakSelf qosReport:partnerId reqType:@"qosremove" reqUrl:cancelUrl mobile:mobile publicip:publicIp privateip:intranetIp areacode:areaCode response:response responseObject:responseObject error:error];
                           res(model);
                       }];
    }
}

- (NSString *)getLastTracertResult {
    return _lastTracertResult;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(MSLGCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    if (_updDelegate) {
        [_updDelegate udpSocket:sock didConnectToAddress:address];
    }
}

- (void)udpSocket:(MSLGCDAsyncUdpSocket *)sock didNotConnect:(NSError *_Nullable)error {
    if (_updDelegate) {
        [_updDelegate udpSocket:sock didNotConnect:error];
    }
}

- (void)udpSocket:(MSLGCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送信息成功");

    NSTimeInterval d1 = [_udpStartDate timeIntervalSince1970] * 1000;
    NSTimeInterval d2 = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval dateDelay = d2 - d1;

    NSString *udpDelay = [NSString stringWithFormat:@"%.3f", dateDelay];

    NSInteger count = [self.testDuration integerValue];
    if (_udpIndex == count) {
        _udpTestString = [NSString stringWithFormat:@"%ld packets transmitted , loss:%ld , delay:%@ms , ttl:0", (long)count, (long)_udpLoss, udpDelay];
    } else {
        _udpTestString = [NSString stringWithFormat:@"64 bytes form 120.52.72.43: icmp_seq=0 ttl=0 time=%@ms", udpDelay];
    }

    [self.udpResultTextArray addObject:_udpTestString];
    _udpIndex++;
    NSLog(@"\nUdpResultTextArray:%@\n", self.udpResultTextArray);

    if (_updDelegate) {
        [_updDelegate udpSocket:sock didSendDataWithTag:tag];
    }
}

- (void)udpSocket:(MSLGCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *_Nullable)error {
    _udpLoss++;
    NSLog(@"发送信息失败");

    if (_updDelegate) {
        [_updDelegate udpSocket:sock didNotSendDataWithTag:tag dueToError:error];
    }
}

- (void)    udpSocket:(MSLGCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
          fromAddress:(NSData *)address
    withFilterContext:(nullable id)filterContext {
    NSLog(@"接收到%@的消息:%@", address, data);

    if (_updDelegate) {
        [_updDelegate udpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
    }
}

- (void)udpSocketDidClose:(MSLGCDAsyncUdpSocket *)sock withError:(NSError *_Nullable)error {
    if (_updDelegate) {
        [_updDelegate udpSocketDidClose:sock withError:error];
    }
}

@end
