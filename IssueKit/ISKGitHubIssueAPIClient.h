//
//  ISKGitHubIssueAPIClient.h
//  IssueKit
//
//  Created by Mert Dümenci on 6/27/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ISKIssue.h"

typedef void (^IssueCreateBlock)(ISKIssue*);
typedef void (^IssueErrorBlock)(NSError *);

typedef void (^LabelCreateBlock)(NSString*);
typedef void (^LabelErrorBlock)(NSError *);

@interface ISKGitHubIssueAPIClient : AFHTTPClient

- (instancetype)initWithAPIToken:(NSString *)token;

/*
    The repo name must be in username/repo format.
*/

- (void)createIssue:(ISKIssue *)issue onRepoWithName:(NSString *)repoName success:(IssueCreateBlock)successBlock error:(IssueErrorBlock)errorBlock;
- (void)createLabel:(NSString *)label onRepoWithName:(NSString *)repoName withHexColorString:(NSString *)hexColorString success:(LabelCreateBlock)successBlock error:(LabelErrorBlock)errorBlock;

@end
