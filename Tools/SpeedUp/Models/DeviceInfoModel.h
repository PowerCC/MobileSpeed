//
//  DeviceInfoModel.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/5/8.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoModel : NSObject

@property (copy, nonatomic) NSString *osVer;
@property (copy, nonatomic) NSString *phoneModel;
@property (copy, nonatomic) NSString *mobileNetworkStandard;
@property (copy, nonatomic) NSString *uuid;
@property (copy, nonatomic) NSString *extranetIP;
@property (copy, nonatomic) NSString *intranetIP;
@property (copy, nonatomic) NSString *cityCode;
@property (copy, nonatomic) NSString *latitude;
@property (copy, nonatomic) NSString *longitude;
@property (copy, nonatomic) NSString *location;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
