//
//  UILocalizable+Localizable.m
//  KievTube
//
//  Created by Pavel Tsybulin on 06.11.2017.
//  Copyright © 2017 Pavel Tsybulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSObject+Localizable.h"

@implementation NSObject (Localizable)

- (NSString *)localize:(NSString *)string {
    if (![string hasPrefix:@"@"]) {
        return string ;
    }
    
    if ([string hasPrefix:@"@@"]) {
        return [string substringFromIndex:1] ;
    }
    
    return NSLocalizedString([string substringFromIndex:1], @"") ;
}

- (void)localize {
    
}

@end

@implementation UIView (Localizable)

- (void)localize {
    [super localize] ;
    
    for (UIView *subview in self.subviews) {
        [subview localize] ;
    }
}

@end

@implementation UILabel (Localizable)

- (void)localize {
    self.text = [self localize:self.text] ;
}

@end

@implementation UINavigationItem (Localizable)

- (void)localize {
    [super localize] ;
    self.title = [self localize:self.title] ;
    self.prompt = [self localize:self.prompt] ;
    [self.titleView localize] ;
    for (UIBarButtonItem *item in self.leftBarButtonItems) {
        [item localize] ;
    }
    for (UIBarButtonItem *item in self.rightBarButtonItems) {
        [item localize] ;
    }
    [self.backBarButtonItem localize] ;
}


@end

@implementation UIBarItem (Localizable)

- (void)localize {
    [super localize] ;
    self.title = [self localize:self.title] ;
}

@end


@implementation UIBarButtonItem (Localizable)

- (void)localize {
    [super localize] ;
    [self.customView localize] ;
}

@end

@implementation UIViewController (Localizable)
    
- (void)localize {
    self.title = [self.title localize:self.title] ;
    [self.navigationItem localize] ;
    [self.tabBarItem localize] ;
    [self.view localize] ;
}

@end

@implementation UIButton (Localizable)

- (void)localize {
    [super localize] ;
    [self setTitle:[self localize:[self titleForState:UIControlStateNormal]] forState:UIControlStateNormal] ;
    [self setTitle:[self localize:[self titleForState:UIControlStateHighlighted]] forState:UIControlStateHighlighted] ;
    [self setTitle:[self localize:[self titleForState:UIControlStateDisabled]] forState:UIControlStateDisabled] ;
    [self setTitle:[self localize:[self titleForState:UIControlStateSelected]] forState:UIControlStateSelected] ;
    [self setTitle:[self localize:[self titleForState:UIControlStateFocused]] forState:UIControlStateFocused] ;
}

@end

@implementation UITextField (Localizable)

- (void)localize {
    [super localize] ;
    self.placeholder = [self localize:self.placeholder] ;
}

@end

