//
//  AppDelegate.m
//  letsshopping
//
//  Created by Pavel Tsybulin on 10/29/16.
//  Copyright © 2016 Pavel Tsybulin. All rights reserved.
//

#import "AppDelegate.h"
#import <NotificationCenter/NotificationCenter.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "StorageHelper.h"
#import "ImportHelper.h"
// #import "LogHelper.h"

@interface AppDelegate () <WCSessionDelegate>

@end

@implementation AppDelegate

@synthesize notificationTitle ;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Hide widget
    [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:@"com.tsybulin.goshopping.LetsShopWidget"] ;
    
    StorageHelper *storageHelper = [StorageHelper sharedHelper] ;
    storageHelper.managedObjectContext = self.persistentContainer.viewContext ;

    [storageHelper checkLists] ;

    if ([WCSession isSupported]) {
        WCSession *wcsession = [WCSession defaultSession] ;
        wcsession.delegate = self ;
        [wcsession activateSession] ;
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    //NSLog(@"applicationWillResignActive") ;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //NSLog(@"applicationDidEnterBackground") ;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //NSLog(@"applicationWillEnterForeground") ;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //NSLog(@"applicationDidBecomeActive") ;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"letsshopping"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Open file
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if ([url isFileURL]) {
        [[StorageHelper sharedHelper] updateFromSharedList:[[ImportHelper sharedHelper] listFromURL:url]] ;
        
        NSError *error = nil ;
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error] ;
        if (error) {
            NSLog(@"removeItemAtURL error %@", error) ;
        }
        
        return YES ;
    }
    
    return NO ;
}

#pragma mark - WCSessionDelegate

- (void)updateFromWatch:(NSDictionary<NSString *,id> *)dictionary {
    StorageHelper *storageHelper = [StorageHelper sharedHelper] ;
    NSString *shoplistId = [dictionary objectForKey:@"shoplistID"] ;
    NSNumber *currentElement = [dictionary objectForKey:@"currentElement"] ;
    BOOL shopped = [[dictionary objectForKey:@"shopped"] boolValue] ;
    
    [storageHelper updateFromWatch:shoplistId element:currentElement shopped:shopped] ;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    [self updateFromWatch:message] ;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    [self updateFromWatch:message] ;
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    [self updateFromWatch:applicationContext] ;
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
}

- (void)sessionDidDeactivate:(WCSession *)session {
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
}

#pragma mark User Activity Continuation


@end
