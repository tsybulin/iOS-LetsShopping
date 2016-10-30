//
//  TextExportProvider.m
//  goshopping
//
//  Created by Pavel Tsybulin on 28.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import "TextExportProvider.h"
#import "Commodity.h"
#import "Product.h"

@implementation TextExportProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"" ;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
    return @"public.plain-text" ;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return self.shoplist.name ;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if (!self.shoplist) {
        return nil ;
    }
    
    NSMutableString *text = [NSMutableString string] ;
    
    NSSortDescriptor *shoppedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shopped" ascending:YES] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    
    NSArray *commodities = [self.shoplist.commodities sortedArrayUsingDescriptors:@[shoppedSortDescriptor, categorySortDescriptor, productSortDescriptor]] ;
    
    for (Commodity *commodity in commodities) {
        [text appendFormat:@"%@ : %@\n", commodity.product.name, commodity.amount] ;
    }
        
    return text ;
}

@end
