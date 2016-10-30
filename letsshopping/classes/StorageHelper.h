//
//  StorageHelper.h
//  goshopping
//
//  Created by Pavel Tsybulin on 15.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Shoplist.h"
#import "Commodity.h"
#import "Product.h"
#import "SharedList.h"

@interface StorageHelper : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext ;

+ (instancetype)sharedHelper ;

- (void)commit ;

- (void)checkLists ;

- (NSFetchedResultsController *)shoplistFetchController ;

- (Shoplist *)addShoplist:(NSString *)name intsort:(NSNumber *)intsort ;

- (void)deleteShoplist:(Shoplist *)shoplist ;

- (Shoplist *)shoplistByName:(NSString *)name ;

- (Shoplist *)shoplistByID:(NSManagedObjectID *)shoplistID ;

- (void)markShoplist:(Shoplist *)shoplist shopped:(BOOL)shopped ;

- (void)clearShoplist:(Shoplist *)shoplist ;

- (void)copyShoplist:(Shoplist *)shoplist withIntsort:(NSNumber *)intsort ;

- (NSFetchedResultsController *)commodityFetchController:(Shoplist *)shoplist ;

- (void)deleteCommodity:(Commodity *)commodity ;

- (NSFetchedResultsController *)productFetchController ;

- (Commodity *)commodityWithProduct:(Product *)product shopList:(Shoplist *)shoplist ;

- (Product *)productByName:(NSString *)name ;

- (Product *)addProduct:(NSString *)name ;

- (void)deleteProduct:(Product *)product ;

- (NSFetchedResultsController *)shopcategoryFetchController ;

- (ShopCategory *)addShopCategory:(NSString *)name intsort:(NSNumber *)intsort color:(NSNumber *)clr ;

- (void)deleteShopcategory:(ShopCategory *)shopcategory ;

- (NSFetchedResultsController *)commoditySharingFetchController:(Shoplist *)shoplist ;

- (void)updateFromWatch:(NSString *)shoplistId element:(NSNumber *)currentElement shopped:(BOOL)shopped ;

- (void)updateFromSharedList:(SharedList *)sharedList ;

@end
