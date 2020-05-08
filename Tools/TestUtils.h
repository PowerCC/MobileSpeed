//
//  TestUtils.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PhoneNetSDK/PhoneNetSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PingResultHandler)(NSString *_Nullable pingres, BOOL doingPing);

@interface TestUtils : NSObject
+ (PNTcpPing *)tcpPing:(NSString * _Nonnull)host port:(NSUInteger)port count:(NSUInteger)count complete:(PNTcpPingHandler _Nonnull)complete;
    
+ (void)ping:(NSString *_Nonnull)host packetCount:(int)count pingResultHandler:(PingResultHandler _Nonnull)handler;

+ (void)stopPing;

+ (PNUdpTraceroute *)udpTraceroute:(NSString * _Nonnull)host complete:(PNUdpTracerouteHandler _Nonnull)complete;

+ (void)icmpTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(NetTracerouteResultHandler _Nonnull)handler;

+ (void)stopIcmpTraceroute;
@end

NS_ASSUME_NONNULL_END
