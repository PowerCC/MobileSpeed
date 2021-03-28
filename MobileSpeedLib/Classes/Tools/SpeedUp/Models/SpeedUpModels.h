//
//  SpeedUpModels.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/26.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSLJSONModel.h"
#import "Marco.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpeedUpTokenModel : MSLJSONModel
@property (copy, nonatomic) NSString *result;
@end

@interface SpeedUpAreaInfoModel : MSLJSONModel
@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *countryName;
@property (copy, nonatomic) NSString *detectServer;
@property (copy, nonatomic) NSString *duration;
@property (copy, nonatomic) NSString *guangdongTokenUrl;
@property (copy, nonatomic) NSString *ip;
@property (copy, nonatomic) NSString *ispId;
@property (copy, nonatomic) NSString *regionName;
@property (copy, nonatomic) NSString *rules;
@property (copy, nonatomic) NSString *server;
@property (copy, nonatomic) NSString *tokenUrl;
@end

@interface SpeedUpApplyTecentGamesQoSModel : MSLJSONModel
@property (copy, nonatomic) NSString *CorrelationId;
@property (copy, nonatomic) NSString *ResultCode;
@property (copy, nonatomic) NSString *ResultMessage;
@end

@interface SpeedUpCancelTecentGamesQoSModel : MSLJSONModel
@property (copy, nonatomic) NSString *ResultCode;
@property (copy, nonatomic) NSString *ResultMessage;
@end

NS_ASSUME_NONNULL_END
