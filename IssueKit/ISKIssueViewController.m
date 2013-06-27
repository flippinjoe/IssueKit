//
//  ISKIssueViewController.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKIssueViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ISKIssueManager.h"

@interface ISKIssueViewController ()
- (void)cancelButtonItemPressed:(id)action;
@end

@implementation ISKIssueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 0; i < 3; i++) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[NSString stringWithFormat:@"cell%d", i+1]];
    }
    
    self.title = [ISKIssueManager defaultManager].reponame;
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonItemPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) return @"Create a new issue";
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                static NSString *dequeueID = @"cell1";
                cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
                
                cell.textLabel.text = @"Title";
                [cell.textLabel sizeToFit];
            }
                break;
                
            case 1:
            {
                static NSString *dequeueID = @"cell2";
                cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
                
                cell.textLabel.text = @"Description";
                [cell.textLabel sizeToFit];
            }
                break;
                
            default:
                break;
        }
        
        CGFloat textFieldWidth = cell.frame.size.width - 20 * 2 - cell.textLabel.frame.size.width;
        CGFloat textFieldHeight = 40;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width - 20 - textFieldWidth, cell.frame.size.height / 2 - textFieldHeight / 2, textFieldWidth, textFieldHeight)];
        
        textField.tag = 100;
        textField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:textField];
        
        return cell;
    }
    
    else {
        static NSString *dequeueID = @"cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
        
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.backgroundColor = [UIColor clearColor];
        buttonLabel.font = cell.textLabel.font;
        buttonLabel.textColor = cell.textLabel.textColor;
        
        buttonLabel.text = @"Submit";
        
        [cell.contentView addSubview:buttonLabel];
        
        return cell;
    }

    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell viewWithTag:100];
    
    if (textField) {
        [textField becomeFirstResponder];
    }
    
    else {
        UITableViewCell *titleCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITableViewCell *descriptionCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        UITextField *titleTextField = (UITextField *)[titleCell viewWithTag:100];
        UITextField *descriptionTextField = (UITextField *)[descriptionCell viewWithTag:100];
        
        [SVProgressHUD showWithStatus:@"Submitting"];
        [[ISKIssueManager defaultManager] createNewIssueWithTitle:titleTextField.text body:descriptionTextField.text success:^(ISKIssue *issue) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Created issue %@", issue.identifier]];
            [self.ownerController dismissViewControllerAnimated:YES completion:nil];
        } error:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error submitting issue"];
        }];
    }
}

- (void)cancelButtonItemPressed:(id)action {
    [self.ownerController dismissViewControllerAnimated:YES completion:nil];
}


@end
