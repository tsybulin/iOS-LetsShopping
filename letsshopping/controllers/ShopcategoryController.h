//
//  ShopcategoryController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 20.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCategory.h"

@interface ShopcategoryController : UIViewController

@property (strong, nonatomic) ShopCategory *shopcategory ;

@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)onRightNavButtonClick:(id)sender;

- (IBAction)hideKeyboard:(id)sender;

@end
