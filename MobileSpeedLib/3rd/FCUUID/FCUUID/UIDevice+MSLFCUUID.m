//
//  UIDevice+MSLFCUUID.m
//
//  Created by Fabio Caccamo on 19/11/15.
//  Copyright © 2015 Fabio Caccamo. All rights reserved.
//

#import "UIDevice+MSLFCUUID.h"

@implementation UIDevice (MSLFCUUID)

-(NSString *)uuid
{
    return [MSLFCUUID uuidForDevice];
}

@end
