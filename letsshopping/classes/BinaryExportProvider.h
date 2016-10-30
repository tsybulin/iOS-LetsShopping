//
//  BinaryExportProvider.h
//  goshopping
//
//  Created by Pavel Tsybulin on 28.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoplist.h"

@interface BinaryExportProvider : UIActivityItemProvider

@property (nonatomic, strong) Shoplist *shoplist ;

@end
