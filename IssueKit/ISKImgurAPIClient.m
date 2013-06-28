//
//  ISKImgurAPIClient.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/28/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKImgurAPIClient.h"
#import <NSData+Base64/NSData+Base64.h>

#define BASE_URL_STRING @"https://api.imgur.com/3/"

@implementation ISKImgurAPIClient {
    NSString *_clientID;
}

- (id)initWithClientID:(NSString *)clientID {
    NSParameterAssert(clientID);
    
    _clientID = clientID;
    
    self = [self initWithBaseURL:[NSURL URLWithString:BASE_URL_STRING]];
    if (!self) return nil;
    
    return self;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Client-ID %@", _clientID]];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return self;
}

- (void)uploadImage:(UIImage *)image success:(UploadSuccessfulBlock)successBlock error:(UploadFailedBlock)errorBlock {
    NSMutableDictionary *parameters = @{}.mutableCopy;
    parameters[@"image"] = [UIImageJPEGRepresentation(image, 0.7) base64EncodedString];
    parameters[@"type"] = @"base64";
    
    [self postPath:@"image" parameters:parameters.copy success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        
        if (error) {
            errorBlock(error);
            return;
        }
        
        else {
            successBlock([NSURL URLWithString:JSONDict[@"data"][@"link"]]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

@end
