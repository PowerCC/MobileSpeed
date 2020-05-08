//
//  TestUtils.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "TestUtils.h"

@implementation TestUtils

+ (PNTcpPing *)tcpPing:(NSString * _Nonnull)host port:(NSUInteger)port count:(NSUInteger)count complete:(PNTcpPingHandler _Nonnull)complete {
    return [PNTcpPing start:host port:port count:count complete:complete];
}

+ (void)ping:(NSString *_Nonnull)host packetCount:(int)count pingResultHandler:(PingResultHandler _Nonnull)handler {
    [[PhoneNetManager shareInstance] netStartPing:host packetCount:count pingResultHandler:^(NSString * _Nullable pingres) {
        handler(pingres, [PhoneNetManager shareInstance].isDoingPing);
    }];
}

+ (void)stopPing {
    [[PhoneNetManager shareInstance] netStopPing];
}

+ (PNUdpTraceroute *)udpTraceroute:(NSString * _Nonnull)host complete:(PNUdpTracerouteHandler _Nonnull)complete {
    return [PNUdpTraceroute start:host complete:complete];
}

+ (void)icmpTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(NetTracerouteResultHandler _Nonnull)handler {
    [[PhoneNetManager shareInstance] netStartTraceroute:host tracerouteResultHandler:handler];
}

+ (void)stopIcmpTraceroute {
    [[PhoneNetManager shareInstance] netStopTraceroute];
}
@end
