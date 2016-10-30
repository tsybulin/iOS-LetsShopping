//
//  ImportHelper.m
//  goshopping
//
//  Created by Pavel Tsybulin on 25.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import "ImportHelper.h"
#import "SharedCommodity.h"
#import "Commodity.h"
#import "Product.h"
#import "ShopCategory.h"

@implementation ImportHelper

+ (instancetype)sharedHelper {
    static ImportHelper *sharedInstance = nil ;
    
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[ImportHelper alloc] init] ;
        }
    }
    
    return sharedInstance ;
}

- (NSArray<NSDictionary<NSString *, id> *> *)commoditiesFromList:(Shoplist *)shoplist {
    NSMutableArray<NSDictionary<NSString *, id> *> *sharedArray = [NSMutableArray array] ;
    
    NSSortDescriptor *shoppedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shopped" ascending:YES] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    
    NSArray *commodities = [shoplist.commodities sortedArrayUsingDescriptors:@[shoppedSortDescriptor, categorySortDescriptor, productSortDescriptor]] ;
    
    for (Commodity *commodity in commodities) {
        SharedCommodity *sharedCommodity = [[SharedCommodity alloc] init] ;
        sharedCommodity.productName = commodity.product.name ;
        sharedCommodity.categoryName = commodity.product.shopCategory.name ;
        sharedCommodity.categoryColor = commodity.product.shopCategory.clr ;
        sharedCommodity.amount = commodity.amount ;
        sharedCommodity.shopped = commodity.shopped ;
        [sharedArray addObject:[sharedCommodity mutableDictionary]] ;
    }
    
    return sharedArray ;
}

- (NSDictionary<NSString *, id> *)dictionaryFromList:(Shoplist *)shoplist {
    NSArray *sharedArray = [self commoditiesFromList:shoplist] ;
    
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary dictionaryWithCapacity:0] ;
    [dict setObject:shoplist.name forKey:@"name"] ;
    [dict setObject:[[shoplist.objectID URIRepresentation] absoluteString] forKey:@"shoplistID"] ;
    [dict setObject:@(0) forKey:@"currentElement"] ;
    [dict setObject:sharedArray forKey:@"commodities"] ;

    return dict ;
}

- (SharedList *)listFromDictionary:(NSDictionary *)dictionary {
    if (dictionary) {
        NSMutableArray<SharedCommodity *> *sharedCommodities = [NSMutableArray array] ;
        NSArray<NSDictionary<NSString *, id> *> *sharedArray = [dictionary objectForKey:@"commodities"] ;
        for (NSDictionary<NSString *, id> *dc in sharedArray) {
            SharedCommodity *sharedCommodity = [[SharedCommodity alloc] init] ;
            [sharedCommodity fromDictionary:dc] ;
            [sharedCommodities addObject:sharedCommodity] ;
        }
        
        SharedList *sharedList = [[SharedList alloc] init] ;
        sharedList.commodities = sharedCommodities ;
        sharedList.name = [dictionary objectForKey:@"name"] ;
        sharedList.shoplistID = [dictionary objectForKey:@"shoplistID"] ;
        return sharedList ;
    }
    
    return nil ;
}

- (SharedList *)listFromURL:(NSURL *)url {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url] ;
    return [self listFromDictionary:dict] ;
}

- (SharedList *)listFromPath:(NSString *)path {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path] ;
    return [self listFromDictionary:dict] ;
}

@end
