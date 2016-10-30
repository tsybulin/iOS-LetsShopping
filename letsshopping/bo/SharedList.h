//
//  SharedList.h
//  goshopping
//
//  Created by Pavel Tsybulin on 26.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedCommodity.h"

@interface SharedList : NSObject

@property (nonatomic, retain) NSString *name ;
@property (nonatomic, retain) NSString *shoplistID ;
@property (nonatomic, retain) NSArray<SharedCommodity *> *commodities ;

@end
