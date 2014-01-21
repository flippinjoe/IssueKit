//
//  ISKIssueViewController.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKIssueViewController.h"
#import "ISKIssueManager.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <BlocksKit/BlocksKit+UIKit.h>

/*
 Sorry for this nasty macro. iOS 6 cells don't like to give the font & frame size of it's text label before it gets added to the view hierarchy. :(
 */

#define IS_IOS7 !([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)

@interface ISKIssueViewController ()
- (void)cancelButtonItemPressed:(id)action;
@end

@implementation ISKIssueViewController {
    UIPopoverController *_popoverController;
    UIImage *_selectedImage;
}

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
    if ([ISKIssueManager defaultManager].hasImageUploads) return section == 0? 3 : 1;
    else return section == 0? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) return @"Create a new issue";
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            static NSString *dequeueID = @"cell1";
            cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
            
            cell.textLabel.text = indexPath.row == 0 ? @"Title" : @"Description";
            [cell.textLabel sizeToFit];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGSize textLabelSize = cell.textLabel.frame.size;
            
            if (!IS_IOS7) {
                CGSize fontSize = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.f]];
                textLabelSize = CGSizeMake(fontSize.width + 8, fontSize.height);
            }
            
            float offset = 20*2;
            CGFloat textFieldWidth = cell.contentView.bounds.size.width - offset - textLabelSize.width;
            CGFloat textFieldHeight = 40;
            
            CGRect rect = CGRectZero;
            rect.origin.x = cell.contentView.bounds.size.width - 20 - textFieldWidth;
            rect.origin.y = cell.contentView.bounds.size.height / 2 - textFieldHeight / 2;
            rect.size.height = textFieldHeight;
            rect.size.width = cell.contentView.bounds.size.width - rect.origin.x - 10;
            UITextField *textField = [[UITextField alloc] initWithFrame:rect];
            textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
            textField.tag = 100;
            textField.textAlignment = NSTextAlignmentRight;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            [cell.contentView addSubview:textField];
            
            return cell;
        }
        
        else {
            static NSString *dequeueID = @"cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = @"Image upload";
            [cell.textLabel sizeToFit];
            
            if (_selectedImage) {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            else {
                UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                accessoryButton.userInteractionEnabled = NO;
                cell.accessoryView = accessoryButton;
            }
            
            return cell;
        }
    }
    
    else {
        static NSString *dequeueID = @"cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:dequeueID forIndexPath:indexPath];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.bounds = CGRectMake(0, 0, cell.textLabel.superview.bounds.size.width, cell.textLabel.superview.bounds.size.height);
        
        cell.textLabel.text = @"Submit";
        
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
    
    else if (indexPath.section == 0 && indexPath.row == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image upload" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        if (_selectedImage) {
            [actionSheet bk_setDestructiveButtonWithTitle:@"Delete existing photo" handler:^{
                _selectedImage = nil;
                [[NSFileManager defaultManager] removeItemAtPath:tempImageURL().path error:nil];
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }];
            
            [actionSheet bk_addButtonWithTitle:@"View existing photo" handler:^{
                QLPreviewController *previewController = [[QLPreviewController alloc] init];
                previewController.dataSource = self;
                previewController.delegate = self;
                
                [self.navigationController pushViewController:previewController animated:YES];
            }];
        }
        
        else {
            
            void (^ShowPickerController)(UIImagePickerControllerSourceType sourceType) = ^(UIImagePickerControllerSourceType sourceType) {
                UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.sourceType = sourceType;
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    _popoverController = [[UIPopoverController alloc] initWithContentViewController:pickerController];
                    [_popoverController presentPopoverFromRect:cell.frame
                                                        inView:cell.superview
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
                }
                else
                { [self presentViewController:pickerController animated:YES completion:nil]; }
            };
            
            [actionSheet bk_addButtonWithTitle:@"Take a photo" handler:^{
                ShowPickerController(UIImagePickerControllerSourceTypeCamera);
            }];
            
            [actionSheet bk_addButtonWithTitle:@"Pick a photo" handler:^{
                ShowPickerController(UIImagePickerControllerSourceTypePhotoLibrary);
            }];
        }
        
        [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [actionSheet showInView:self.tableView];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    else {
        UITableViewCell *titleCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITableViewCell *descriptionCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        UITextField *titleTextField = (UITextField *)[titleCell viewWithTag:100];
        UITextField *descriptionTextField = (UITextField *)[descriptionCell viewWithTag:100];
        
        [SVProgressHUD showWithStatus:@"Submitting"];
        
        void (^SuccessBlock)(ISKIssue *issue) = ^(ISKIssue *issue) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Created issue %@", issue.identifier]];
            [self.ownerController dismissViewControllerAnimated:YES completion:nil];
        };
        
        void (^ErrorBlock)(NSError *error) = ^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error submitting issue"];
        };
        
        if (_selectedImage) {
            [[ISKIssueManager defaultManager] createNewIssueWithTitle:titleTextField.text body:descriptionTextField.text image:_selectedImage success:SuccessBlock error:ErrorBlock];
        }
        
        else {
            [[ISKIssueManager defaultManager] createNewIssueWithTitle:titleTextField.text body:descriptionTextField.text success:SuccessBlock error:ErrorBlock];
        }
    }
}

- (void)cancelButtonItemPressed:(id)action {
    [self.ownerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // iPad should dismiss it's popoverController instead of dismissing
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    { [_popoverController dismissPopoverAnimated:YES]; }
    else
    { [self dismissViewControllerAnimated:YES completion:nil]; }
    
    _selectedImage = info[UIImagePickerControllerOriginalImage];
    
    [UIImageJPEGRepresentation(_selectedImage, 0.7) writeToFile:tempImageURL().path atomically:YES];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - Quick Look

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return tempImageURL();
}

NSURL *tempImageURL () {
    NSURL *tempDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    return [[tempDirURL URLByAppendingPathComponent:@"Selected Image"] URLByAppendingPathExtension:@"jpg"];
}


@end
