//
//  ShoplistViewController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 16.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ShoplistViewController.h"
#import "StorageHelper.h"
#import "Shoplist.h"
#import "Commodity.h"
#import "Product.h"
#import "ShopCategory.h"
#import "ProductListController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <UserNotifications/UserNotifications.h>
#import "SharedCommodity.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "ImportHelper.h"
#import "BinaryExportProvider.h"
#import "TextExportProvider.h"
#import "NSObject+Localizable.h"
#import "AppDelegate+UIShortcutItems.h"

@interface ShoplistViewController () {
    Shoplist *shoplist ;
    BOOL dataShared ;
}
@property (weak, nonatomic) IBOutlet UIImageView *ivCounter ;

@end

@implementation ShoplistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self localize] ;
    
    self.ivCounter.hidden = YES ;
    NSMutableArray *cntImageArray = [NSMutableArray arrayWithCapacity:5] ;
    for (int i = 5; i > 0; i--) {
        UIImage *cntImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]] ;
        [cntImageArray addObject:cntImage] ;
    }
    self.ivCounter.animationImages = cntImageArray ;
    self.ivCounter.animationDuration = 5.0f ;
    self.ivCounter.animationRepeatCount = 0 ;

    cellIdentifier = @"CommodityCell" ;
    
    shoplist = [[StorageHelper sharedHelper] shoplistByID:self.shoplistID] ;
    
    UIApplication *application = [UIApplication sharedApplication] ;
    [((AppDelegate *) application.delegate) updateShortcutItemsForApplication:application shopList:shoplist] ;

    ((UITextField *)self.navigationItem.titleView).text = shoplist.name ;
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRightNavButtonClick:)],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)]
    ] ;

    listController = [[StorageHelper sharedHelper] commodityFetchController:shoplist] ;
    listController.delegate = self ;
    
    dataShared = NO ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoimport) name:UIApplicationDidBecomeActiveNotification object:nil] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [listController performFetch:nil] ;
    [self.tableView reloadData] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (![shoplist.name isEqualToString:((UITextField *)self.navigationItem.titleView).text]) {
        shoplist.name = ((UITextField *)self.navigationItem.titleView).text ;
    }
    
    [[StorageHelper sharedHelper] commit] ;
    [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:@"com.tsybulin.goshopping.LetsShopWidget"] ;
    
    [super viewWillDisappear:animated] ;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addcommodity"]) {
        ((ProductListController *)segue.destinationViewController).shoplistID = shoplist.objectID ;
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES] ;
}

#pragma mark - CellConfigurator

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Commodity *commodity = [listController objectAtIndexPath:indexPath] ;
    ((UILabel *)[cell viewWithTag:1]).text = commodity.product.name ;

    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 36.0f) ;
    UIGraphicsBeginImageContext(rect.size) ;
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor(context, [commodity.product.shopCategory.color CGColor]) ;
    CGContextFillRect(context, rect) ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    ((UIImageView *)[cell viewWithTag:2]).image = image ;
    
    ((UIButton *)[cell viewWithTag:3]).selected = commodity.shopped ;
    
    ((UILabel *)[cell viewWithTag:4]).text = commodity.amount.stringValue ;
    ((UILabel *)[cell viewWithTag:5]).text = [NSLocalizedString(@"amount", @"") stringByAppendingString:@":"] ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCommodityAtPath:indexPath] ;
    }
}

#pragma mark - Actions

- (IBAction)onShop:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)((UIView *)sender).superview.superview] ;
    Commodity *commodity = [listController objectAtIndexPath:indexPath] ;
    commodity.shopped = !commodity.shopped ;
}

- (void)deleteCommodityAtPath:(NSIndexPath *)indexPath {
    Commodity *commodity = [listController objectAtIndexPath:indexPath] ;
    [[StorageHelper sharedHelper] deleteCommodity:commodity] ;
}

