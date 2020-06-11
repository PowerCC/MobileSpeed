//
//  QosSreamSpeed.m
//  MobileSpeedLib
//
//  Created by 邹程 on 2020/6/5.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "QosSreamSpeed.h"

@implementation QosSreamSpeed

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minUp = 100000;
        self.minDown = 200000;
        self.maxUp = 50000;
        self.maxDown = 100000;
    }
    return self;
}

- (instancetype)initWithData:(long)minUp minDown:(long)minDown maxUp:(long)maxUp maxDown:(long)maxDown {
    self = [super init];
    if (self) {
        self.minUp = minUp;
        self.minDown = minDown;
        self.maxUp = maxUp;
        self.maxDown = maxDown;
    }
    return self;
}

@end
