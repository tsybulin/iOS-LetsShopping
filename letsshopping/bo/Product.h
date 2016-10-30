//
//  Product.h
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Commodity, ShopCategory;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) ShopCategory *shopCategory;
@property (nonatomic, retain) NSSet *commodities;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addCommoditiesObject:(Commodity *)value;
- (void)removeCommoditiesObject:(Commodity *)value;
- (void)addCommodities:(NSSet *)values;
- (void)removeCommodities:(NSSet *)values;

@end
