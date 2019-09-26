//
//  AboutController.m
//  goshopping
//
//  Created by Pavel Tsybulin on 04.06.15.
//  Copyright (c) 2015 Pavel Tsybulin. All rights reserved.
//

#import "AboutController.h"
#import <MessageUI/MessageUI.h>
#import "NSObject+Localizable.h"

@interface AboutController ()  <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
- (IBAction)onSendTouch:(id)sender;

@end

@implementation AboutController

- (void)viewDidLoad {
    [super viewDidLoad] ;
    [self localize] ;
    
    self.lblVersion.text = [NSString stringWithFormat:@"%@ %@ (%@)", NSLocalizedString(@"Version", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSendTouch:(id)sender {
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init] ;
     mail.mailComposeDelegate = self ;
    [mail setSubject:self.lblVersion.text] ;
    [mail setToRecipients:@[@"Pavel Tsybulin <tsybulin@me.com>"]] ;
    [mail setMessageBody:@"Pavel, \n" isHTML:NO] ;
    [self presentViewController:mail animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL] ;
}

@end
