//
//  QuestSDK.m
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "QuestSDK.h"
#import "MQBeacon.h"
#import "MQFlyer.h"
#import "MQNotification.h"
#import "MQStore.h"

NSString * const kQuestSDKErrorDomain = @"QuestSDK";
NSString * const kQuestRequestErrorDomain = @"QuestQuery";
NSInteger const kQuestSDKErrorAppKeyNotSet = 1;
NSInteger const kQuestSDKErrorUnauthorized = 2;
NSInteger const kQuestSDKErrorResourceNotFound = 404;

const NSString *kQuestBeaconPropertyUUID = @"beacon_uuid";

const NSString *kSERVER_URL = @"http://localhost:3000/v1";

const NSString *kSDKVersion = @"0.1.2";

@interface QuestSDK() <CLLocationManagerDelegate>

@property (nonatomic, retain) NSString *userUUID;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appUUID;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, strong) CLLocationManager *locationManager;

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

+ (NSString *) sdkVersion
{
    return [kSDKVersion copy];
}

- (instancetype) init
{
    self.userUUID = [[NSUUID UUID] UUIDString];
    return self;
}

- (BOOL) isAuthorized
{
    if (!self.token || [self.token length] == 0) {
        return NO;
    }
    return YES;
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
        
        NSDictionary *latestSdkInfo = [responseObject valueForKey:@"latest_sdk"];
        if (latestSdkInfo) {
            NSString *latestSDKVersion = [latestSdkInfo valueForKey:@"version"];
            if (![kSDKVersion isEqualToString:latestSDKVersion]) {
                NSString *homepage = [latestSdkInfo valueForKey:@"homepage"];
                NSLog(@"!!!Attention!!!\nThe latest QuestSDK version is \"%@\", your current version is: \"%@\".\nFor more details, please visit %@",
                      latestSDKVersion, kSDKVersion, homepage);
            }
        }
        
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
    
    [self queryPath:[NSString stringWithFormat:@"beacons/%@/%@/%@/flyers/",
                     beacon.uuid,
                     @(beacon.major),
                     @(beacon.minor)]
   withSerializable:[MQFlyer class] completionHandler:complete];
}

- (void) listBeaconStores:(MQBeacon *)beacon withComplete:(QueryCompletionHandler) complete
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"beacons/%@/%@/%@/stores/",
                     beacon.uuid,
                     @(beacon.major),
                     @(beacon.minor)]
   withSerializable:[MQStore class] completionHandler:complete];
}

- (void) listBeaconNotifications:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete
{
    NSLog(@"%s", __FUNCTION__);
    
    [self queryPath:[NSString stringWithFormat:@"beacons/%@/%@/%@/notifications/",
                     beacon.uuid,
                     @(beacon.major),
                     @(beacon.minor)]
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

- (CLLocationManager *) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return _locationManager;
}

- (BOOL) checkOrAskForUserPermission
{
    // Check authorization status (with class method)
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"Location authorization status = %d", status);
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Location authorization status is not always, request user permission");
            [self.locationManager requestAlwaysAuthorization];
            return NO;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES;
        case kCLAuthorizationStatusDenied:
            NSLog(@"Location authorization status is denied, please change setting in iOS settings");
            return NO;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location authorization status is restricted, please change setting in iOS settings");
            return NO;
        default:
            return NO;
    }
}

- (void) startMonitoringForBeacon:(MQBeacon *)beacon
{
    NSLog(@"%s: %@", __FUNCTION__, beacon.uuid);
    
    // User has never been asked to decide on location authorization
    if (![self checkOrAskForUserPermission]) {
        NSLog(@"Requesting when in use auth");
        return;
    }
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"monitoring is not available for CLBeaconRegion");
        return;
    }
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beacon.uuid];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:beacon.description];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"start ranging");
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
    NSLog(@"start monitoring");
    [self.locationManager startMonitoringForRegion:beaconRegion];
}

- (void) stopMonitoringForBeacon:(MQBeacon *)beacon
{
    NSLog(@"%s: %@", __FUNCTION__, beacon.uuid);
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beacon.uuid];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:beacon.description];

    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

#pragma mark - CLLocationManagerDelegate

// Fail for region
- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"%s: %@, %@", __FUNCTION__, region.identifier, error);
}

// Enter region
- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s: %@", __FUNCTION__, region);
}

// Exit region
- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"%s: %@", __FUNCTION__, region);
}

// A new set of beacons are available in the specified region.
- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"%s", __FUNCTION__);
    
    if ([beacons count] <= 0) {
        NSLog(@"No beacons found");
        return;
    }
    
    if (!self.monitoringDelegate) {
        return;
    }
    
    NSMutableArray *outBeacons = [NSMutableArray arrayWithCapacity:[beacons count]];
    
    for (CLBeacon *beacon in beacons) {
        NSLog(@"beacon: %@", beacon);
        MQBeacon *mqBeacon = [[MQBeacon alloc] init];
        mqBeacon.uuid = [beacon.proximityUUID UUIDString];
        mqBeacon.major = [beacon.major integerValue];
        mqBeacon.minor = [beacon.minor integerValue];
        mqBeacon.clBeacon = beacon;
        [outBeacons addObject:mqBeacon];
    }
    
    if (self.monitoringDelegate && [self.monitoringDelegate respondsToSelector:@selector(questDidRangeBeacons:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.monitoringDelegate questDidRangeBeacons:outBeacons];
        });
    }
    
}

@end
