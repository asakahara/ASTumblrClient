//
//  SettingInfo.m
//  ASTumblrClient
//
//  Created by sakahara on 2013/10/20.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "SettingInfo.h"

#define INFO_TUMBLR_AUTH_TOKEN @"INFO_TUMBLR_AUTH_TOKEN"
#define INFO_TUMBLR_AUTH_TOKEN_SECRET @"INFO_TUMBLR_AUTH_TOKEN_SECRET"

@implementation SettingInfo

+ (SettingInfo *)sharedInstance {
	static SettingInfo* _sharedSettingInfo = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSettingInfo = [[SettingInfo alloc] init];
    });
    [_sharedSettingInfo load];
    return _sharedSettingInfo;
}


- (id)init {
	if ((self = [super init]) == nil) {
		return nil;
	}
    
	return self;
}

- (void)load {
	
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    self.tumblrAuthToken = [defaults objectForKey:INFO_TUMBLR_AUTH_TOKEN];
    self.tumblrAuthTokenSecret = [defaults objectForKey:INFO_TUMBLR_AUTH_TOKEN_SECRET];
}

- (void)save {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.tumblrAuthToken forKey:INFO_TUMBLR_AUTH_TOKEN];
    [defaults setObject:self.tumblrAuthTokenSecret forKey:INFO_TUMBLR_AUTH_TOKEN_SECRET];
    
    [defaults synchronize];
}

@end
