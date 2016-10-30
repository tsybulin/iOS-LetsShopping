//
//  StorageHelper.m
//  goshopping
//
//  Created by Pavel Tsybulin on 15.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "StorageHelper.h"
#import "ShopCategory.h"
#import <UIKit/UIKit.h>
#import "SharedCommodity.h"

@implementation StorageHelper

+ (instancetype)sharedHelper {
    static StorageHelper *sharedInstance = nil ;
    
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[StorageHelper alloc] init] ;
        }
    }
    
    return sharedInstance ;
}

- (NSUInteger)colorFromHex:(NSString *)hex {
    if (hex) {
        NSUInteger i ;
#ifdef __LP64__
        sscanf([hex UTF8String], "#%6lX", &i) ;
#else
        sscanf([hex UTF8String], "#%6X", &i) ;
#endif
        return i ;
    } else {
        return 0 ;
    }
}

- (void)checkLists {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *shoplistEntity = [NSEntityDescription entityForName:@"Shoplist" inManagedObjectContext:self.managedObjectContext] ;
    [fetchRequest setEntity:shoplistEntity] ;
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error] ;
    if (fetchedObjects != nil && fetchedObjects.count == 0) {

        NSError *error = nil ;
        NSDictionary *parsedCatalog = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"json"]] options:0 error:&error] ;

        NSEntityDescription *shopcategoryEntity = [NSEntityDescription entityForName:@"ShopCategory" inManagedObjectContext:self.managedObjectContext] ;
        NSEntityDescription *productEntity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext] ;
        NSEntityDescription *commodityEntity = [NSEntityDescription entityForName:@"Commodity" inManagedObjectContext:self.managedObjectContext] ;

        for (NSDictionary *jShopCategory in [parsedCatalog objectForKey:@"categories"]) {
            ShopCategory *shopcategory = [[ShopCategory alloc] initWithEntity:shopcategoryEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
            shopcategory.name = [jShopCategory objectForKey:@"name"] ;
            shopcategory.clr = [NSNumber numberWithUnsignedInteger:[self colorFromHex:[jShopCategory objectForKey:@"clr"]]]  ;
            shopcategory.intsort = [jShopCategory objectForKey:@"intsort"] ? [jShopCategory objectForKey:@"intsort"] : [NSNumber numberWithInt:1] ;
            
            for (NSDictionary *jProduct in [jShopCategory objectForKey:@"products"]) {
                Product *product = [[Product alloc] initWithEntity:productEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
                product.name = [jProduct objectForKey:@"name"] ;
                product.shopCategory = shopcategory ;
            }
        }
        
        for (NSDictionary *jShoplist in [parsedCatalog objectForKey:@"shoplists"]) {
            Shoplist *shoplist = [[Shoplist alloc] initWithEntity:shoplistEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
            shoplist.name = [jShoplist objectForKey:@"name"] ;
            shoplist.intsort = [jShoplist objectForKey:@"intsort"] ? [jShoplist objectForKey:@"intsort"] : [NSNumber numberWithInt:1] ;

            for (NSDictionary *jCommodity in [jShoplist objectForKey:@"commodities"]) {
                Commodity *commodity = [[Commodity alloc] initWithEntity:commodityEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
                commodity.product = [self productByName:[jCommodity objectForKey:@"name"]] ;
                commodity.amount = [jCommodity objectForKey:@"amount"] ? [jCommodity objectForKey:@"amount"] : [NSNumber numberWithInt:1] ;
                commodity.shoplist = shoplist ;
            }
        }

        [self.managedObjectContext save:nil] ;
    }
}

- (Shoplist *)shoplistByName:(NSString *)name {
    NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"ShoplistByName" substitutionVariables:@{@"NAME": name}] ;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    return [results firstObject] ;
}

- (Product *)productByName:(NSString *)name {
    NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"ProductByName" substitutionVariables:@{@"NAME": name}] ;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    return [results firstObject] ;
}

- (NSFetchedResultsController *)shoplistFetchController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shoplist" inManagedObjectContext:self.managedObjectContext] ;
    [fetchRequest setEntity:entity] ;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intsort" ascending:YES] ;
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]] ;
    fetchRequest.fetchBatchSize = 20 ;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
}

