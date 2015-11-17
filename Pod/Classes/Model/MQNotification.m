//
//  MQNotification.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQNotification.h"

@implementation MQNotification

+ (NSArray *) parseArray:(NSArray *)src
{
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:[src count]];
    
    for (id obj in src) {
        MQNotification *notification = [MQNotification instantiateFromJSON:obj];
        [data addObject:notification];
    }
    
    return data;
}

+ (instancetype) instantiateFromJSON:(id)json
{
    return [[MQNotification alloc] initWithJSON:json];
}

- (instancetype) initWithJSON:(id)json
{
    self.notificationId = [json valueForKey:@"notification_beacon_id"];
    self.message = [json valueForKey:@"notification_beacon_msg"];
    
    return self;
}

@end
