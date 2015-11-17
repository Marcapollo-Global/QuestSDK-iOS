//
//  MQFlyer.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQFlyer.h"

@implementation MQFlyer

+ (NSArray *) parseArray:(NSArray *)src
{
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:[src count]];
    
    for (id obj in src) {
        MQFlyer *flyer = [MQFlyer instantiateFromJSON:obj];
        [data addObject:flyer];
    }
    
    return data;
}

+ (instancetype) instantiateFromJSON:(id)json
{
    return [[MQFlyer alloc] initWithJSON:json];
}

- (instancetype) initWithJSON:(id)json
{
    self.flyerId = [json valueForKey:@"beacon_flyers_id"];
    self.order = [json valueForKey:@"beacon_flyers_order"];
    self.type = [json valueForKey:@"beacon_flyers_type"];
    self.content = [json valueForKey:@"beacon_flyers_content"];
    self.audioFile = [json valueForKey:@"beacon_flyers_audio_file"];
    self.videoImageFile = [json valueForKey:@"beacon_flyers_videoimg_file"];
    self.textTitle = [json valueForKey:@"beacon_flyers_text_title"];
    if (!self.textTitle) {
        self.textTitle = @"";
    }
    self.textDescription = [json valueForKey:@"beacon_flyers_text_desc"];
    if (!self.textDescription) {
        self.textDescription = @"";
    }
    
    return self;
}

@end