- (Shoplist *)addShoplist:(NSString *)name intsort:(NSNumber *)intsort {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shoplist" inManagedObjectContext:self.managedObjectContext] ;
    Shoplist *shoplist = [[Shoplist alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] ;
    shoplist.name = name ;
    shoplist.intsort = intsort ;
    [self.managedObjectContext save:nil] ;
    return shoplist ;
}

- (void)deleteShoplist:(Shoplist *)shoplist {
    [self.managedObjectContext deleteObject:shoplist] ;
    [self.managedObjectContext save:nil] ;
}

- (void)copyShoplist:(Shoplist *)shoplist withIntsort:(NSNumber *)intsort {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shoplist" inManagedObjectContext:self.managedObjectContext] ;
    Shoplist *newShoplist = [[Shoplist alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] ;
    newShoplist.name = [shoplist.name stringByAppendingString:@" 2"] ;
    newShoplist.intsort = intsort ;

    for (Commodity *commodity in shoplist.commodities) {
        [self commodityWithProduct:commodity.product shopList:newShoplist].amount = commodity.amount ;
    }
    
    [self.managedObjectContext save:nil] ;
}

- (Shoplist *)shoplistByID:(NSManagedObjectID *)shoplistID {
    return (Shoplist *)[self.managedObjectContext objectWithID:shoplistID] ;
}

- (NSFetchedResultsController *)commodityFetchController:(Shoplist *)shoplist {
    NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"CommodityByShoplist" substitutionVariables:@{@"SHOPLIST": shoplist}] ;
    NSSortDescriptor *shoppedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shopped" ascending:YES] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    [fetchRequest setSortDescriptors:@[shoppedSortDescriptor, categorySortDescriptor, productSortDescriptor]] ;
    fetchRequest.includesPendingChanges = YES ;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
}

- (void)deleteCommodity:(Commodity *)commodity {
    [self.managedObjectContext deleteObject:commodity] ;
    [self.managedObjectContext save:nil] ;
}

- (NSFetchedResultsController *)productFetchController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext] ;
    [fetchRequest setEntity:entity] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] ;
    [fetchRequest setSortDescriptors:@[categorySortDescriptor, productSortDescriptor]] ;
    fetchRequest.fetchBatchSize = 20 ;

    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
}

- (Commodity *)commodityWithProduct:(Product *)product shopList:(Shoplist *)shoplist {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Commodity" inManagedObjectContext:self.managedObjectContext] ;
    Commodity *commodity = [[Commodity alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] ;
    commodity.product = product ;
    commodity.shoplist = shoplist ;
    return commodity ;
}

- (void)markShoplist:(Shoplist *)shoplist shopped:(BOOL)shopped {
    for (Commodity *commodity in shoplist.commodities) {
        commodity.shopped = shopped ;
    }
}

- (void)clearShoplist:(Shoplist *)shoplist {
    for (Commodity *commodity in shoplist.commodities) {
        [self.managedObjectContext deleteObject:commodity] ;
    }
}

- (void)commit {
    [self.managedObjectContext save:nil] ;
}

- (NSFetchedResultsController *)shopcategoryFetchController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopCategory" inManagedObjectContext:self.managedObjectContext] ;
    [fetchRequest setEntity:entity] ;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intsort" ascending:YES] ;
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]] ;
    fetchRequest.fetchBatchSize = 20 ;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
}

- (ShopCategory *)addShopCategory:(NSString *)name intsort:(NSNumber *)intsort color:(NSNumber *)clr {
    NSEntityDescription *shopcategoryEntity = [NSEntityDescription entityForName:@"ShopCategory" inManagedObjectContext:self.managedObjectContext] ;
    ShopCategory *shopcategory = [[ShopCategory alloc] initWithEntity:shopcategoryEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
    shopcategory.name = name ;
    shopcategory.clr = clr  ;
    shopcategory.intsort = intsort ;
    return shopcategory ;
}

- (void)deleteShopcategory:(ShopCategory *)shopcategory {
    [self.managedObjectContext deleteObject:shopcategory] ;
    [self.managedObjectContext save:nil] ;
}

- (Product *)addProduct:(NSString *)name {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext] ;
    Product *product = [[Product alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] ;
    product.name = name ;
    return product ;
}

- (void)deleteProduct:(Product *)product {
    [self.managedObjectContext deleteObject:product] ;
    [self.managedObjectContext save:nil] ;
}

- (NSFetchedResultsController *)commoditySharingFetchController:(Shoplist *)shoplist {
    NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"CommodityByShoplist" substitutionVariables:@{@"SHOPLIST": shoplist}] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    [fetchRequest setSortDescriptors:@[categorySortDescriptor, productSortDescriptor]] ;
    fetchRequest.includesPendingChanges = YES ;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
}

- (ShopCategory *)shopCategoryByName:(NSString *)name {
    NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"ShopCategoryByName" substitutionVariables:@{@"NAME": name}] ;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    return [results firstObject] ;
}

