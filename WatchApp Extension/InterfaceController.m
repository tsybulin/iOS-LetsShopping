//
//  InterfaceController.m
//  WatchApp Extension
//
//  Created by Pavel Tsybulin on 10/30/16.
//  Copyright © 2016 Pavel Tsybulin. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>


@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblName;
@property (weak, nonatomic) IBOutlet WKInterfaceSeparator *sepName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblAmount;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *btnMark;

- (IBAction)prevTouched;
- (IBAction)nextTouched;
- (IBAction)markTouched;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.lblName setText:NSLocalizedString(@"Let's Shopping!", nil)] ;
    [self.lblAmount setText:NSLocalizedString(@"Please share list", nil)] ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoplistUpdated:) name:@"SHOPLIST_CHANGED" object:nil] ;
}

- (void)willActivate {
    [super willActivate] ;
    [self configureView:0 updateMark:NO] ;
}

- (void)didDeactivate {
    [super didDeactivate] ;
}

- (void)shoplistUpdated:(NSNotification *)notification {
    [self configureView:0 updateMark:NO] ;
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"shoplist"]] ;
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
        
        if ([WCSession isSupported]) {
            WCSession *wcsession = [WCSession defaultSession] ;
            
            NSMutableDictionary<NSString *, id> *upd = [NSMutableDictionary dictionaryWithCapacity:0] ;
            [upd setObject:[dict objectForKey:@"shoplistID"] forKey:@"shoplistID"] ;
            [upd setObject:@(currentElement) forKey:@"currentElement"] ;
            [upd setObject:@(shopped) forKey:@"shopped"] ;
            
            if ([wcsession isReachable]) {
                [wcsession sendMessage:upd replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"updateMark error: %@", error) ;
                }] ;
            } else {
                NSError *error = nil ;
                [wcsession updateApplicationContext:upd error:&error] ;
                if (error) {
                    NSLog(@"updateMark error: %@", error) ;
                }
            }
        }
        
        step = 1 ;
    }
    
    currentElement = [self stepBy:sharedArray current:currentElement step:step] ;
    
    [dict setObject:@(currentElement) forKey:@"currentElement"] ;
    [defaults setObject:dict forKey:@"shoplist"] ;
    
    NSDictionary *sharedCommodity = [sharedArray objectAtIndex:currentElement] ;
    [self.lblName setText:[sharedCommodity objectForKey:@"productName"]] ;
    [self.lblAmount setText:[NSString stringWithFormat:@"%@ %@.", [sharedCommodity objectForKey:@"amount"], NSLocalizedString(@"pcs", nil)]]   ;
    
    NSNumber *clr = [sharedCommodity objectForKey:@"categoryColor"] ;
    
    float red = ((float)((clr.intValue & 0xFF0000) >> 16)) / 255.0 ;
    float green = ((float)((clr.intValue & 0xFF00) >> 8)) / 255.0 ;
    float blue = ((float)(clr.intValue & 0xFF)) / 255.0 ;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0] ;
    
    [self.sepName setColor:color] ;
    
    if ([[sharedCommodity objectForKey:@"shopped"] boolValue]) {
        [self.btnMark setBackgroundImageNamed:@"shopped"] ;
    } else {
        [self.btnMark setBackgroundImageNamed:@"unshopped"] ;
    }
    
    [defaults synchronize] ;
    
    CLKComplicationServer *complicationServer = [CLKComplicationServer sharedInstance] ;
    for (CLKComplication *complication in complicationServer.activeComplications) {
        [complicationServer reloadTimelineForComplication:complication] ;
    }
    
    return YES ;
}

- (IBAction)prevTouched {
    [self configureView:-1 updateMark:NO] ;
}

- (IBAction)nextTouched {
    [self configureView:1 updateMark:NO] ;
}

- (IBAction)markTouched {
    [self configureView:0 updateMark:YES] ;
}

@end



