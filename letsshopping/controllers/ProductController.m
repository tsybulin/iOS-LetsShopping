//
//  ProductController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 21.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ProductController.h"
#import <CoreData/CoreData.h>
#import "StorageHelper.h"
#import "ShopCategory.h"

@interface ProductController () {
    NSFetchedResultsController *listController ;
}

@end

@implementation ProductController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    listController = [[StorageHelper sharedHelper] shopcategoryFetchController] ;
    [listController performFetch:nil] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    
    if (self.product) {
        self.nameField.text = self.product.name ;
        
        NSIndexPath *indexPath = [listController indexPathForObject:self.product.shopCategory] ;
        if (indexPath) {
            [self.categoryPicker selectRow:indexPath.row inComponent:0 animated:YES] ;
        }
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1 ;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[listController.sections objectAtIndex:0] numberOfObjects] ;
}


#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    ShopCategory *shopcategory = [listController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] ;
    return [[NSAttributedString alloc] initWithString:shopcategory.name attributes:@{NSForegroundColorAttributeName: shopcategory.color}] ;
}

#pragma mark - Actions

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (IBAction)onSave:(id)sender {
    if (!self.product) {
        return ;
    }

    self.product.name = self.nameField.text ;
    self.product.shopCategory = [listController objectAtIndexPath:[NSIndexPath indexPathForRow:[self.categoryPicker selectedRowInComponent:0] inSection:0]] ;

    [[StorageHelper sharedHelper] commit] ;

    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (IBAction)hideKeyboard:(id)sender {
    [self.nameField resignFirstResponder] ;
}

@end
