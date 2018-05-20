//
//  TodayViewController.m
//  LetsShoppingWidget
//
//  Created by Pavel Tsybulin on 10/30/16.
//  Copyright © 2016 Pavel Tsybulin. All rights reserved.
//

#import "TodayViewController.h"
#import "SharedCommodity.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding> {
    
}

- (IBAction)onMarkTouched:(id)sender;
- (IBAction)onMoveTouched:(id)sender;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [self configureView:0 updateMark:NO] ;
}

//- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins {
//    return UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0) ;
//}

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
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.ptsybulin.letsshopping"] ;
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
    
    [dict setObject:@(currentElement) forKey:@"currentElement"] ;
    [sharedDefaults setObject:dict forKey:@"shoplist"] ;
    
    NSDictionary *sharedCommodity = [sharedArray objectAtIndex:currentElement] ;
    ((UILabel *)[self.view viewWithTag:1]).text = [NSString stringWithFormat:@"%@",  [sharedCommodity objectForKey:@"productName"]]   ;
    ((UILabel *)[self.view viewWithTag:6]).text = [NSString stringWithFormat:@"%@ %@.", [sharedCommodity objectForKey:@"amount"], NSLocalizedString(@"pcs", nil)]   ;
    
    NSNumber *clr = [sharedCommodity objectForKey:@"categoryColor"] ;
    UIColor *color = [UIColor colorWithRed:((float)((clr.intValue & 0xFF0000) >> 16))/255.0 green:((float)((clr.intValue & 0xFF00) >> 8))/255.0 blue:((float)(clr.intValue & 0xFF))/255.0 alpha:1.0] ;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 51.0f) ;
    UIGraphicsBeginImageContext(rect.size) ;
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor(context, [color CGColor]) ;
    CGContextFillRect(context, rect) ;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    ((UIImageView *)[self.view viewWithTag:2]).image = image ;
    
    
    ((UIButton *)[self.view viewWithTag:3]).selected = [[sharedCommodity objectForKey:@"shopped"] boolValue] ;
    
    [sharedDefaults synchronize] ;
    
    return YES ;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    if ([self configureView:0 updateMark:NO]) {
        completionHandler(NCUpdateResultNoData) ;
    } else {
        completionHandler(NCUpdateResultNoData) ;
    }
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
