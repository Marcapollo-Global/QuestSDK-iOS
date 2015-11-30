//
//  MQBeacon.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQBeacon.h"

@implementation MQBeacon

+ (NSArray *) parseArray:(NSArray *)src
{
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:[src count]];
    
    for (id obj in src) {
        MQBeacon *beacon = [MQBeacon instantiateFromJSON:obj];
        [data addObject:beacon];
    }
    
    return data;
}

+ (instancetype) instantiateFromJSON:(id)json
{
    return [[MQBeacon alloc] initWithJSON:json];
}

- (instancetype) initWithJSON:(id)json
{
    self.uuid = [json valueForKey:@"beacon_uuid"];
    self.major = [[json valueForKey:@"beacon_major"] integerValue];
    self.minor = [[json valueForKey:@"beacon_minor"] integerValue];
    self.tagName = [json valueForKey:@"beacon_tag_name"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    [copy setUuid:self.uuid];
    [copy setMajor:self.major];
    [copy setMinor:self.minor];
    
    return copy;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.uuid, @(self.major), @(self.minor)];
}

@end
