//
//  Shoplist.h
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Commodity;

@interface Shoplist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * intsort;
@property (nonatomic, retain) NSSet *commodities;
@end

@interface Shoplist (CoreDataGeneratedAccessors)

- (void)addCommoditiesObject:(Commodity *)value;
- (void)removeCommoditiesObject:(Commodity *)value;
- (void)addCommodities:(NSSet *)values;
- (void)removeCommodities:(NSSet *)values;

@end
