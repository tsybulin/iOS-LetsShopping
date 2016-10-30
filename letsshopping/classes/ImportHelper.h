//
//  ImportHelper.h
//  goshopping
//
//  Created by Pavel Tsybulin on 25.09.15.
//  Copyright © 2015 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shoplist.h"
#import "SharedList.h"

@interface ImportHelper : NSObject

+ (instancetype)sharedHelper ;

- (NSArray<NSDictionary<NSString *, id> *> *)commoditiesFromList:(Shoplist *)shoplist ;
- (NSDictionary<NSString *, id> *)dictionaryFromList:(Shoplist *)shoplist ;
- (SharedList *)listFromURL:(NSURL *)url ;
- (SharedList *)listFromPath:(NSString *)path ;

@end
