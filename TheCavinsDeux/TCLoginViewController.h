//
//  TCSecondViewController.h
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)pushedLoginButton:(id)sender;

@end
