//
//  QuestSDK.h
//  QuestSDK
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>

// In this header, you should import all the public headers of your framework using statements like #import <QuestSDK/PublicHeader.h>

FOUNDATION_EXPORT NSString * const kQuestSDKErrorDomain;
FOUNDATION_EXPORT NSString * const kQuestRequestErrorDomain;

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

/**
 * Your App key to access Marcapollo Quest
 */
@property (nonatomic, copy) NSString *appKey;

/**
 * Returns global shared instance.
 * @return QuestSDK global instance.
 */
+ (instancetype) sharedInstance;

/**
 * Returns SDK version
 * @return QuestSDK version
 */
+ (NSString *) sdkVersion;

/**
 * Checks if authorization is performed and passed. Once authrozed, you can continue to access the Quest Web Services.
 * @return If authorized by Server.
 */
- (BOOL) isAuthorized;

/**
 * Request for authorization.
 * @param complete  The completion handler.
 */
- (void) auth:(void(^)(NSError *))complete;

/**
 * List beacons owned by this application.
 */
- (void) listAppBeacons:(QueryCompletionHandler)complete;

/**
 * List flyers of a specified beacon
 * @param beacon    The beacon to list for flyers.
 */
- (void) listBeaconFlyers:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete;

/**
 * List notifications of a specified beacon
 * @param beacon    The beacon to list for notifications.
 */
- (void) listBeaconNotifications:(MQBeacon *)beacon withComplete:(QueryCompletionHandler)complete;

/**
 * List store(s) the specified beacon blongs to.
 * @param beacon    The beacon to list stores it belongs to.
 */
- (void) listBeaconStores:(MQBeacon *)beacon withComplete:(QueryCompletionHandler) complete;

/**
 * List stores owned by this application
 */
- (void) listAppStores:(QueryCompletionHandler)complete;

/**
 * Lits beacons in a specified store.
 * @param store The store to list for beacons.
 */
- (void) listStoreBeacons:(MQStore *)store withComplete:(QueryCompletionHandler)complete;

/**
 * Check if user authorized permissions related to detecting beacons.
 * Present dialog to ask user for permissions if user has not decided yet.
 */
- (BOOL) checkOrAskForUserPermission;

/**
 * Start monitoring for beacon(s).
 * @param beacon    Beacon or beacon gorup to monitor.
 */
- (void) startMonitoringForBeacon:(MQBeacon *)beacon;

/**
 * Stop monitoring for beacon(s).
 * @param beacon    Beacon or beacon gorup to monitor.
 */
- (void) stopMonitoringForBeacon:(MQBeacon *)beacon;

@property (nonatomic, retain) id<MQMonitoringForBeaconDelegate> monitoringDelegate;

@end
