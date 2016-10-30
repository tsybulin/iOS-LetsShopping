//
//  SharedCommodity.h
//  goshopping
//
//  Created by Pavel Tsybulin on 30.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCommodity : NSObject

@property (nonatomic, retain) NSString *productName ;
@property (nonatomic, retain) NSString *categoryName ;
@property (nonatomic, retain) NSNumber *categoryColor ;
@property (nonatomic, retain) NSNumber *amount ;
@property (nonatomic) BOOL shopped ;

- (NSMutableDictionary *)mutableDictionary ;
- (void)fromDictionary:(NSDictionary<NSString *, id> *)dictionary ;

@end