- (void)showActions {
    UIAlertController* alertActions = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select an action", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;
    alertActions.popoverPresentationController.sourceView = self.view ;
    alertActions.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0) ;

    UIAlertAction* deleteAllAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete all", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [[StorageHelper sharedHelper] clearShoplist:self->shoplist] ;
    }] ;
    [alertActions addAction:deleteAllAction] ;
    
    UIAlertAction* completeAllAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Complete all", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self.tableView beginUpdates] ;
        [[StorageHelper sharedHelper] markShoplist:self->shoplist shopped:YES] ;
        [self.tableView endUpdates] ;
        [self->listController performFetch:nil] ;
        [self.tableView reloadData] ;
    }] ;
    [alertActions addAction:completeAllAction] ;

    UIAlertAction* cancelAllAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel all", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self.tableView beginUpdates] ;
        [[StorageHelper sharedHelper] markShoplist:self->shoplist shopped:NO] ;
        [self.tableView endUpdates] ;
        [self->listController performFetch:nil] ;
        [self.tableView reloadData] ;
    }] ;
    [alertActions addAction:cancelAllAction] ;

    UIAlertAction* sendToAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send to...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIAlertController* alertSendTo = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Send to...", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;
        
        alertSendTo.popoverPresentationController.sourceView = self.view ;
        alertSendTo.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0) ;
        
        UIAlertAction* widgetAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Widget", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [[StorageHelper sharedHelper] commit] ;
            [self shareWithWidget] ;
        }] ;
        [alertSendTo addAction:widgetAction] ;

        UIAlertAction* notificationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notification", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [[StorageHelper sharedHelper] commit] ;
            [self shareWithNotification] ;
        }] ;
        [alertSendTo addAction:notificationAction] ;

        if ([WCSession isSupported]) {
            WCSession *wcsession = [WCSession defaultSession] ;
            if ([wcsession isPaired] && [wcsession isWatchAppInstalled]) {
                UIAlertAction* watchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Apple Watch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [[StorageHelper sharedHelper] commit] ;
                    [self shareWithWatch] ;
                }] ;
                [alertSendTo addAction:watchAction] ;
            }
        }
        
        UIAlertAction* textAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"As text...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self shareText] ;
        }] ;
        [alertSendTo addAction:textAction] ;
        
        UIAlertAction* binaryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"As binary...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self shareBinary] ;
        }] ;
        [alertSendTo addAction:binaryAction] ;

        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            //
        }] ;
        [alertSendTo addAction:cancelAction] ;
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:alertSendTo animated:YES completion:nil] ;
        }) ;
    }] ;
    [alertActions addAction:sendToAction] ;

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }] ;
    [alertActions addAction:cancelAction] ;

    [self presentViewController:alertActions animated:YES completion:nil] ;
}

- (IBAction)onRightNavButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"addcommodity" sender:self] ;
}

- (void)importGroupData {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.tsybulin.goshopping"] ;
    NSDictionary<NSString *, id> *dict = [sharedDefaults objectForKey:@"shoplist"] ;
    NSArray *sharedArray = [dict objectForKey:@"commodities"] ;
    
    if (!sharedArray) {
        return ;
    }
    
    if (![[[shoplist.objectID URIRepresentation] absoluteString] isEqualToString:[dict objectForKey:@"shoplistID"]]) {
        return ;
    }

    if (sharedArray.count < 1) {
        return ;
    }
    
    [self.tableView beginUpdates] ;
    
    NSSortDescriptor *shoppedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shopped" ascending:YES] ;
    NSSortDescriptor *categorySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.shopCategory.intsort" ascending:YES] ;
    NSSortDescriptor *productSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"product.name" ascending:YES] ;
    
    NSArray *commodities = [shoplist.commodities sortedArrayUsingDescriptors:@[shoppedSortDescriptor, categorySortDescriptor, productSortDescriptor]] ;

    NSInteger i = 0 ;
    for (Commodity *commodity in commodities) {
        commodity.shopped = [[[sharedArray objectAtIndex:i] objectForKey:@"shopped"] boolValue] ;
        i++ ;
    }
    
    [self.tableView endUpdates] ;
    [listController performFetch:nil] ;
    [self.tableView reloadData] ;
    dataShared = NO ;
}

