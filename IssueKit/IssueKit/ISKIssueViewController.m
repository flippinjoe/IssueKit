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

#import <Mantle/Mantle.h>

/*
    Sorry for this nasty macro. iOS 6 cells don't like to give the font & frame size of it's text label before it gets added to the view hierarchy. :(
*/

#define IS_IOS7 !([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)

@interface ISKIssueViewController ()
- (void)cancelButtonItemPressed:(id)action;
@end

@implementation ISKIssueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 0; i < 2; i++) {
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
        static NSString *dequeueID = @"cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
        
        cell.textLabel.text = indexPath.row == 0 ? @"Title" : @"Description";
        [cell.textLabel sizeToFit];
        
        CGSize textLabelSize = cell.textLabel.frame.size;
        
        if (!IS_IOS7) {
            CGSize fontSize = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.f]];
            textLabelSize = CGSizeMake(fontSize.width + 8, fontSize.height);
        }
        
        CGFloat textFieldWidth = cell.frame.size.width - 20 * 2 - textLabelSize.width;
        CGFloat textFieldHeight = 40;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 20 - textFieldWidth, cell.contentView.bounds.size.height / 2 - textFieldHeight / 2, textFieldWidth, textFieldHeight)];
        
        textField.tag = 100;
        textField.textAlignment = NSTextAlignmentRight;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [cell.contentView addSubview:textField];
        
        return cell;
    }
    
    else {
        static NSString *dequeueID = @"cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
        
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.backgroundColor = [UIColor clearColor];
        
        if (IS_IOS7) {
            buttonLabel.font = cell.textLabel.font;
            buttonLabel.textColor = cell.textLabel.textColor;
        }
    
        else {
            buttonLabel.font = [UIFont boldSystemFontOfSize:18.f];
            buttonLabel.textColor = [UIColor blackColor];
        }
        
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
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
