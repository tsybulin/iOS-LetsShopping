//
//  AppDelegate.h
//  letsshopping
//
//  Created by Pavel Tsybulin on 10/29/16.
//  Copyright © 2016 Pavel Tsybulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

