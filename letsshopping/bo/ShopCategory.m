//
//  ShopCategory.m
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ShopCategory.h"
#import "Product.h"

@implementation ShopCategory

@dynamic name;
@dynamic intsort;
@dynamic clr;
@dynamic products;

- (UIColor *)color {
    return [UIColor colorWithRed:((float)((self.clr.intValue & 0xFF0000) >> 16))/255.0 green:((float)((self.clr.intValue & 0xFF00) >> 8))/255.0 blue:((float)(self.clr.intValue & 0xFF))/255.0 alpha:1.0] ;
}

@end
