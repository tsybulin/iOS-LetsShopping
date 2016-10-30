//
//  ProductListController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 18.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ProductListController.h"
#import "StorageHelper.h"
#import "Shoplist.h"
#import "Commodity.h"
#import "Product.h"
#import "ShopCategory.h"
#import "ALToastView.h"
#import "ShopcategoryListController.h"
#import "ProductController.h"

NSString * const C_AMOUNT_SEPARATOR = @" • " ;

@interface ProductListController () {
    Shoplist *shoplist ;
}

@end

@implementation ProductListController

- (void)viewDidLoad {
    [super viewDidLoad];

    cellIdentifier = @"ProductCell" ;
    
    if (self.shoplistID) {
        self.searchField.inputAccessoryView = self.accessoryView ;
        shoplist = [[StorageHelper sharedHelper] shoplistByID:self.shoplistID] ;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onRightNavButtonClick:)] ;
    }

    listController = [[StorageHelper sharedHelper] productFetchController] ;
    
    listController.delegate = self ;
    [listController performFetch:nil] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"pickshopcategory" isEqualToString:segue.identifier]) {
        ((ShopcategoryListController *) segue.destinationViewController).product = sender ;
    } else if ([@"product" isEqualToString:segue.identifier]) {
        ((ProductController *) segue.destinationViewController).product = sender ;
    }
}

#pragma mark - CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Product *product = [listController objectAtIndexPath:indexPath] ;
    ((UILabel *)[cell viewWithTag:1]).text = product.name ;

    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 36.0f) ;
    UIGraphicsBeginImageContext(rect.size) ;
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor(context, [product.shopCategory.color CGColor]) ;
    CGContextFillRect(context, rect) ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    ((UIImageView *)[cell viewWithTag:2]).image = image ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    
    UIColor *color = [UIColor colorWithRed:1.0 green:240.0/255.0 blue:0.0 alpha:1.0f] ;
    self.navigationController.navigationBar.barTintColor = color ;
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:color] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [[StorageHelper sharedHelper] commit] ;
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.shoplistID == nil ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteProduct:[listController objectAtIndexPath:indexPath]] ;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shoplistID) {
        [self selectProduct:indexPath] ;
        [self.searchField becomeFirstResponder] ;
    } else if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"product" sender:[listController objectAtIndexPath:indexPath]] ;
    }
}

- (void)selectProduct:(NSIndexPath *)indexPath {
    Product *product = [listController objectAtIndexPath:indexPath] ;
    self.searchField.text = product.name ;
    self.buttonAmount.enabled = YES ;
    
    [self refineList:product.name] ;
}

- (void)refineList:(NSString *)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like[c] %@", [searchText stringByAppendingString:@"*"]] ;
    listController.fetchRequest.predicate = predicate ;
    
    [listController performFetch:nil] ;
    
    [self.tableView reloadData] ;
}

#pragma mark - Actions

- (NSString *)productFromPatternt {
    NSArray *parts = [self.searchField.text componentsSeparatedByString:C_AMOUNT_SEPARATOR] ;
    if (!parts || parts.count < 2) {
        return self.searchField.text ;
    } else {
        return [parts objectAtIndex:0] ;
    }
}

- (NSNumber *)amountFromPatternt {
    NSArray *parts = [self.searchField.text componentsSeparatedByString:C_AMOUNT_SEPARATOR] ;
    if (!parts || parts.count < 2) {
        return [NSNumber numberWithInt:1] ;
    } else {
        return [NSNumber numberWithInteger:[[parts objectAtIndex:1] integerValue]] ;
    }
}


- (IBAction)onAmount:(id)sender {
    NSString *product = [self productFromPatternt] ;

    if ([self.searchField.text isEqualToString:product]) {
        self.searchField.keyboardType = UIKeyboardTypeNumbersAndPunctuation ;
        self.searchField.text = [self.searchField.text stringByAppendingString:C_AMOUNT_SEPARATOR] ;
    } else {
        self.searchField.keyboardType = UIKeyboardTypeDefault ;
        self.searchField.text = product ;
    }

    [self.searchField reloadInputViews] ;
}

- (IBAction)onOk:(id)sender {
    if (!self.shoplistID || !self.searchField.text || self.searchField.text.length < 3) {
        [self hideKeyboard:sender] ;
        return ;
    }
    
    Product *product = [[StorageHelper sharedHelper] productByName:[self productFromPatternt]] ;
    if (product) {
        Commodity *commodity = [[StorageHelper sharedHelper] commodityWithProduct:product shopList:shoplist] ;
        commodity.amount = [self amountFromPatternt] ;
        
        [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"%@ %@ • %@", NSLocalizedString(@"Added", nil), product.name, commodity.amount]] ;
        
        self.searchField.text = @"" ;
        [self searchValueChanged:self] ;
    } else {
        product = [[StorageHelper sharedHelper] addProduct:[self productFromPatternt]] ;

        Commodity *commodity = [[StorageHelper sharedHelper] commodityWithProduct:product shopList:shoplist] ;
        commodity.amount = [self amountFromPatternt] ;
        
        [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"%@ %@ • %@", NSLocalizedString(@"New product", nil), product.name, commodity.amount]] ;
        
        self.searchField.text = @"" ;
        [self searchValueChanged:self] ;

        [self performSegueWithIdentifier:@"pickshopcategory" sender:product] ;
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [self.searchField resignFirstResponder] ;
}

- (IBAction)searchValueChanged:(id)sender {
    NSString *searchText = [self productFromPatternt] ;
    
    if (searchText.length > 0) {
        self.buttonAmount.enabled = YES ;
    } else {
        self.buttonAmount.enabled = NO ;
    }
    
    [self refineList:searchText] ;
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

- (void)deleteProduct:(Product *)product {
    [[StorageHelper sharedHelper] deleteProduct:product] ;
}

@end
