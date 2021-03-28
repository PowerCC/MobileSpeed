//
//  SpeedUpUtils.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/26.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "SpeedUpUtils.h"
#import "Marco.h"
#import "MSLAFNetworking.h"
#import "MSLTools.h"

@implementation SpeedUpUtils

- (void)request:(NSString *)urlString method:(NSString *)method parameters:(nullable id)parameters completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    MSLAFURLSessionManager *manager = [[MSLAFURLSessionManager alloc] initWithSessionConfiguration:configuration];

//    if ([method isEqualToString:@"GET"]) {
//        MSLAFHTTPResponseSerializer *responseSerializer = (MSLAFHTTPResponseSerializer *)manager.responseSerializer;
//        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain" "text/html", @"application/octet-stream", @"application/json", @"text/json", nil];
//        manager.responseSerializer = responseSerializer;
//    }

    NSURLRequest *request = [[MSLAFJSONRequestSerializer serializer] requestWithMethod:method URLString:urlString parameters:parameters error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
    [dataTask resume];
}

- (NSURLSessionDownloadTask *)downloadFile:(NSString *)fileUrl progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    MSLAFURLSessionManager *manager = [[MSLAFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:completionHandler];
    [downloadTask resume];
    return downloadTask;
}

- (void)getToken:(NSString *)urlString res:(nullable void (^)(NSString *token, NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))res {
    [self request:urlString method:@"GET" parameters:nil completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            res(nil, nil, nil, nil);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            SpeedUpTokenModel *model = [[SpeedUpTokenModel alloc] initWithDictionary:responseObject error:nil];
            res(model.result, response, responseObject, error);
        }
    }];
}

- (void)getAreaInfo:(AreaInfo)areaInfo {
    WeakSelf;
    [self request:getAreaInfoUrl method:@"POST" parameters:nil completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            areaInfo(nil, response, responseObject, error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            SpeedUpAreaInfoModel *model = [[SpeedUpAreaInfoModel alloc] initWithDictionary:responseObject error:nil];
            weakSelf.areaInfoModel = model;
            areaInfo(model, response, responseObject, error);
        }
    }];
}

- (void)applyTecentGamesQoS:(NSString *_Nullable)partnerId
                  serviceId:(NSString *_Nullable)serviceId
              destAddresses:(NSArray *_Nullable)destAddresses
              qosSreamSpeed:(QosSreamSpeed *_Nullable)qosSreamSpeed
                 intranetIp:(NSString *_Nullable)intranetIp
                   publicIp:(NSString *_Nullable)publicIp
                      token:(NSString *_Nullable)token
        applyTecentGamesQoS:(ApplyTecentGamesQoS)applyTecentGamesQoS {
    if (partnerId == nil ||
        serviceId == nil ||
        destAddresses == nil ||
        destAddresses.count == 0 ||
        qosSreamSpeed == nil ||
        intranetIp == nil ||
        publicIp == nil ||
        token == nil) {
        if (applyTecentGamesQoS != nil) {
            applyTecentGamesQoS(nil, nil, nil, nil);
        }
        return;
    }

    NSMutableArray *ipDics = [[NSMutableArray alloc] init];

    for (NSString *ip in destAddresses) {
        NSString *destinationIpAddress = ip;
        NSString *destinationPort = @"";

        if ([ip containsString:@":"]) {
            NSArray *ipstrArray = [ip componentsSeparatedByString:@":"];
            if (ipstrArray != nil && [ipstrArray count] == 2) {
                destinationIpAddress = ipstrArray[0];
                destinationPort = ipstrArray[1];
            }
        }

        NSDictionary *ipDic = @{ @"DestinationIpAddress": destinationIpAddress,
                                 @"DestinationPort": destinationPort,
                                 @"Direction": @"2",
                                 @"MaximumDownStreamSpeedRate": [NSString stringWithFormat:@"%lu", (unsigned long)qosSreamSpeed.maxDown],
                                 @"MaximumUpStreamSpeedRate": [NSString stringWithFormat:@"%lu", (unsigned long)qosSreamSpeed.maxUp],
                                 @"Protocol": @"ip",
                                 @"SourceIpAddress": intranetIp };

        [ipDics addObject:ipDic];
    }

    NSDictionary *resourceFeaturePropertiesDic = @{ @"FlowProperties": ipDics,
                                                    @"MinimumDownStreamSpeedRate":  [NSString stringWithFormat:@"%lu", (unsigned long)qosSreamSpeed.minDown],
                                                    @"MinimumUpStreamSpeedRate":  [NSString stringWithFormat:@"%lu", (unsigned long)qosSreamSpeed.minUp],
                                                    @"Priority": @"15",
                                                    @"Type": @"2" };

    NSDictionary *userIdentifierDic = @{ @"IP": intranetIp,
                                         @"PublicIP": publicIp };

    NSDictionary *paramsDic = @{ @"Duration": self.areaInfoModel ? self.areaInfoModel.duration : @"3450",
                                 @"OTTchargingId": @"a1234567890",
                                 @"Partner_ID": partnerId,
                                 @"ResourceFeatureProperties": @[resourceFeaturePropertiesDic],
                                 @"ServiceId": serviceId,
                                 @"UserIdentifier": userIdentifierDic,
                                 @"security_token": token };
    NSLog(@"请求参数：%@", paramsDic);
    [self request:applyUrl method:@"POST" parameters:paramsDic completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error) {
        SpeedUpApplyTecentGamesQoSModel *model = [[SpeedUpApplyTecentGamesQoSModel alloc] init];

        if (error) {
            NSLog(@"Error: %@", error);
            model.ResultCode = [NSString stringWithFormat:@"%ld", (long)error.code];
            model.ResultMessage = error.description;
        } else {
            NSLog(@"response: %@ responseObject: %@", response, responseObject);
            model.ResultCode = responseObject[@"ResultCode"];
            model.ResultMessage = responseObject[@"ResultMessage"];

            if ([model.ResultCode integerValue] == 0) {
                model.CorrelationId = responseObject[@"CorrelationId"];
                [MSLTools saveToUserDefaults:SP_KEY_CORRELATION_ID value:model.CorrelationId];
            } else if ([model.ResultCode integerValue] == 203) {
                NSString *correlationId = [MSLTools loadStringFromUserDefaults:SP_KEY_CORRELATION_ID];
                if (correlationId && correlationId.length > 0) {
                    model.CorrelationId = correlationId;
                }
            }
        }

        NSLog(@"SpeedUpApplyTecentGamesQoSModel: %@", model);
        if (applyTecentGamesQoS != nil) {
            applyTecentGamesQoS(model, response, responseObject, error);
        }
    }];
}

