//
//  ProductListController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 18.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "BaseFetchedResultsController.h"

@interface ProductListController : BaseFetchedResultsController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchField ;
@property (strong, nonatomic) NSManagedObjectID *shoplistID ;
@property (weak, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *buttonAmount;

- (IBAction)onAmount:(id)sender;
- (IBAction)onOk:(id)sender;
- (IBAction)hideKeyboard:(id)sender ;
- (IBAction)searchValueChanged:(id)sender ;

@end
