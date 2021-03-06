//
//  ExtensionDelegate.m
//  WatchApp Extension
//
//  Created by Pavel Tsybulin on 10/30/16.
//  Copyright © 2016 Pavel Tsybulin. All rights reserved.
//

#import "ExtensionDelegate.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ExtensionDelegate() <WCSessionDelegate>

@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    if ([WCSession isSupported]) {
        WCSession *wcsession = [WCSession defaultSession] ;
        wcsession.delegate = self ;
        [wcsession activateSession] ;
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompletedWithSnapshot:NO];
        }
    }
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if ([applicationContext objectForKey:@"shoplistID"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
        
        NSArray<NSString *> *allKeys = [[defaults dictionaryRepresentation] allKeys] ;
        for (NSString *key in allKeys) {
            [defaults removeObjectForKey:key] ;
        }
        
        [defaults setObject:applicationContext forKey:@"shoplist"] ;
        [defaults synchronize] ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOPLIST_CHANGED" object:nil] ;

        CLKComplicationServer *complicationServer = [CLKComplicationServer sharedInstance] ;
        for (CLKComplication *complication in complicationServer.activeComplications) {
            [complicationServer reloadTimelineForComplication:complication] ;
        }
    }
}

@end
