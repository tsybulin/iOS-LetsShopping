//
//  ProductController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 21.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) Product *product ;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

- (IBAction)onCancel:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
