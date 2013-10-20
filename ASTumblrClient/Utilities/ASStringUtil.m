//
//  ASStringUtil.m
//  ASTumblrClient
//
//  Created by sakahara on 2013/10/20.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASStringUtil.h"

@implementation ASStringUtil

+ (NSString *)removeTag:(NSString *)inputString
{
    NSMutableString *result = nil;
    
    if (inputString) {
        result = [[NSMutableString alloc] initWithString:inputString];
        
        if ([inputString length] > 0) {
            NSRange range;
            
            while ((range = [result rangeOfString:@"<[^>]+>"
                                         options:NSRegularExpressionSearch]).location != NSNotFound) {
                [result deleteCharactersInRange:range];
            }      
        }
    }
    
    return result;
}

@end
