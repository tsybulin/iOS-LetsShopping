//
//  ShopListController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 15.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "BaseFetchedResultsController.h"

@interface ShopListController : BaseFetchedResultsController <UITableViewDelegate>

- (IBAction)onRightNavButtonClick:(id)sender ;
- (IBAction)onLeftNavButtonClick:(id)sender;

@end
