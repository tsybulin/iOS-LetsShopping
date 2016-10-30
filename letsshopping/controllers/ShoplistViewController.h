//
//  ShoplistViewController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "BaseFetchedResultsController.h"

@interface ShoplistViewController : BaseFetchedResultsController <UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectID *shoplistID ;

- (IBAction)onShop:(id)sender;
- (IBAction)hideKeyboard:(id)sender ;
- (IBAction)onRightNavButtonClick:(id)sender;

@end
