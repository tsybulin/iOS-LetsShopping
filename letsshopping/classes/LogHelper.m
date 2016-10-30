//
//  LogHelper.m
//  goshopping
//
//  Created by Pavel Tsybulin on 01.10.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import "LogHelper.h"

@interface LogHelper () {
    NSDateFormatter *dateFormatter ;
}

@end

@implementation LogHelper

- (instancetype)init {
    if (self = [super init]) {
        dateFormatter = [[NSDateFormatter alloc] init] ;
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss" ;
    }

    return self ;
}

+ (instancetype)sharedHelper {
    static LogHelper *sharedInstance = nil ;
    
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[LogHelper alloc] init] ;
        }
    }
    
    return sharedInstance ;
}


- (void)logMessage:(NSString *)msg {
    NSLog(@"%@", msg) ;

    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"letsshopping_log.txt"] ;
    NSData *data = [[NSString stringWithFormat:@"%@ %@\n", [dateFormatter stringFromDate:[NSDate date]], msg] dataUsingEncoding:NSUTF8StringEncoding] ;
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path] ;

    NSError *error = nil ;

    if (!fileHandler) {
        if (![data writeToFile:path options:NSDataWritingFileProtectionNone error:&error]) {
            NSLog(@"LogHelper.logMessage data write error %@", error) ;
        }
        return ;
    }

    [fileHandler seekToEndOfFile] ;
    
    @try {
        [fileHandler writeData:data] ;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception) ;
    } @finally {
        //
    }

}

@end
