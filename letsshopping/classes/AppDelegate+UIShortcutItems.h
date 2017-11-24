//
//  AppDelegate+UIShortcutItems.h
//  letsshopping
//
//  Created by Pavel Tsybulin on 24.11.2017.
//  Copyright © 2017 Pavel Tsybulin. All rights reserved.
//

#import "AppDelegate.h"
#import "Shoplist.h"

@interface AppDelegate (UIShortcutItems)

- (void)updateShortcutItemsForApplication:(UIApplication *)application shopList:(Shoplist *)shopList ;

@end
