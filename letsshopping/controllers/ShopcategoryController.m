//
//  ShopcategoryController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 20.04.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "ShopcategoryController.h"

#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]

@interface ShopcategoryController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    __weak IBOutlet UIView *vwColor;
    NSArray *colors ;
    UIColor *color ;
}

@end

@implementation ShopcategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    colors = @[
        hsb(0, 0, 17), hsb(0, 0, 15),
        hsb(224, 50, 63), hsb(224, 56, 51),
        hsb(24, 45, 37), hsb(25, 45, 31),
        hsb(25, 31, 64), hsb(25, 34, 56),
        hsb(138, 45, 37), hsb(135, 44, 31),
        hsb(184, 10, 65), hsb(184, 10, 55),
        hsb(145, 77, 80), hsb(145, 78, 68),
        hsb(74, 70, 78), hsb(74, 81, 69),
        hsb(283, 51, 71), hsb(282, 61, 68),
        hsb(5, 65, 47), hsb(4, 68, 40),
        hsb(168, 86, 74), hsb(168, 86, 63),
        hsb(210, 45, 37), hsb(210, 45, 31),
        hsb(28, 85, 90), hsb(24, 100, 83),
        hsb(324, 49, 96), hsb(327, 57, 83),
        hsb(300, 45, 37), hsb(300, 46, 31),
        hsb(222, 24, 95), hsb(222, 28, 84),
        hsb(253, 52, 77), hsb(253, 56, 64),
        hsb(6, 74, 91), hsb(6, 78, 75),
        hsb(42, 25, 94), hsb(42, 30, 84),
        hsb(204, 76, 86), hsb(204, 78, 73),
        hsb(195, 55, 51), hsb(196, 54, 45),
        hsb(356, 53, 94), hsb(358, 61, 85),
        hsb(192, 2, 95), hsb(204, 5, 78),
        hsb(48, 99, 100), hsb(40, 100, 100)
    ] ;

    if (self.shopcategory) {
        self.nameField.text = self.shopcategory.name ;
        color = self.shopcategory.color ;
    } else {
        color = [UIColor grayColor] ;
    }
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0 ;
    [color getRed:&red green:&green blue:&blue alpha:&alpha] ;
    
    vwColor.backgroundColor = color ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1 ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [colors count] ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (UICollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [colors objectAtIndex:indexPath.row] ;
    cell.layer.cornerRadius = 3 ;
    cell.layer.masksToBounds = YES ;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize sz = collectionView.frame.size ;
    return CGSizeMake(sz.width / 4 - 2 , sz.width / 4 - 2) ;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *componentColor = [UIColor redColor] ;
    if (component == 1) {
        componentColor = [UIColor greenColor] ;
    } else if (component == 2) {
        componentColor = [UIColor blueColor] ;
    }
    
    return [[NSAttributedString alloc] initWithString:[NSNumber numberWithInteger:row].stringValue attributes:@{NSForegroundColorAttributeName : componentColor}] ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    color = [colors objectAtIndex:indexPath.row] ;
    vwColor.backgroundColor = color ;
}

- (IBAction)onRightNavButtonClick:(id)sender {
    if (self.shopcategory) {
        self.shopcategory.name = self.nameField.text ;
        
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0 ;
        [color getRed:&red green:&green blue:&blue alpha:&alpha] ;
        NSUInteger clr = ((int)(red*255) <<16) + ((int)(green*255) <<8) + (int)(blue*255) ;
        self.shopcategory.clr = [NSNumber numberWithUnsignedInteger:clr] ;
    }
    
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)hideKeyboard:(id)sender {
    [self.nameField resignFirstResponder] ;
}

@end