- (void)cancelTecentGamesQoS:(NSString *_Nullable)correlationId
                   partnerId:(NSString *_Nullable)partnerId
                    publicIp:(NSString *_Nullable)publicIp
        cancelTecentGamesQoS:(CancelTecentGamesQoS)cancelTecentGamesQoS {
    if (correlationId == nil || partnerId == nil || publicIp == nil) {
        if (cancelTecentGamesQoS != nil) {
            cancelTecentGamesQoS(nil, nil, nil, nil);
        }
        return;
    }

    NSDictionary *paramsDic = @{ @"correlationId": correlationId, @"Partner_ID": partnerId, @"PublicIP": publicIp };
    [self request:cancelUrl method:@"GET" parameters:paramsDic completionHandler:^(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error) {
        SpeedUpCancelTecentGamesQoSModel *model = [[SpeedUpCancelTecentGamesQoSModel alloc] init];

        if (error) {
            NSLog(@"Error: %@", error);
            model.ResultCode = [NSString stringWithFormat:@"%ld", (long)error.code];
            model.ResultMessage = error.description;
        } else {
            NSLog(@"response: %@ responseObject: %@", response, responseObject);
            model.ResultCode = responseObject[@"ResultCode"];
            model.ResultMessage = responseObject[@"ResultMessage"];
        }

        if ([model.ResultCode integerValue] == 0 || [model.ResultCode integerValue] == 201) {
            [MSLTools saveToUserDefaults:SP_KEY_CORRELATION_ID value:@""];
        }

        NSLog(@"SpeedUpCancelTecentGamesQoSModel: %@", model);
        if (cancelTecentGamesQoS != nil) {
            cancelTecentGamesQoS(model, response, responseObject, error);
        }
    }];
}

- (void)doRequest:(NSString *)urlString method:(NSString *)method paramsDic:(NSDictionary *)paramsDic completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError *_Nullable error))completionHandler {
    if (paramsDic && paramsDic.count > 0) {
        [self request:urlString method:method parameters:paramsDic completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
            NSLog(@"%@ %@", response, responseObject);
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
            }

            completionHandler(response, responseObject, error);
        }];
    }
}

@end
