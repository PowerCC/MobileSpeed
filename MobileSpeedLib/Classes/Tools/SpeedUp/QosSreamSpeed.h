//
//  QosSreamSpeed.h
//  MobileSpeedLib
//
//  Created by 邹程 on 2020/6/5.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QosSreamSpeed : NSObject

@property (assign, nonatomic) NSUInteger minUp;
@property (assign, nonatomic) NSUInteger minDown;
@property (assign, nonatomic) NSUInteger maxUp;
@property (assign, nonatomic) NSUInteger maxDown;

/**
 上行下行/最小最大带宽设置
 @param minUp 最小上行带宽
 @param minDown 最小下行带宽
 @param maxUp 最大上行带宽
 @param maxDown 最大下行带宽
*/
- (instancetype)initWithData:(long)minUp minDown:(long)minDown maxUp:(long)maxUp maxDown:(long)maxDown;

@end

NS_ASSUME_NONNULL_END
