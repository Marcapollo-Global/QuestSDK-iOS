//
//  MQStore.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQStore.h"
#import "NSNull+Extension.h"

@implementation MQStore

+ (NSArray *) parseArray:(NSArray *)src
{
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:[src count]];
    
    for (id obj in src) {
        MQStore *store = [MQStore instantiateFromJSON:obj];
        [data addObject:store];
    }
    
    return data;
}

+ (instancetype) instantiateFromJSON:(id)json
{
    return [[MQStore alloc] initWithJSON:json];
}

- (instancetype) initWithJSON:(id)json
{
    self.uuid = [json valueForKey:@"store_uuid"];
    self.name = [json valueForKey:@"store_name"];
    self.intro = [json valueForKey:@"store_intro"];
    self.address = [json valueForKey:@"store_address"];
    self.booking = [json valueForKey:@"store_booking"];
    self.headerImg = [json valueForKey:@"store_headerimg"];
    self.listImg = [json valueForKey:@"store_listimg"];
    self.logo = [json valueForKey:@"store_logo"];
    self.note = [json valueForKey:@"store_note"];
    self.tel = [json valueForKey:@"store_tel"];
    self.website = [json valueForKey:@"store_website"];
    self.chat = [[json valueForKey:@"store_chat"] boolValue];
    self.flyer = [[json valueForKey:@"store_flyer"] boolValue];
    self.wifi = [[json valueForKey:@"store_wifi"] boolValue];
    self.icg = [[json valueForKey:@"store_icg"] boolValue];
    self.latitude = [[json valueForKey:@"store_latitude"] doubleValue];
    self.longitude = [[json valueForKey:@"store_longitude"] doubleValue];
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@\n%@", self.uuid, self.name];
}


@end
