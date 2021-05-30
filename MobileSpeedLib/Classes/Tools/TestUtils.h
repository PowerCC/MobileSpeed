//
//  TestUtils.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "Marco.h"
#import "MSLTools.h"
#import "DeviceUtils.h"
#import "DeviceInfoModel.h"
#import "SpeedUpUtils.h"
#import "Traceroute.h"
#import "SpeedUpModels.h"
#import "QosSreamSpeed.h"
#import "PhoneNetSDK.h"
#import "MSLGCDAsyncUdpSocket.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^DeviceInfoHandler)(DeviceInfoModel *_Nullable infoModel);

@interface TestUtils : NSObject

@property (assign, nonatomic) BOOL pingTesting;
@property (assign, nonatomic) BOOL httpTesting;
@property (assign, nonatomic) BOOL udpTesting;
@property (assign, nonatomic) BOOL traceTesting;

@property (strong, nonatomic) SpeedUpUtils *speedUpUtils;
@property (strong, nonatomic) MSLPNTcpPing *tcpPing;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) MSLGCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) Traceroute *traceroute;

+ (instancetype)getSharedInstance;

/**
 实例
 @param appId App标识
 @param userId 用户标识
 @param businessId businessId
 @param businessState businessState
 */
+ (instancetype)sharedInstance:(NSString *)appId userId:(NSString *)userId businessId:(NSString *)businessId businessState:(NSString *)businessState;

/**
 实例
 @param host 测试网址或IP
 @param port 测试端口号
 @param duration 测试时长
 @param appId App标识
 @param userId 用户标识
 @param businessId businessId
 @param businessState businessState
 */
+ (instancetype)sharedInstance:(NSString *)host port:(NSString *)port duration:(NSString *)duration appId:(NSString *)appId userId:(NSString *)userId businessId:(NSString *)businessId businessState:(NSString *)businessState;

/**
 获取设备信息
 @param infoHandler 设备信息DeviceInfoModel
*/
- (void)getDeviceInfo:(DeviceInfoHandler)infoHandler;

/**
 ping探测
 @param count 测试次数
 @param state 加速状态 1加速前 2加速后
*/
- (void)ping:(NSUInteger)count state:(NSString *)state complete:(NetPingResultHandler _Nonnull)complete;

/**
 停止ping探测
 */
- (void)stopPing;

/**
 tcpping探测
 @param count 测试次数
 @param state 加速状态 1加速前 2加速后
*/
- (void)tcpPing:(NSUInteger)count state:(NSString *)state complete:(MSLPNTcpPingHandler _Nonnull)complete;

/**
 停止tcpping探测
 */
- (void)stopTcpPing;

/**
 http探测（文件下载）
 @param fileUrl 文件地址
 @param state 加速状态 1加速前 2加速后
 @param downloadProgressBlock 下载进度
 @param completionHandler 结果Handler
*/
- (void)httpDownloadFile:(NSString *_Nonnull)fileUrl state:(NSString *)state progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/**
 停止http探测（文件下载）
 */
- (void)stopHttpDownloadFile;

/**
 udp检测
 @param aDelegate GCDAsyncUdpSocketDelegate 代理
 @param state 加速状态 1加速前 2加速后
*/
- (void)udpTest:(id<MSLGCDAsyncUdpSocketDelegate>)aDelegate state:(NSString *)state;

/**
 停止udp探测（文件下载）
*/
- (void)stopUdpTest;

/**
 trace探测
 @param stepCallback Traceroute中每一跳的结果回调
 @param finish Traceroute结束的回调
*/
- (void)trace:(TracerouteStepCallback)stepCallback finish:(TracerouteFinishCallback)finish;

/**
 停止Trace探测
*/
- (void)stopTrace;

/**
 上报探测数据
 @param method 测试方法（PING、HTTP、UDP、TRACE）
 @param port 端口号
 @param duration 持续时间
 @param completionHandler 结果回调
*/
- (void)uploadTestResult:(NSString *_Nonnull)method port:(NSString *)port duration:(NSString *)duration testParams:(NSDictionary *)testPrarms completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler;

/**
 加速
 @param partnerId partnerId
 @param serviceId serviceId
 @param destAddresses IP数组
 @param qosSreamSpeed 上行下行/最小最大带宽
 @param intranetIp 内网IP
 @param publicIp 公网IP
 @param ispId isPId
 @param areaCode 区域码
 @param mobile 手机号
 @param res SpeedUpCancelTecentGamesQoSModel（code，message）
*/
- (void)  speedUp:(NSString *_Nonnull)partnerId
        serviceId:(NSString *_Nonnull)serviceId
    destAddresses:(NSArray *_Nonnull)destAddresses
    qosSreamSpeed:(QosSreamSpeed *_Nonnull)qosSreamSpeed
       intranetIp:(NSString *_Nonnull)intranetIp
         publicIp:(NSString *_Nonnull)publicIp
            ispId:(NSString *_Nonnull)ispId
         areaCode:(NSString *_Nonnull)areaCode
           mobile:(NSString *_Nonnull)mobile
              res:(nullable void (^)(SpeedUpApplyTecentGamesQoSModel *qoModel))res;

/**
 取消加速
 @param correlationId correlationId
 @param partnerId partnerId
 @param intranetIp 内网IP
 @param publicIp 公网IP
 @param areaCode 区域码
 @param mobile 手机号
 @param res SpeedUpCancelTecentGamesQoSModel（code，message）
*/
- (void)cancalSpeedUp:(NSString *_Nonnull)correlationId
            partnerId:(NSString *_Nonnull)partnerId
           intranetIp:(NSString *_Nonnull)intranetIp
             publicIp:(NSString *_Nonnull)publicIp
             areaCode:(NSString *_Nonnull)areaCode
               mobile:(NSString *_Nonnull)mobile
                  res:(nullable void (^)(SpeedUpCancelTecentGamesQoSModel *qoModel))res;

/**
 获取最后一次测速结果
 @return 结果字符串
*/
- (NSString *)getLastTracertResult;

@end
NS_ASSUME_NONNULL_END
