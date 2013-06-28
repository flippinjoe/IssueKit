//
//  ISKViewController.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKViewController.h"
#import "IssueKit.h"

@interface ISKViewController ()

@end

@implementation ISKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (IBAction)showIssueViewController:(id)sender {
    [[ISKIssueManager defaultManager] presentIssueViewControllerOnViewController:self];
}

@end
