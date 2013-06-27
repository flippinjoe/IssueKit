//
//  ISKIssue.h
//  IssueKit
//
//  Created by Mert Dümenci on 6/27/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISKIssue : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *assignee;
@property (nonatomic, copy) NSString *label;

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSURL *URL;
@end