- (void)shareGroupData {
    NSDictionary<NSString *, id> *dict = [[ImportHelper sharedHelper] dictionaryFromList:shoplist] ;
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.tsybulin.goshopping"] ;
    
    NSArray<NSString *> *allKeys = [[sharedDefaults dictionaryRepresentation] allKeys] ;
    for (NSString *key in allKeys) {
        [sharedDefaults removeObjectForKey:key] ;
    }
    
    [sharedDefaults setObject:dict forKey:@"shoplist"] ;
    [sharedDefaults synchronize] ;
    dataShared = YES ;
}

- (void)shareWithWidget {
    [self shareGroupData] ;
    
    [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:@"com.tsybulin.goshopping.LetsShopWidget"] ;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Use the results?", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;

    alert.popoverPresentationController.sourceView = self.view ;
    alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0) ;
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:@"com.tsybulin.goshopping.LetsShopWidget"] ;
    }] ;
    [alert addAction:defaultAction] ;
    
    [self presentViewController:alert animated:YES completion:nil] ;
}

- (void)stopCounter {
    [self.ivCounter stopAnimating] ;
    self.ivCounter.hidden = YES ;
}

- (void)showNotification:(NSString *)title timeout:(NSTimeInterval)timeout {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init] ;
    content.body = NSLocalizedString(@"Expand to interact", nil)  ;
    content.title = title ;
    content.categoryIdentifier = @"ltsNotification" ;
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeout repeats:NO] ;
    UNNotificationRequest *request =  [UNNotificationRequest requestWithIdentifier:@"FiveSecond" content:content trigger:trigger] ;
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }] ;
}

- (void)showNotification {
    [self showNotification:shoplist.name timeout:5.0f] ;
    [self performSelector:@selector(stopCounter) withObject:nil afterDelay:5] ;
    self.ivCounter.hidden = NO ;
    [self.ivCounter startAnimating] ;
}

- (void)shareWithNotification {
    [self shareGroupData] ;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter] ;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"AppDelegate.requestAuthorizationWithOptions error %@", error) ;
            return ;
        } else {
            if (!granted) {
                NSLog(@"AppDelegate.requestAuthorizationWithOptions not granted") ;
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self showNotification] ;
            }) ;
        }
    }] ;
}

- (void)shareWithWatch {
    if (![WCSession isSupported]) {
        return ;
    }

    WCSession *wcsession = [WCSession defaultSession] ;

    if (![wcsession isPaired]) {
        return ;
    }
    
    if(![wcsession isWatchAppInstalled]) {
        return ;
    }

    NSDictionary<NSString *, id> *dict = [[ImportHelper sharedHelper] dictionaryFromList:shoplist] ;
    
    NSError *error = nil ;
    [wcsession updateApplicationContext:dict error:&error] ;
    if (error) {
        NSLog(@"shareWithWatch error: %@", error) ;
    }
}

- (void)shareText {
    TextExportProvider *provider = [[TextExportProvider alloc]initWithPlaceholderItem:@""] ;
    provider.shoplist = shoplist ;

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil] ;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:activityViewController animated:YES completion:nil] ;
    }) ;
}

- (void)shareBinary {
    BinaryExportProvider *provider = [[BinaryExportProvider alloc] initWithPlaceholderItem:[NSData data]] ;
    provider.shoplist = shoplist ;

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil] ;

    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:activityViewController animated:YES completion:nil] ;
    }) ;
}

- (void)autoimport {
    if (dataShared) {
        [self importGroupData] ;
    }
}

@end
