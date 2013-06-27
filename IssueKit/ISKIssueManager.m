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

- (void)setupWithReponame:(NSString *)reponame andAccessToken:(NSString *)accessToken {
    _apiClient = [[ISKGitHubIssueAPIClient alloc] initWithAPIToken:accessToken];

    _reponame = reponame;
}

- (void)presentIssueViewControllerOnViewController:(UIViewController *)viewController {
    NSAssert(_apiClient, @"-setupWithReponame must be called first.");
    
    ISKIssueViewController *issueViewController = [[ISKIssueViewController alloc] initWithStyle:UITableViewStyleGrouped];
    issueViewController.ownerController = (UIViewController *)viewController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:issueViewController];
    
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)createNewIssueWithTitle:(NSString *)title body:(NSString *)body success:(IssueCreateBlock)successBlock error:(IssueErrorBlock)errorBlock {
    NSAssert(_apiClient, @"-setupWithReponame must be called first.");
    
    ISKIssue *issue = [[ISKIssue alloc] init];
    issue.title = title;
    issue.body = body;
    issue.label = kIssueLabel;
    
    [_apiClient createLabel:issue.label onRepoWithName:self.reponame withHexColorString:kIssueColor success:^(NSString *issueName) {
        [_apiClient createIssue:issue onRepoWithName:self.reponame success:successBlock error:errorBlock];
    } error:^(NSError *error) {
        errorBlock(error);
    }];
}

@end
