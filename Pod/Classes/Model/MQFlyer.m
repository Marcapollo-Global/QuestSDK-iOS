//
//  MQFlyer.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQFlyer.h"
#import "QuestSDK_internal.h"

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
    self.beaconId = [json valueForKey:@"beacon_id"];
    self.order = [json valueForKey:@"beacon_flyers_order"];
    self.type = (MQFlyerType) [[json valueForKey:@"beacon_flyers_type"] integerValue];
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
    self.distance = [json valueForKey:@"beacon_flyers_distance"];
    self.isLogin = [json valueForKey:@"beacon_flyers_islogin"];
    self.isActivated = [json valueForKey:@"beacon_flyers_activate"];
    
    return self;
}

- (NSString *) content
{
    NSString *url;
    switch (self.type) {
        case MQFlyerTypeImage:
            url = [NSString stringWithFormat:[QuestSDK sharedInstance].urlBeaconFlyerImg, self.beaconId, self.distance, self.order, _content];
            break;
        case MQFlyerTypeVideo:
            url = _content;
        case MQFlyerTypeWeb:
        default:
            url = _content;
            break;
    }
    
    return url;
}

- (NSString *) audioFile
{
    if (!_audioFile || [_audioFile length] == 0) {
        return _audioFile;
    }
    
    return [NSString stringWithFormat:[QuestSDK sharedInstance].urlBeaconFlyerAudio, self.beaconId, self.distance, self.order, _audioFile];
}

- (NSString *) videoImageFile
{
    if (!_videoImageFile || [_videoImageFile length] == 0) {
        return _videoImageFile;
    }
    
    return [NSString stringWithFormat:[QuestSDK sharedInstance].urlBeaconFlyerVideoImg, self.beaconId, self.distance, self.order, _videoImageFile];
}

@end
