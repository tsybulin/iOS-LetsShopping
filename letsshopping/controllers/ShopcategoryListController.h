//
//  ShopcategoryPickerController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 19.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "BaseFetchedResultsController.h"
#import "Product.h"

@interface ShopcategoryListController : BaseFetchedResultsController <UITableViewDelegate>

@property (nonatomic, strong) Product *product ;

- (IBAction)onRightNavButtonClick:(id)sender ;

@end
