//
//  MQFlyer.h
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuestSDK.h"

@interface MQFlyer() <MQJsonParsable>

+ (NSArray *) parseArray:(NSArray *)src;
+ (instancetype) instantiateFromJSON:(id)json;

@end
