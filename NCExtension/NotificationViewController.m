//
//  NotificationViewController.m
//  NCExtension
//
//  Created by Pavel Tsybulin on 5/17/18.
//  Copyright © 2018 Pavel Tsybulin. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension> {
    UIColor *playColor ;
}

@property (strong, nonatomic) IBOutlet UIView *inpView;
@property (strong, nonatomic) IBOutlet UIView *accView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    playColor = [UIColor blackColor] ;
    // Do any required interface initialization here.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [self configureView:0 updateMark:NO] ;
    [self becomeFirstResponder] ;
}

- (BOOL)canBecomeFirstResponder {
    return YES ;
}

- (UIView *)inputView {
    return self.inpView ;
}

- (UIView *)inputAccessoryView {
    return self.accView ;
}

- (UIColor *)mediaPlayPauseButtonTintColor {
    UIColor *color = [UIColor colorWithRed:65.0/255.0 green:187.0/255.0 blue:0.0 alpha:1.0f] ;
    return color ;
}

- (NSInteger)stepBy:(NSArray *)array current:(NSInteger)current step:(NSInteger)step {
    NSInteger result = current + step ;
    NSInteger count = array.count ;
    if (result > (count -1)) {
        return 0 ;
    }
    
    if (result < 0) {
        return count - 1 ;
    }
    
    return result ;
}

- (BOOL)configureView:(NSInteger)step updateMark:(BOOL)updateMark {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.tsybulin.goshopping"] ;
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary dictionaryWithDictionary:[sharedDefaults objectForKey:@"shoplist"]] ;
    NSMutableArray *sharedArray = [NSMutableArray arrayWithArray:[dict objectForKey:@"commodities"]] ;
    
    if (!sharedArray) {
        return NO ;
    }
    
    if (sharedArray.count < 1) {
        return NO ;
    }
    
    NSInteger currentElement = [self stepBy:sharedArray current:[[dict objectForKey:@"currentElement"] integerValue] step:0] ;

    if (updateMark) {
        NSMutableDictionary *sharedCommodity = [NSMutableDictionary dictionaryWithDictionary:[sharedArray objectAtIndex:currentElement]] ;
        BOOL shopped = ![[sharedCommodity objectForKey:@"shopped"] boolValue] ;
        [sharedCommodity setObject:[NSNumber numberWithBool:shopped] forKey:@"shopped"] ;
        [sharedArray replaceObjectAtIndex:currentElement withObject:sharedCommodity] ;
        [dict setObject:sharedArray forKey:@"commodities"] ;
        step = 1 ;
    }
    
    currentElement = [self stepBy:sharedArray current:currentElement step:step] ;
    
    ((UILabel *)[self.view viewWithTag:3]).text = [dict objectForKey:@"name"] ;

    int cnt = 0 ;
    for (NSDictionary *commodity in sharedArray) {
        cnt += [[commodity objectForKey:@"shopped"] boolValue] ? 0 : 1 ;
    }
    ((UILabel *)[self.view viewWithTag:2]).text = [NSString stringWithFormat:@"%d", cnt] ;

    [dict setObject:@(currentElement) forKey:@"currentElement"] ;
    [sharedDefaults setObject:dict forKey:@"shoplist"] ;
    
    NSDictionary *sharedCommodity = [sharedArray objectAtIndex:currentElement] ;
    ((UILabel *)[self.accView viewWithTag:1]).text = [NSString stringWithFormat:@"%@",  [sharedCommodity objectForKey:@"productName"]]   ;
    ((UILabel *)[self.accView viewWithTag:6]).text = [NSString stringWithFormat:@"%@ %@.", [sharedCommodity objectForKey:@"amount"], NSLocalizedString(@"pcs", nil)]   ;
    
    NSNumber *clr = [sharedCommodity objectForKey:@"categoryColor"] ;
    playColor = [UIColor colorWithRed:((float)((clr.intValue & 0xFF0000) >> 16))/255.0
                                green:((float)((clr.intValue & 0xFF00) >> 8))/255.0
                                 blue:((float)(clr.intValue & 0xFF))/255.0
                                alpha:1.0
                 ] ;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 51.0f) ;
    UIGraphicsBeginImageContext(rect.size) ;
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor(context, [playColor CGColor]) ;
    CGContextFillRect(context, rect) ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    ((UIImageView *)[self.accView viewWithTag:2]).image = image ;

    ((UIButton *)[self.inpView viewWithTag:3]).selected = [[sharedCommodity objectForKey:@"shopped"] boolValue] ;
    [sharedDefaults synchronize] ;
    
    return YES ;
}

- (void)didReceiveNotification:(UNNotification *)notification {
    [self configureView:0 updateMark:NO] ;
}

- (IBAction)onMarkTouched:(id)sender {
    [self configureView:0 updateMark:YES] ;
}

- (IBAction)onMoveTouched:(id)sender {
    UIControl *ctrl = sender ;
    if (ctrl.tag == 4) {
        [self configureView:-1 updateMark:NO] ;
    } else if (ctrl.tag == 5) {
        [self configureView:1 updateMark:NO] ;
    }
}

@end
