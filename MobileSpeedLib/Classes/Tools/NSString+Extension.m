//
//  NSString+Extension.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/5/3.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL)match:(NSString *)pattern {
    // 1.创建正则表达式
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    return results.count > 0;
}

+ (NSString *)decryptData:(NSString *)dataStr key:(NSString *)key {
    NSArray *dataArr = [[dataStr substringFromIndex:1] componentsSeparatedByString:@"@"];
    Byte *tmpList = malloc(dataArr.count);

    NSArray *keyArr = [self getByte:key];
    NSInteger keyLen = keyArr.count;
    for (int i = 0; i < dataArr.count; i++) {
        tmpList[i] = (Byte)(([dataArr[i] integerValue]) - (0xFF & [[keyArr objectAtIndex:(i % keyLen)] integerValue]));
    }

    NSData *adata = [[NSData alloc]initWithBytes:tmpList length:dataArr.count];
    NSString *result = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];

    return result;
}

// 字符串转byte数组
+ (NSMutableArray *)getByte:(NSString *)data {
    NSMutableArray *list = @[].mutableCopy;

    NSData *testData = [data dataUsingEncoding:NSUTF8StringEncoding]; //字符串转化成 data
    Byte *testByte = (Byte *)[testData bytes];
    for (int i = 0; i < testData.length; i++) {
        [list addObject:[NSString stringWithFormat:@"%d", 0xFF & testByte[i]]];
    }
    return list;
}

@end
