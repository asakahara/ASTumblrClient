//
//  ASDateUtils.m
//  ASTwitterClient
//
//  Created by sakahara on 2013/10/05.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASDateUtil.h"

@implementation ASDateUtil

+ (NSString *)parseDate:(NSString *)dateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    // 2013-07-25 13:35:19 GMT
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date = [df dateFromString:dateString];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    return [df stringFromDate:date];
}

@end
