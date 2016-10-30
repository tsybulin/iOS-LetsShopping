//
//  Commodity.h
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product, Shoplist;

@interface Commodity : NSManagedObject

@property (nonatomic, retain) NSNumber *num;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic) BOOL shopped ;
@property (nonatomic, retain) Product *product;
@property (nonatomic, retain) Shoplist *shoplist;

@end