- (void)updateFromWatch:(NSString *)shoplistId element:(NSNumber *)currentElement shopped:(BOOL)shopped {
    NSManagedObjectID *shoplistID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:shoplistId]] ;
    if (!shoplistID) {
        NSLog(@"updateFromWatch: managedObject with id %@ not found", shoplistId) ;
        return ;
    }

    Shoplist *shoplist = (Shoplist *)[self.managedObjectContext objectWithID:shoplistID] ;
    if (!shoplist) {
        NSLog(@"updateFromWatch: shopList with id %@ not found", shoplistID) ;
    }

    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    
    NSArray *commodities = [shoplist.commodities sortedArrayUsingDescriptors:@[categorySortDescriptor, productSortDescriptor]] ;
    
    if (currentElement && currentElement.integerValue >= 0 && currentElement.unsignedIntegerValue < commodities.count) {
        Commodity *commodity = [commodities objectAtIndex:currentElement.unsignedIntegerValue] ;
        if (commodity) {
            commodity.shopped = shopped ;
            
            [self commit] ;
        }
    }
}

- (void)updateFromSharedList:(SharedList *)sharedList {
    if (!sharedList) {
        return ;
    }
    
    NSManagedObjectID *shoplistID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:sharedList.shoplistID]] ;
    
    NSEntityDescription *shoplistEntity = [NSEntityDescription entityForName:@"Shoplist" inManagedObjectContext:self.managedObjectContext] ;
    NSEntityDescription *productEntity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext] ;
    NSEntityDescription *shopcategoryEntity = [NSEntityDescription entityForName:@"ShopCategory" inManagedObjectContext:self.managedObjectContext] ;
    NSEntityDescription *commodityEntity = [NSEntityDescription entityForName:@"Commodity" inManagedObjectContext:self.managedObjectContext] ;

    NSNumber *listIntsort ;

    Shoplist *shoplist = nil ;
    
    if (shoplistID) {
        shoplist = (Shoplist *)[self.managedObjectContext objectWithID:shoplistID] ;
    }

    if (shoplist && shoplist.name.length > 0) {
        listIntsort = shoplist.intsort ;
        [self clearShoplist:shoplist] ;
    } else {
        shoplist = [self shoplistByName:sharedList.name] ;

        if (shoplist && shoplist.name.length > 0) {
            listIntsort = shoplist.intsort ;
            [self clearShoplist:shoplist] ;
        } else {
            NSFetchRequest *countRequest = [[NSFetchRequest alloc] init] ;
            [countRequest setEntity:shoplistEntity] ;
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intsort" ascending:YES] ;
            [countRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]] ;
            NSArray *countObjects = [self.managedObjectContext executeFetchRequest:countRequest error:nil] ;
            
            if (countObjects.count == 0) {
                listIntsort = [NSNumber numberWithInt:1] ;
            } else {
                listIntsort = [NSNumber numberWithInt:1 + [((Shoplist *)[countObjects lastObject]).intsort intValue]] ;
            }

            shoplist = [[Shoplist alloc] initWithEntity:shoplistEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
        }
    }
    
    shoplist.name = sharedList.name ;
    shoplist.intsort = listIntsort ;
    
    for (SharedCommodity *sharedCommodity in sharedList.commodities) {
        Product *product = [self productByName:sharedCommodity.productName] ;

        if (!product) {
            product = [[Product alloc] initWithEntity:productEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
            product.name = sharedCommodity.productName ;
        }
        
        ShopCategory *shopcategory = [self shopCategoryByName:sharedCommodity.categoryName] ;

        if (!shopcategory) {
            shopcategory = [[ShopCategory alloc] initWithEntity:shopcategoryEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
            shopcategory.name = sharedCommodity.categoryName ;
            shopcategory.clr = sharedCommodity.categoryColor ;
            
            NSFetchRequest *countRequest = [[NSFetchRequest alloc] init] ;
            [countRequest setEntity:shopcategoryEntity] ;
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intsort" ascending:YES] ;
            [countRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]] ;
            NSArray *countObjects = [self.managedObjectContext executeFetchRequest:countRequest error:nil] ;
            
            if (countObjects.count == 0) {
                shopcategory.intsort = [NSNumber numberWithInt:1] ;
            } else {
                shopcategory.intsort = [NSNumber numberWithInt:1 + [((ShopCategory *)[countObjects lastObject]).intsort intValue]] ;
            }
        }
        
        product.shopCategory = shopcategory ;
        
        Commodity *commodity = [[Commodity alloc] initWithEntity:commodityEntity insertIntoManagedObjectContext:self.managedObjectContext] ;
        commodity.product = product ;
        commodity.amount = sharedCommodity.amount ;
        commodity.shopped = sharedCommodity.shopped ;
        commodity.shoplist = shoplist ;
    }
    
    [self commit] ;
}

@end
