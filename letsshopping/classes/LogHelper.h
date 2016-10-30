//
//  LogHelper.h
//  goshopping
//
//  Created by Pavel Tsybulin on 01.10.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogHelper : NSObject

+ (instancetype)sharedHelper ;
- (void)logMessage:(NSString *)msg ;

@end
