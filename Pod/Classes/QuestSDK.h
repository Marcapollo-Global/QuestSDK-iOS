//
//  QuestSDK.h
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>

// In this header, you should import all the public headers of your framework using statements like #import <QuestSDK/PublicHeader.h>

FOUNDATION_EXPORT NSString *kQuestSDKErrorDomain;
FOUNDATION_EXPORT NSString *kQuestRequestErrorDomain;

FOUNDATION_EXPORT NSInteger const kQuestSDKErrorAppKeyNotSet;
FOUNDATION_EXPORT NSInteger const kQuestSDKErrorUnauthorized;
FOUNDATION_EXPORT NSInteger const kQuestSDKErrorResourceNotFound;

FOUNDATION_EXPORT NSString *kQuestBeaconPropertyUUID;

@protocol MQJsonParsable <NSObject>

+ (NSArray *) parseArray:(NSArray *)src;
+ (instancetype) instantiateFromJSON:(id)json;

@end

@class CLBeacon;

@interface MQBeacon : NSObject<NSCopying, MQJsonParsable>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;
@property (nonatomic, copy) NSString *tagName;
// The detected raw CoreLocation beacon
@property (nonatomic, retain) CLBeacon *clBeacon;

@end

@interface MQFlyer : NSObject <MQJsonParsable>

@property (nonatomic, copy) NSString *flyerId;
@property (nonatomic, copy) NSString *order;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *audioFile;
@property (nonatomic, copy) NSString *videoImageFile;
@property (nonatomic, copy) NSString *textTitle;
@property (nonatomic, copy) NSString *textDescription;

@end

@interface MQNotification : NSObject <MQJsonParsable>

@property (nonatomic, copy) NSString *notificationId;
@property (nonatomic, copy) NSString *message;

@end

@interface MQStore : NSObject <MQJsonParsable>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *booking;
@property (nonatomic, copy) NSString *headerImg;
@property (nonatomic, copy) NSString *listImg;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, assign) BOOL chat;
@property (nonatomic, assign) BOOL flyer;
@property (nonatomic, assign) BOOL wifi;
@property (nonatomic, assign) BOOL icg;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end

@protocol MQMonitoringForBeaconDelegate <NSObject>

- (void) questDidRangeBeacons:(NSArray<MQBeacon *> *)beacons;

@end

typedef void (^QueryCompletionHandler)(NSArray *, NSError *);

@interface QuestSDK : NSObject

@property (nonatomic, copy) NSString *appKey;

+ (instancetype) sharedInstance;

- (BOOL) isAuthorized;

- (void) auth:(void(^)(NSError *))complete;

// List application beacons
- (void) listAppBeacons:(QueryCompletionHandler)complete;

// List beacon flyers
- (void) listBeaconFlyers:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete;

// List beacon notifications
- (void) listBeaconNotifications:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete;

// List beacon stores
- (void) listBeaconStores:(MQBeacon *)beacon withComplete:(QueryCompletionHandler) complete;

// List application stores
- (void) listAppStores:(QueryCompletionHandler)complete;

// Lits store beacons
- (void) listStoreBeacons:(MQStore *)store withComplete:(QueryCompletionHandler)complete;

- (BOOL) checkOrAskForUserPermission;

// Start monitoring for beacon
- (void) startMonitoringForBeacon:(MQBeacon *)beacon;
// Stop monitoring for beacon
- (void) stopMonitoringForBeacon:(MQBeacon *)beacon;

@property (nonatomic, retain) id<MQMonitoringForBeaconDelegate> monitoringDelegate;

@end
