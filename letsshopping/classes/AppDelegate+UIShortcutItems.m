//
//  AppDelegate+UIShortcutItems.m
//  letsshopping
//
//  Created by Pavel Tsybulin on 24.11.2017.
//  Copyright © 2017 Pavel Tsybulin. All rights reserved.
//

#import "AppDelegate+UIShortcutItems.h"
#import "Commodity.h"
#import "Product.h"
#import "ShoplistViewController.h"

@implementation AppDelegate (UIShortcutItems)

- (void)updateShortcutItemsForApplication:(UIApplication *)application shopList:(Shoplist *)shopList {
    NSMutableArray <UIApplicationShortcutItem *> *shortcutItems = [application.shortcutItems mutableCopy] ;
    [shortcutItems removeAllObjects] ;
    
    NSMutableString *productNames = [NSMutableString string] ;
    for (Commodity *commodity in [shopList.commodities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"product.name" ascending:YES]]]) {
        if (productNames.length > 0) {
            [productNames appendString:@", "] ;
        }
        [productNames appendString:commodity.product.name] ;
        
        if (productNames.length > 40) {
            break ;
        }
    }

    UIApplicationShortcutItem *shortcutItem = [[UIApplicationShortcutItem alloc]
                                               initWithType:@"com.tsybulin.letsshopping.shoplist"
                                               localizedTitle:shopList.name localizedSubtitle:productNames
                                               icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeTaskCompleted]
                                               userInfo:@{@"shoplistID" : [[shopList.objectID URIRepresentation] absoluteString]}
                                               ] ;
    [shortcutItems addObject:shortcutItem] ;

    application.shortcutItems = shortcutItems ;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
    if ([@"com.tsybulin.letsshopping.shoplist" isEqualToString:shortcutItem.type]) {

        NSString *shoplistId = (NSString *)[shortcutItem.userInfo objectForKey:@"shoplistID"] ;
        NSManagedObjectID *shoplistID = [self.persistentContainer.viewContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:shoplistId]] ;

        if (shoplistID) {
            ShoplistViewController *controller = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ShoplistViewController"] ;
            controller.shoplistID = shoplistID ;
            [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO] ;
            [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:NO] ;
            completionHandler(YES) ;
            return ;
        }
        
        completionHandler(NO) ;
    } else {
        completionHandler(NO) ;
    }
}

@end
