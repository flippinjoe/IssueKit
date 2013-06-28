//
//  ISKIssueViewController.h
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface ISKIssueViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic, weak) UIViewController *ownerController;

@end
