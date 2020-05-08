//
//  AppDelegate.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/22.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

    return YES;
}

@end
