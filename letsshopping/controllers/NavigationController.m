//
//  NavigationController.m
//  letsshopping
//
//  Created by Pavel Tsybulin on 9/26/19.
//  Copyright © 2019 Pavel Tsybulin. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init] ;
    UIColor *color = [UIColor colorWithRed:0.162 green:0.413 blue:0.667 alpha:1.0] ;
    appearance.backgroundColor = color ;
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]} ;
    appearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]} ;
    UINavigationBar.appearance.tintColor = [UIColor whiteColor] ;
    UINavigationBar.appearance.standardAppearance = appearance ;
    UINavigationBar.appearance.compactAppearance = appearance ;
    UINavigationBar.appearance.scrollEdgeAppearance = appearance ;

    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:color] ;
}

@end
