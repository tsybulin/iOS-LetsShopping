//
//  BinaryExportProvider.m
//  goshopping
//
//  Created by Pavel Tsybulin on 28.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import "BinaryExportProvider.h"
#import "ImportHelper.h"

@implementation BinaryExportProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [NSData data] ;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
    return @"com.tsybulin.letsshopping.list" ;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return self.shoplist.name ;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if (!self.shoplist) {
        return nil ;
    }
    
    NSDictionary<NSString *, id> *dict = [[ImportHelper sharedHelper] dictionaryFromList:self.shoplist] ;

    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSString *path = [documentDirectory stringByAppendingPathComponent:[self.shoplist.name stringByAppendingString:@".letsshopping"]] ;
    if (![dict writeToFile:path atomically:YES]) {
        return nil ;
    }

    NSData *data = [NSData dataWithContentsOfFile:path] ;
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil] ;

    return data ;
}

@end
