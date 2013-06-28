//
//  ISKIssueManager.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKIssueManager.h"
#import "ISKIssueViewController.h"

@interface ISKIssueManager (private)

- (void)gestureRecognizerDidFire:(UITapGestureRecognizer *)gestureRecognizer;

@end

@implementation ISKIssueManager {
    ISKGitHubIssueAPIClient *_apiClient;
}

+ (instancetype)defaultManager {
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - API related things

- (void)setupWithReponame:(NSString *)reponame andAccessToken:(NSString *)accessToken {
    _apiClient = [[ISKGitHubIssueAPIClient alloc] initWithAPIToken:accessToken];

    _reponame = reponame;
}


- (void)createNewIssueWithTitle:(NSString *)title body:(NSString *)body success:(IssueCreateBlock)successBlock error:(IssueErrorBlock)errorBlock {
    NSAssert(_apiClient, @"-setupWithReponame must be called first.");
    
    ISKIssue *issue = [[ISKIssue alloc] init];
    issue.title = title;
    issue.body = body;
    issue.labels = @[kIssueLabel];
    
    [_apiClient createLabel:kIssueLabel onRepoWithName:self.reponame withHexColorString:kIssueColor success:^(NSString *issueName) {
        [_apiClient createIssue:issue onRepoWithName:self.reponame success:successBlock error:errorBlock];
    } error:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - View Controller related things

- (void)presentIssueViewControllerOnViewController:(UIViewController *)viewController {
    NSAssert(_apiClient, @"-setupWithReponame must be called first.");
    
    ISKIssueViewController *issueViewController = [[ISKIssueViewController alloc] initWithStyle:UITableViewStyleGrouped];
    issueViewController.ownerController = (UIViewController *)viewController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:issueViewController];
    
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)installGestureOnWindow:(UIWindow *)window {
    if (self.tapGestureRecognizer) return;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidFire:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;
    self.tapGestureRecognizer.numberOfTouchesRequired = 3;
    
    [window addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark Gesture Recognizer Callback

- (void)gestureRecognizerDidFire:(UITapGestureRecognizer *)gestureRecognizer {
    [self presentIssueViewControllerOnViewController:topMostController()];
}

/*
    Hacky way of finding topmost view controller.
    http://stackoverflow.com/questions/6131205/iphone-how-to-find-topmost-view-controller
*/

UIViewController *_topMostController(UIViewController *cont) {
    UIViewController *topController = cont;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    
    return (topController != cont ? topController : nil);
}

UIViewController *topMostController() {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *next = nil;
    
    while ((next = _topMostController(topController)) != nil) {
        topController = next;
    }
    
    return topController;
}

@end
