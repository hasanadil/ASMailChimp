//
//  ASMailChimpDemo
//
//  Created by Hasan
//  Copyright (c) 2014 AssembleLabs.com All rights reserved.
//

#import "ViewController.h"
#import "ASMailChimp.h"

@interface ViewController ()

@property (weak) IBOutlet UITextField* apiKey;
@property (weak) IBOutlet UITextField* listId;
@property (weak) IBOutlet UITextField* email;

@end

@implementation ViewController

-(id) init
{
    return [super initWithNibName:@"ViewController" bundle:nil];
}

-(IBAction) tapSubscribe:(id)sender
{
    [ASMailChimp initializeWithApiKey:[self.apiKey text]];
    [[ASMailChimp sharedInstance] addSubscriberWithEmail:[self.email text] toList:[self.listId text] completion:^(id result, NSError *error) {
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:[error description]];
        }
        else {
            [self showAlertWithTitle:@"Success" andMessage:@"Subscribed"];
        }
    }];
}

-(IBAction) tapUnsubscribe:(id)sender
{
    [ASMailChimp initializeWithApiKey:[self.apiKey text]];
    [[ASMailChimp sharedInstance] removeSubscriberWithEmail:[self.email text] fromList:[self.listId text] completion:^(id result, NSError *error) {
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:[error description]];
        }
        else {
            [self showAlertWithTitle:@"Success" andMessage:@"Unsubscribed"];
        }
    }];
}

-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

@end
