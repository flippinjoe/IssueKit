//
//  ISKImgurAPIClient.h
//  IssueKit
//
//  Created by Mert Dümenci on 6/28/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^UploadSuccessfulBlock)(NSURL* imageURL);
typedef void (^UploadFailedBlock)(NSError *error);

@interface ISKImgurAPIClient : AFHTTPRequestOperationManager

- (instancetype)initWithClientID:(NSString *)clientID;
- (void)uploadImage:(UIImage *)image success:(UploadSuccessfulBlock)successBlock error:(UploadFailedBlock)errorBlock;
@end
