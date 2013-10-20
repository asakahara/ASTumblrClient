//
//  SettingInfo.h
//  ASTumblrClient
//
//  Created by sakahara on 2013/10/20.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingInfo : NSObject

@property (nonatomic, strong) NSString *tumblrAuthToken;
@property (nonatomic, strong) NSString *tumblrAuthTokenSecret;

+ (SettingInfo *)sharedInstance;
- (void)load;
- (void)save;

@end
