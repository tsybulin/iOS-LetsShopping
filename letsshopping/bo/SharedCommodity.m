//
//  SharedCommodity.m
//  goshopping
//
//  Created by Pavel Tsybulin on 30.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "SharedCommodity.h"

@implementation SharedCommodity

- (NSMutableDictionary *)mutableDictionary {
    return[NSMutableDictionary dictionaryWithObjectsAndKeys:self.productName, @"productName",
           self.categoryName, @"categoryName",
           self.categoryColor, @"categoryColor",
           self.amount, @"amount",
           [NSNumber numberWithBool:self.shopped], @"shopped",
           nil] ;
}

- (void)fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    self.productName = [dictionary objectForKey:@"productName"] ;
    self.categoryName = [dictionary objectForKey:@"categoryName"] ;
    self.categoryColor = [dictionary objectForKey:@"categoryColor"] ;
    self.amount = [dictionary objectForKey:@"amount"] ;
    self.shopped = [[dictionary objectForKey:@"shopped"] boolValue] ;
}

@end
