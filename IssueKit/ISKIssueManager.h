//
//  ISKIssueManager.h
//  IssueKit
//
//  Created by Mert Dümenci on 6/26/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISKGitHubIssueAPIClient.h"

#define kIssueLabel @"IssueKit"
#define kIssueColor @"3f61ff"

@interface ISKIssueManager : NSObject
@property (nonatomic, readonly) NSString *reponame;

+ (instancetype)defaultManager;

/*
    The repo name must be in username/repo format.
    Get an API Access Token from https://github.com/settings/applications
 */

- (void)setupWithReponame:(NSString *)reponame andAccessToken:(NSString *)accessToken;

- (void)presentIssueViewControllerOnViewController:(UIViewController *)viewController;
- (void)createNewIssueWithTitle:(NSString *)title body:(NSString *)body success:(IssueCreateBlock)successBlock error:(IssueErrorBlock)errorBlock;

@end
