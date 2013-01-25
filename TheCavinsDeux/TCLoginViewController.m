//
//  TCSecondViewController.m
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import "TCLoginViewController.h"
#import "RCConnectionHandler.h"
@interface TCLoginViewController ()

@end

@implementation TCLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushedLoginButton:(id)sender {
    
    [RCConnectionHandler requestJSONWithEndpoint:@"login"
                                      withMethod:@"POST"
                                        withArgs:@{ @"username":self.usernameTextField.text,
                                                    @"password":self.passwordTextField.text}
                                       withFiles:nil
                                       withOwner:self
                            withProgressCallback:nil     
                          withCompletionCallback:^(NSHTTPURLResponse *response, NSDictionary* json) {

                              if ([json objectForKey:@"login_required"]) {
                                  UIAlertView* alertView =
                                  [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                             message:@"Login failed"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                                  [alertView show];
                                  
                              }
                              else {
                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"user_logged_in"];
                                  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                              }
                          }
     ];
    
    
}
@end
