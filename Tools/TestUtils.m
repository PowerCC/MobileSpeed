//
//  TestUtils.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "TestUtils.h"

@interface TestUtils ()

@end

@implementation TestUtils

static TestUtils *testUtils = nil;
+ (instancetype)sharedInstance {
    if (testUtils == nil) {
        testUtils = [[TestUtils alloc]init];
    }
    return testUtils;
}

- (void)ping:(NSString *_Nonnull)host port:(NSUInteger)port count:(NSUInteger)count complete:(PNTcpPingHandler _Nonnull)complete {
    _tcpPing = [PNTcpPing start:host port:port count:count complete:complete];
}

- (void)stopPing {
    if (_tcpPing) {
        [_tcpPing stopTcpPing];
    }
}

- (void)httpDownloadFile:(NSString *)fileUrl progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
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

- (void)udpTest:(NSString *_Nonnull)host port:(uint16_t)port aDelegate:(id<GCDAsyncUdpSocketDelegate>)aDelegate {
    if (_udpSocket == nil) {
        _udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
        
        NSError *error = nil;
        [_udpSocket bindToPort:port error:&error];
        if (error) {//监听错误打印错误信息
            NSLog(@"error:%@", error);
        } else {//监听成功则开始接收信息
            [_udpSocket beginReceiving:&error];
        }
    }

    [_udpSocket sendData:[@"test" dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:port withTimeout:-1 tag:0];
}

- (void)stopUdpTest {
    [_udpSocket pauseReceiving];
}

- (void)trace:(NSString *)host port:(NSString *)port stepCallback:(TracerouteStepCallback)stepCallback finish:(TracerouteFinishCallback)finish {
    _traceroute = [Traceroute startTracerouteWithHost:host port:port queue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0) stepCallback:stepCallback finish:finish];
}

- (void)stopTrace {
    _traceroute.maxTtl = 0;
}

- (void)uploadTestResult:(NSString *)method port:(NSString *)port duration:(NSString *)duration testParams:(NSDictionary *)testPrarms {
    if (_speedUpUtils) {
        DeviceInfoModel *infoModel = [DeviceInfoModel shared];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"appId"] = @"zhongxin";
        params[@"duration"] = duration;
        params[@"ispId"] = infoModel.ispId;
        params[@"latitude"] = infoModel.latitude;
        params[@"longitude"] = infoModel.longitude;
        params[@"msgId"] = [Tools uuidString];
        params[@"privateIp"] = infoModel.intranetIP;
        params[@"publicIp"] = infoModel.extranetIP;
        params[@"serverPort"] = port;
        params[@"testMethod"] = method;
        params[@"userId"] = @"testUserId";
        [params addEntriesFromDictionary:testPrarms];

        [_speedUpUtils tracertReport:params];
    }
}

@end
