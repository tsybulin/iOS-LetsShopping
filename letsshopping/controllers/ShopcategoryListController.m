//
//  ShopcategoryPickerController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 19.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ShopcategoryListController.h"
#import "StorageHelper.h"
#import "ShopCategory.h"
#import "ShopcategoryController.h"
#import "NSObject+Localizable.h"

@interface ShopcategoryListController ()

@end

@implementation ShopcategoryListController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    [self localize] ;

    cellIdentifier = @"ShopcategoryCell" ;
    
    if (self.product) {
        self.navigationItem.rightBarButtonItem = nil ;
    }

    listController = [[StorageHelper sharedHelper] shopcategoryFetchController] ;
    listController.delegate = self ;
    [listController performFetch:nil] ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shopcategory"]) {
        ((ShopcategoryController *)segue.destinationViewController).shopcategory = sender ;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [[StorageHelper sharedHelper] commit] ;
}

#pragma mark - CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ShopCategory *shopcategory = [listController objectAtIndexPath:indexPath] ;
    ((UILabel *)[cell viewWithTag:1]).text = shopcategory.name ;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 36.0f) ;
    UIGraphicsBeginImageContext(rect.size) ;
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor(context, [shopcategory.color CGColor]) ;
    CGContextFillRect(context, rect) ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    ((UIImageView *)[cell viewWithTag:2]).image = image ;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete ;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *caAdd = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:NSLocalizedString(@"New", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        self.tableView.editing = NO ;
        [self addShopcategory] ;
    }] ;

    if ([self tableView:tableView numberOfRowsInSection:0] > 1) {
        UIContextualAction *caDelete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self deleteShopcategory:indexPath] ;
        }] ;

        return [UISwipeActionsConfiguration configurationWithActions:@[caDelete, caAdd]] ;
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:@[caAdd]] ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addShopcategory] ;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.product) {
        self.product.shopCategory = [listController objectAtIndexPath:indexPath] ;
        [self.navigationController popViewControllerAnimated:YES] ;
    } else if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"shopcategory" sender:[listController objectAtIndexPath:indexPath]] ;
    }
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self moveItemFromIndexPath:sourceIndexPath toIndexpath:destinationIndexPath] ;
}


#pragma mark - Actions

- (void)deleteShopcategory:(NSIndexPath *)indexPath {
    ShopCategory *shopcategory = [listController objectAtIndexPath:indexPath] ;
    [[StorageHelper sharedHelper] deleteShopcategory:shopcategory] ;
}

- (void)addShopcategory {
    ShopCategory *shopcategory = [[StorageHelper sharedHelper] addShopCategory:@"Новая категория" intsort:[self newIntSort] color:[NSNumber numberWithUnsignedInteger:13421772]] ; // #cccccc
    [self performSegueWithIdentifier:@"shopcategory" sender:shopcategory] ;
}

- (IBAction)onRightNavButtonClick:(id)sender {
    if (self.tableView.editing) {
        self.tableView.editing = NO ;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onRightNavButtonClick:)] ;
    } else {
        self.tableView.editing = YES ;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onRightNavButtonClick:)] ;
    }
}


@end
