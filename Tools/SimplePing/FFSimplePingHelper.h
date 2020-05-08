//
//  FFSimplePingHelper.h
//  SimplePingDemo
//
//  Created by powercc on 2019/2/18.
//  Copyright © 2019年 MoGuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"
#include <netdb.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFSimplePingHelper : NSObject

@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, strong) NSTimer *timer;
/**目标域名的IP地址*/
@property (nonatomic, copy) NSString *iPAddress;
/**开始发送数据的时间*/
@property (nonatomic) NSTimeInterval startTimeInterval;
/**消耗的时间*/
@property (nonatomic) NSTimeInterval delayTime;
/**接收到数据或者丢失的数据的次数*/
@property (nonatomic, assign) NSInteger receivedOrDelayCount;
/**发出的数据包*/
@property (nonatomic) NSUInteger sendPackets;
/**收到的数据包*/
@property (nonatomic) NSUInteger receivePackets;
/**丢包率*/
@property (nonatomic, assign) double packetLoss;

- (instancetype)initWithHostName:(NSString*)hostName;
@property(nonatomic, readonly) NSString *hostName;
- (void)startPing;
- (void)stopPing;

@end

NS_ASSUME_NONNULL_END
