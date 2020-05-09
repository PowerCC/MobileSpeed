//
//  Tools.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/26.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (void)showPrompt:(NSString *)text superView:(UIView *)superView numberOfLines:(NSInteger)numberOfLines afterDelay:(NSTimeInterval)afterDelay completion:(MBProgressHUDCompletionBlock)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (text != nil) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
            hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = text;
            hud.label.numberOfLines = numberOfLines;
            hud.label.textColor = [UIColor whiteColor];
            hud.label.font = [UIFont systemFontOfSize:14];
            hud.offset = CGPointMake(0.0, (superView.frame.size.height - hud.frame.size.height) / 2.0);
            [hud hideAnimated:YES afterDelay:afterDelay];
            hud.completionBlock = completion;
        }
    });
}

+ (NSDictionary *)convert2DictionaryWithJSONString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        NSLog(@"%@", err);
        return nil;
    }
    return dic;
}

+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:nil error:&parseError];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (void)saveToUserDefaults:(NSString *)key value:(id)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

+ (NSString *)loadStringFromUserDefaults:(NSString *)key {
    if (key && key.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *text = [defaults objectForKey:key];
        return text;
    }
    return nil;
}

+ (id)loadObjectFromUserDefaults:(NSString *)key {
    if (key && key.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults objectForKey:key];
    }
    return nil;
}

@end
