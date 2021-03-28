//
//  DeviceInfoModel.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/5/8.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeedUpModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoModel : NSObject

/**
 OS版本
 */
@property (copy, nonatomic) NSString *osVer;

/**
 手机型号
*/
@property (copy, nonatomic) NSString *phoneModel;

/**
 移动网络类型
*/
@property (copy, nonatomic) NSString *mobileNetworkStandard;

/**
 UUID
*/
@property (copy, nonatomic) NSString *uuid;

/**
 公网IP
*/
@property (copy, nonatomic) NSString *publicIP;

/**
 内网IP
*/
@property (copy, nonatomic) NSString *intranetIP;

/**
 区域模型
 */
@property (strong, nonatomic) SpeedUpAreaInfoModel *areaInfo;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
