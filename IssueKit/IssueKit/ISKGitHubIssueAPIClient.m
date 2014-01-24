//
//  ISKGitHubIssueAPIClient.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/27/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKGitHubIssueAPIClient.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#define BASE_URL_STRING @"https://api.github.com/"

@implementation ISKGitHubIssueAPIClient {
    @private
    NSString *_apiToken;
}

- (id)initWithAPIToken:(NSString *)token {
    NSParameterAssert(token);
    
    self = [self initWithBaseURL:[NSURL URLWithString:BASE_URL_STRING]];
    if (!self) return nil;
    
    _apiToken = token;
    return self;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) return nil;
    
    [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [self setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
    [self.requestSerializer setValue:@"application/vnd.github.beta+json" forHTTPHeaderField:@"Accept"];
    
//    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    [self setDefaultHeader:@"Accept" value:@"application/vnd.github.beta+json"];
//    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return self;
}

- (void)createIssue:(ISKIssue *)issue onRepoWithName:(NSString *)repoName success:(IssueCreateBlock)successBlock error:(IssueErrorBlock)errorBlock {
    NSMutableString *path = @"repos".mutableCopy;
    [path appendFormat:@"/%@", repoName];
    [path appendFormat:@"/issues?access_token=%@", _apiToken];

    NSMutableDictionary *parameters = @{}.mutableCopy;
    if (issue.title) parameters[@"title"] = issue.title;
    if (issue.body) parameters[@"body"] = issue.body;
    if (issue.assignee) parameters[@"assignee"] = issue.assignee;
    if (issue.labels) parameters[@"labels"] = issue.labels;
    
    [self POST:path.copy parameters:parameters.copy success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        id JSONObject = responseObject;
//        id JSONObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        
        if (error) {
            errorBlock(error);
            return;
        }
        
        issue.URL = [NSURL URLWithString:JSONObject[@"html_url"]];
        issue.identifier = JSONObject[@"number"];
        successBlock(issue);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)createLabel:(NSString *)label onRepoWithName:(NSString *)repoName withHexColorString:(NSString *)hexColorString success:(LabelCreateBlock)successBlock error:(LabelErrorBlock)errorBlock {
    NSMutableString *path = @"repos".mutableCopy;
    [path appendFormat:@"/%@", repoName];
    [path appendFormat:@"/labels?access_token=%@", _apiToken];
    
    NSMutableDictionary *parameters = @{}.mutableCopy;
    if (label) parameters[@"name"] = label;
    if (hexColorString) parameters[@"color"] = hexColorString;
    
    [self POST:path.copy parameters:parameters.copy success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        id JSONObject = responseObject;
//        id JSONObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        
        if (error) {
            errorBlock(error);
            return;
        }
        
        successBlock(JSONObject[@"name"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /*
            If the label already exists (422)
        */
        
        if (operation.response.statusCode == 422) successBlock(label);
        else errorBlock(error);
    }];

}

@end
