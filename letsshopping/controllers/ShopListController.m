//
//  ShopListController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 15.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ShopListController.h"
#import "AppDelegate.h"
#import "StorageHelper.h"
#import "Shoplist.h"
#import "Commodity.h"
#import "Product.h"
#import "ShoplistViewController.h"
#import "ShopcategoryListController.h"
#import "ProductListController.h"
#import "NSObject+Localizable.h"

@interface ShopListController () <UIViewControllerPreviewingDelegate>

@end

@implementation ShopListController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    [self localize] ;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRightNavButtonClick:)] ;

    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view] ;
    }

    cellIdentifier = @"ShoplistCell" ;

    listController = [[StorageHelper sharedHelper] shoplistFetchController] ;
    listController.delegate = self ;
    [listController performFetch:nil] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;

    UIColor *color = [UIColor colorWithRed:29.0/255.0 green:126.0/255.0 blue:1.0 alpha:1.0f] ;
    self.navigationController.navigationBar.barTintColor = color ;
    
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:color] ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [[StorageHelper sharedHelper] commit] ;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shoplist"]) {
        ((ShoplistViewController *)segue.destinationViewController).shoplistID = sender ;
    } else if ([segue.identifier isEqualToString:@"shopcategories"]) {
        ((ShopcategoryListController *)segue.destinationViewController).product = nil ;
    } else if ([@"products" isEqualToString:segue.identifier]) {
        ((ProductListController *)segue.destinationViewController).shoplistID = nil ;
    }
}

#pragma mark - CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Shoplist *shoplist = [listController objectAtIndexPath:indexPath] ;
    ((UILabel *)[cell viewWithTag:1]).text = shoplist.name ;
    ((UILabel *)[cell viewWithTag:2]).text = [shoplist.name substringToIndex:1] ;
    
    NSMutableString *productNames = [NSMutableString string] ;
    for (Commodity *commodity in [shoplist.commodities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"product.name" ascending:YES]]]) {
        if (productNames.length > 0) {
            [productNames appendString:@", "] ;
        }
        [productNames appendString:commodity.product.name] ;
        
        if (productNames.length > 40) {
            break ;
        }
    }
    
    ((UILabel *)[cell viewWithTag:3]).text = productNames ;
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES ;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self moveItemFromIndexPath:sourceIndexPath toIndexpath:destinationIndexPath] ;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.tableView.editing || [self tableView:tableView numberOfRowsInSection:0] > 1 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert ;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewRowAction *actCopy = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Copy", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.tableView.editing = NO ;
        [self copyListAtPath:indexPath] ;
    }] ;

    if ([self tableView:tableView numberOfRowsInSection:0] > 1) {
        UITableViewRowAction *actDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self deleteListAtPath:indexPath] ;
        }] ;

        return @[actDelete, actCopy] ;
    } else {
        UITableViewRowAction *actAdd = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"New", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            self.tableView.editing = NO ;
            [self addList] ;
        }] ;
        
        return @[actAdd, actCopy] ;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addList] ;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"shoplist" sender:((Shoplist *)[listController objectAtIndexPath:indexPath]).objectID] ;
}

#pragma mark - Actions

- (IBAction)onRightNavButtonClick:(id)sender {
    if (self.tableView.editing) {
        self.tableView.editing = NO ;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRightNavButtonClick:)] ;
    } else {
        [self addList] ;
    }
}

- (IBAction)onLeftNavButtonClick:(id)sender {
    UIAlertController* alertActions = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select an action", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;
    alertActions.popoverPresentationController.sourceView = self.view ;
    alertActions.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0) ;
    
    
    UIAlertAction* editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onRightNavButtonClick:)] ;
        [self.tableView setEditing:YES animated:YES] ;
    }] ;
    [alertActions addAction:editAction] ;

    UIAlertAction* categoriesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"categories", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"shopcategories" sender:self] ;
    }] ;
    [alertActions addAction:categoriesAction] ;
    
    UIAlertAction* productsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"products", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"products" sender:self] ;
    }] ;
    [alertActions addAction:productsAction] ;
    
    UIAlertAction* aboutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"About", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"about" sender:self] ;
    }] ;
    [alertActions addAction:aboutAction] ;
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }] ;
    [alertActions addAction:cancelAction] ;
    
    [self presentViewController:alertActions animated:YES completion:nil] ;
}

- (void)addList {
    Shoplist *shoplist = [[StorageHelper sharedHelper] addShoplist:NSLocalizedString(@"New list", nil) intsort:[self newIntSort]] ;
    [self performSegueWithIdentifier:@"shoplist" sender:shoplist.objectID] ;
}

- (void)deleteListAtPath:(NSIndexPath *)indexPath {
    [[StorageHelper sharedHelper] deleteShoplist:[listController objectAtIndexPath:indexPath]] ;
}

- (void)copyListAtPath:(NSIndexPath *)indexPath {
    [[StorageHelper sharedHelper] copyShoplist:[listController objectAtIndexPath:indexPath] withIntsort: [self newIntSort]] ;
}

#pragma mark <UIViewControllerPreviewingDelegate>

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view] ;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion] ;
    
    if (!indexPath) {
        return nil ;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ; // ShoplistViewController
    ShoplistViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ShoplistViewController"] ;
    controller.shoplistID = ((Shoplist *)[listController objectAtIndexPath:indexPath]).objectID ;
    UITableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:indexPath] ;
    previewingContext.sourceRect = [self.view convertRect:tableCell.frame fromView:self.tableView] ;
    return controller ;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil] ;
}

@end
