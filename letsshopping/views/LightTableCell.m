//
//  LightTableCell.m
//  goshopping
//
//  Created by Pavel Tsybulin on 20.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "LightTableCell.h"

@implementation LightTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIView *selectedView = [[UIView alloc] init] ;
    selectedView.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f] ;
    self.selectedBackgroundView = selectedView ;

    [super setSelected:selected animated:animated] ;
}

@end
