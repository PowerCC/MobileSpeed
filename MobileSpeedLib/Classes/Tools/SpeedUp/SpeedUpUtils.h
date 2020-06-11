//
//  SpeedUpUtils.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/26.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeedUpModels.h"
#import "QosSreamSpeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpeedUpUtils : NSObject

@property (assign, nonatomic) BOOL isPrepare;

typedef void (^AreaInfo)(SpeedUpAreaInfoModel *_Nullable model);
typedef void (^ApplyTecentGamesQoS)(SpeedUpApplyTecentGamesQoSModel *_Nullable model);
typedef void (^CancelTecentGamesQoS)(SpeedUpCancelTecentGamesQoSModel *_Nullable model);

- (void)request:(NSString *)urlString method:(NSString *)method parameters:(nullable id)parameters completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler;

- (NSURLSessionDownloadTask *)downloadFile:(NSString *)fileUrl progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

- (void)getToken:(NSString *)urlString res:(nullable void (^)(NSString *token))res;

- (void)getAreaInfo:(AreaInfo)areaInfo;

- (void)applyTecentGamesQoS:(NSString *_Nullable)partnerId
                  serviceId:(NSString *_Nullable)serviceId
              destAddresses:(NSArray *_Nullable)destAddresses
              qosSreamSpeed:(QosSreamSpeed *_Nullable)QosSreamSpeed
                 intranetIp:(NSString *_Nullable)intranetIp
                   publicIp:(NSString *_Nullable)publicIp
        applyTecentGamesQoS:(ApplyTecentGamesQoS)applyTecentGamesQoS
                      token:(NSString *_Nullable)token;

- (void)cancelTecentGamesQoS:(NSString *_Nullable)correlationId
                   partnerId:(NSString *_Nullable)partnerId
                    publicIp:(NSString *_Nullable)publicIp
        cancelTecentGamesQoS:(CancelTecentGamesQoS)cancelTecentGamesQoS;

- (void)tracertReport:(NSDictionary *)paramsDic completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
