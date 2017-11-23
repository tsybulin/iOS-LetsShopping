//
//  ComplicationController.m
//  WatchApp Extension
//
//  Created by Pavel Tsybulin on 23.11.2017.
//  Copyright © 2017 Pavel Tsybulin. All rights reserved.
//

#import "ComplicationController.h"

@implementation ComplicationController

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone) ;
}

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    NSDictionary<NSString *, id> *dict = [defaults objectForKey:@"shoplist"] ;
    NSArray<NSDictionary *> *commodities = [dict objectForKey:@"commodities"] ;

    if (!commodities) {
        handler(nil) ;
        return ;
    }
    
    if (commodities.count < 1) {
        handler(nil) ;
        return ;
    }
    
    int unshopped = 0 ;
    for (NSDictionary *commodity in commodities) {
        if (![[commodity objectForKey:@"shopped"] boolValue]) {
            unshopped++ ;
        }
    }
    
    NSInteger currentElement = [[dict objectForKey:@"currentElement"] integerValue] ;

    CLKComplicationTimelineEntry *complicationEntry = nil ;

    if (complication.family == CLKComplicationFamilyModularSmall) {
        CLKComplicationTemplateModularSmallStackImage *template = [[CLKComplicationTemplateModularSmallStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_modular_small"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithFormat:@"%d", unshopped] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init] ;
        template.headerImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_modular_large"]] ;
        NSNumber *clr = [[commodities objectAtIndex:currentElement] objectForKey:@"categoryColor"] ;
        float red = ((float)((clr.intValue & 0xFF0000) >> 16)) / 255.0 ;
        float green = ((float)((clr.intValue & 0xFF00) >> 8)) / 255.0 ;
        float blue = ((float)(clr.intValue & 0xFF)) / 255.0 ;
        template.headerImageProvider.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0] ;
        template.headerTextProvider = [CLKSimpleTextProvider textProviderWithFormat:@"%d", unshopped] ;
        template.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:[[commodities objectAtIndex:currentElement] objectForKey:@"productName"]] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmall) {
        CLKComplicationTemplateUtilitarianSmallRingImage *template = [[CLKComplicationTemplateUtilitarianSmallRingImage alloc] init] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_small"]] ;
        template.ringStyle = CLKComplicationRingStyleClosed ;
        template.fillFraction = ((float) unshopped / (float) commodities.count) ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmallFlat) {
        CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init] ;
        template.textProvider =  [CLKSimpleTextProvider textProviderWithFormat:@"%d", unshopped] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_flat"]] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianLarge) {
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
        template.textProvider =  [CLKSimpleTextProvider textProviderWithText:[[commodities objectAtIndex:currentElement] objectForKey:@"productName"]] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_flat"]] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyCircularSmall) {
        CLKComplicationTemplateCircularSmallStackImage *template = [[CLKComplicationTemplateCircularSmallStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_circular_small"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithFormat:@"%d", unshopped] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    } else if (complication.family == CLKComplicationFamilyExtraLarge) {
        CLKComplicationTemplateExtraLargeStackImage *template = [[CLKComplicationTemplateExtraLargeStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_extra_large"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithFormat:@"%d", unshopped] ;
        complicationEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    }
    
    handler(complicationEntry) ;
}

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    CLKComplicationTemplate *complicationTemplate = nil ;
    
    if (complication.family == CLKComplicationFamilyModularSmall) {
        CLKComplicationTemplateModularSmallStackImage *template = [[CLKComplicationTemplateModularSmallStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_modular_small"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"6" shortText:@"6"] ;
    } else if (complication.family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init] ;
        template.headerImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_modular_large"]] ;
        template.headerImageProvider.tintColor = [UIColor blueColor] ;
        template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"6" shortText:@"6"];
        template.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NSLocalizedString(@"Cucumber", nil)  shortText:NSLocalizedString(@"Cucumber", nil)] ;
        complicationTemplate = template ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmall) {
        CLKComplicationTemplateUtilitarianSmallRingImage *template = [[CLKComplicationTemplateUtilitarianSmallRingImage alloc] init] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_small"]] ;
        template.ringStyle = CLKComplicationRingStyleClosed ;
        template.fillFraction = 0.5f ;
        complicationTemplate = template ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmallFlat) {
        CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init] ;
        template.textProvider =  [CLKSimpleTextProvider textProviderWithText:@"6" shortText:@"6"] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_flat"]] ;
        complicationTemplate = template ;
    } else if (complication.family == CLKComplicationFamilyUtilitarianLarge) {
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
        template.textProvider =  [CLKSimpleTextProvider textProviderWithText:NSLocalizedString(@"Cucumber", nil) shortText:NSLocalizedString(@"Cucumber", nil)] ;
        template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_utilitarian_flat"]] ;
        complicationTemplate = template ;
    } else if (complication.family == CLKComplicationFamilyCircularSmall) {
        CLKComplicationTemplateCircularSmallStackImage *template = [[CLKComplicationTemplateCircularSmallStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_circular_small"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"6" shortText:@"6"] ;
        complicationTemplate = template ;
    } else if (complication.family == CLKComplicationFamilyExtraLarge) {
        CLKComplicationTemplateExtraLargeStackImage *template = [[CLKComplicationTemplateExtraLargeStackImage alloc] init] ;
        template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"complication_extra_large"]] ;
        template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"6" shortText:@"6"] ;
        complicationTemplate = template ;
    }
    
    handler(complicationTemplate) ;
}

@end
