//
//  TCStreamViewController.m
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/15/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import "TCStreamViewController.h"
#import "RCConnectionHandler.h"

@interface TCStreamViewController ()

@end

@implementation TCStreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"login_required" object:nil];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateWebView];
}

- (void)updateWebView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_logged_in"])
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_DOMAIN]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login
{
    [self performSegueWithIdentifier:@"login" sender:self];
    [self updateWebView];
}

@end
