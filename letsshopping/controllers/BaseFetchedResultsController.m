//
//  BaseFetchedResultsController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 18.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "BaseFetchedResultsController.h"

@interface BaseFetchedResultsController ()

@end

@implementation BaseFetchedResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd] ;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return listController.sections.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[listController.sections objectAtIndex:section] numberOfObjects] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath] ;
    [self configureCell:cell atIndexPath:indexPath] ;
    return cell ;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((id<NSFetchedResultsSectionInfo>)[[listController sections] objectAtIndex:section]).name  ;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates] ;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade] ;
            break ;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade] ;
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath] ;
            break ;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade] ;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade] ;
            break ;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates] ;
}

- (NSNumber *) newIntSort {
    NSUInteger count = [[listController.sections objectAtIndex:0] numberOfObjects] ;
    if (count == 0) {
        return [NSNumber numberWithInt:1] ;
    } else {
        NSManagedObject *obj = [listController objectAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0]] ;
        NSNumber *intsort = [obj valueForKey:@"intsort"] ;
        if (intsort) {
            return [NSNumber numberWithInt:1 + intsort.intValue] ;
        } else {
            return [NSNumber numberWithInt:1] ;
        }
    }
}

- (void)moveItemFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexpath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *before = [NSMutableArray array] ;
    NSInteger first = sourceIndexPath.row < destinationIndexPath.row ? sourceIndexPath.row : destinationIndexPath.row ;
    NSInteger last = destinationIndexPath.row > sourceIndexPath.row ? destinationIndexPath.row : sourceIndexPath.row ;
    
    for (NSInteger i = first ; i <= last; i++) {
        [before addObject:[listController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]] ;
    }
    
    NSUInteger intsort = ((NSNumber *)[[before firstObject] valueForKey:@"intsort"]).unsignedIntegerValue ;
    
    if (sourceIndexPath.row < destinationIndexPath.row) {
        NSObject *item = [before firstObject] ;
        [before removeObjectAtIndex:0] ;
        [before addObject:item] ;
    } else {
        NSObject *item = [before lastObject] ;
        [before removeLastObject] ;
        [before insertObject:item atIndex:0] ;
    }
    
    for (NSObject *item in before) {
        [item setValue:[NSNumber numberWithUnsignedInteger:intsort] forKey:@"intsort"] ;
        intsort++ ;
    }
}

@end
