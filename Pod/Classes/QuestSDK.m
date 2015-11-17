//
//  QuestSDK.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "QuestSDK.h"
#import "MQBeacon.h"
#import "MQFlyer.h"
#import "MQNotification.h"
#import "MQStore.h"

NSString const *kQuestSDKErrorDomain = @"QuestSDK";
NSString const *kQuestRequestErrorDomain = @"QuestQuery";
NSInteger const kQuestSDKErrorAppKeyNotSet = 1;
NSInteger const kQuestSDKErrorUnauthorized = 2;
NSInteger const kQuestSDKErrorResourceNotFound = 404;

NSString const *kQuestBeaconPropertyUUID = @"beacon_uuid";

NSString const *kSERVER_URL = @"http://localhost:3000/v1";

@interface QuestSDK()

@property (nonatomic, retain) NSString *userUUID;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appUUID;
@property (nonatomic, retain) NSString *token;

@end

@implementation QuestSDK

static id _sharedInstance;


+ (instancetype) sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[QuestSDK alloc] init];
    }
    
    return _sharedInstance;
}

- (instancetype) init
{
    self.userUUID = [[NSUUID UUID] UUIDString];
    return self;
}

- (void) auth:(void(^)(NSError *))complete
{
    NSLog(@"%s", __FUNCTION__);
    
    // Check if app key is set
    if (!self.appKey) {
        NSLog(@"app key is not set");
        if (!complete) {
            complete([NSError errorWithDomain:kQuestSDKErrorDomain code:kQuestSDKErrorAppKeyNotSet userInfo:nil]);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/auth", kSERVER_URL];
    
    NSDictionary *params = @{@"app_key": self.appKey,
                             @"user_uuid": self.userUUID,
                             @"os": @"ios"
                             };
    
    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:params error:&error];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        self.appID = [responseObject valueForKey:@"app_id"];
        self.appUUID = [responseObject valueForKey:@"app_uuid"];
        self.token = [responseObject valueForKey:@"token"];
        
        if (complete) {
            complete(nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"Error: %@", error);
        
        if (complete) {
            complete(error);
        }
        
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void) queryPath:(NSString *)path withSerializable:(Class)class completionHandler:(QueryCompletionHandler)complete
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"paht: %@", path);
    NSLog(@"class: %@", class);
    
    // Check if token is set
    if (self.token == nil) {
        NSLog(@"Unauthorized");
        if (!complete) {
            complete(nil, [NSError errorWithDomain:kQuestSDKErrorDomain code:kQuestSDKErrorUnauthorized userInfo:nil]);
        }
        return;
    }
    
    if (![class conformsToProtocol:@protocol(MQJsonParsable)]) {
        NSLog(@"The serializable class does not confirm to protocol MQJsonParsable");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?token=%@",
                                       kSERVER_URL,
                                       path,
                                       self.token]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"Request completed\nJSON: %@", responseObject);
        
        NSArray *data = [class parseArray:[responseObject valueForKey:@"data"]];
        
        if (complete) {
            complete(data, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Request Error: %@", error);
        
        NSHTTPURLResponse *response = [[error userInfo] valueForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        
        if (!response) {
            if (complete) {
                complete(nil, error);
            }
            return;
        }
        
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        
        NSInteger errorCode = 0;
        NSString *errorMessage;
        if (serializedData) {
            errorCode = [[serializedData valueForKey:@"code"] integerValue];
            errorMessage = [serializedData valueForKey:@"message"];
        }
        
        if (!errorCode) {
            errorCode = response.statusCode;
        }
        if (!errorMessage) {
            errorMessage = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
        }

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
        
        switch (response.statusCode) {
            case kQuestSDKErrorResourceNotFound:
                [userInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
                break;
            default:
                break;
        }
        
        error = [NSError errorWithDomain:kQuestRequestErrorDomain code:response.statusCode userInfo:userInfo];
        
        if (complete) {
            complete(nil, error);
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void) listAppBeacons:(QueryCompletionHandler)complete;
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"apps/%@/beacons/", self.appUUID] withSerializable:[MQBeacon class] completionHandler:complete];
}

- (void) listBeaconFlyers:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"beacons/%@/%ld/%ld/flyers/",
                     beacon.uuid,
                     beacon.major,
                     beacon.minor]
   withSerializable:[MQFlyer class] completionHandler:complete];
}

- (void) listBeaconNotifications:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"beacons/%@/%ld/%ld/notifications/",
                     beacon.uuid,
                     beacon.major,
                     beacon.minor]
   withSerializable:[MQNotification class] completionHandler:complete];
}

- (void) listAppStores:(QueryCompletionHandler)complete;
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"apps/%@/stores/", self.appUUID] withSerializable:[MQStore class] completionHandler:complete];
}

- (void) listStoreBeacons:(MQStore *)store withComplete:(QueryCompletionHandler)complete
{
    [self queryPath:[NSString stringWithFormat:@"stores/%@/beacons/", store.uuid] withSerializable:[MQBeacon class] completionHandler:complete];
}


@end