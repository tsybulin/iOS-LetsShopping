//
//  BaseFetchedResultsController.h
//  goshopping
//
//  Created by Pavel Tsybulin on 18.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath ;

@end

@interface BaseFetchedResultsController : UIViewController <CellConfigurator, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    @protected
    NSFetchedResultsController *listController ;
    NSString *cellIdentifier ;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView ;

- (NSNumber *) newIntSort ;
- (void)moveItemFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexpath:(NSIndexPath *)destinationIndexPath ;

@end
