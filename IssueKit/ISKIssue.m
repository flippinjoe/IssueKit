//
//  ISKIssue.m
//  IssueKit
//
//  Created by Mert Dümenci on 6/27/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "ISKIssue.h"

@implementation ISKIssue
/*
    No u, NSCoding
*/

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title":@"title",
             @"body":@"body",
             @"assignee":@"assignee",
             @"labels": @"labels",
             @"identifier" : @"number",
             @"URL": @"html_url"
             };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
} 

@end
