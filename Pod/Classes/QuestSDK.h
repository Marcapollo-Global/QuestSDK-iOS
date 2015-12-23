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

FOUNDATION_EXPORT NSString * const kQuestBeaconPropertyUUID;

@protocol MQJsonParsable <NSObject>

+ (NSArray *) parseArray:(NSArray *)src;
+ (instancetype) instantiateFromJSON:(id)json;

@end

@class CLBeacon;

/**
 * MQBeacon presents a beacon get from server or detected from monitoring.
 */
@interface MQBeacon : NSObject<NSCopying, MQJsonParsable>

/**
 * Beacon UUID
 */
@property (nonatomic, copy) NSString *uuid;
/**
 * Major Number
 */
@property (nonatomic, assign) NSInteger major;
/**
 * Minor Number
 */
@property (nonatomic, assign) NSInteger minor;
/**
 * Tag name.
 */
@property (nonatomic, copy) NSString *tagName;
/**
 * The raw CoreLocation beacon. This property will be available if the beacon is detected from monitoring calls.
 * @see QuestSDK startMonitoringForBeacon:
 */
@property (nonatomic, retain) CLBeacon *clBeacon;

/**
 * Compare beacon by proximity and accuracy. The nearer one ordered accending.
 * @return comparison result.
 */
- (NSComparisonResult)compare:(MQBeacon *)other;

@end

typedef enum {
    MQFlyerTypeImage = 1,
    MQFlyerTypeVideo = 2,
    MQFlyerTypeWeb = 3,
} MQFlyerType;

typedef enum {
    MQFlyerDistanceImmediate = 1,
    MQFlyerDistanceNear = 2,
    MQFlyerDistanceFar = 4,
} MQFlyerDistance;

/**
 * MQFlyer presents a flyer associated to a beacon.
 */
@interface MQFlyer : NSObject <MQJsonParsable>

/**
 * Flyer ID.
 */
@property (nonatomic, copy) NSString *flyerId;
/**
 * The ID of the beacon which this flyer associated to.
 */
@property (nonatomic, copy) NSNumber *beaconId;
/**
 * Order in sorting.
 */
@property (nonatomic, copy) NSNumber *order;
/**
 * Flyer type.
 */
@property (nonatomic, assign) MQFlyerType type;
/**
 * Flyer content.
 */
@property (nonatomic, copy) NSString *content;
/**
 * Audio content.
 */
@property (nonatomic, copy) NSString *audioFile;
/**
 * Video preview image.
 */
@property (nonatomic, copy) NSString *videoImageFile;
/**
 * Text content title.
 */
@property (nonatomic, copy) NSString *textTitle;
/**
 * Text description.
 */
@property (nonatomic, copy) NSString *textDescription;
/**
 * What distance should the flyer to be presented.
 * Could be sum of MQFlyerDistance. @see MQFlyerDistance
 */
@property (nonatomic, copy) NSNumber *distance;
/**
 * Whether login is required to see this flyer.
 */
@property (nonatomic, copy) NSNumber *isLogin;
/**
 * Is this flyer activated.
 */
@property (nonatomic, copy) NSNumber *isActivated;
@end

/**
 * MQNotification presents a notification associated to a beacon.
 */
@interface MQNotification : NSObject <MQJsonParsable>
/**
 * Notification ID.
 */
@property (nonatomic, copy) NSString *notificationId;
/**
 * Notification message.
 */
@property (nonatomic, copy) NSString *message;

@end

/**
 * MQStore presents a store associated to the application.
 */
@interface MQStore : NSObject <MQJsonParsable>

/**
 * Store UUID.
 */
@property (nonatomic, copy) NSString *uuid;
/**
 * Store introduction.
 */
@property (nonatomic, copy) NSString *intro;
/**
 * Store address.
 */
@property (nonatomic, copy) NSString *address;
/**
 * Is booking available.
 */
@property (nonatomic, copy) NSString *booking;
/**
 * Header image.
 */
@property (nonatomic, copy) NSString *headerImg;
/**
 * Image used in list view.
 */
@property (nonatomic, copy) NSString *listImg;
/**
 * Logo image.
 */
@property (nonatomic, copy) NSString *logo;
/**
 * Store name.
 */
@property (nonatomic, copy) NSString *name;
/**
 * Store note.
 */
@property (nonatomic, copy) NSString *note;
/**
 * Store telephone number.
 */
@property (nonatomic, copy) NSString *tel;
/**
 * Store website url.
 */
@property (nonatomic, copy) NSString *website;
/**
 * Is chatting available.
 */
@property (nonatomic, assign) BOOL chat;
/**
 * Is flyer available.
 */
@property (nonatomic, assign) BOOL flyer;
/**
 * Is wifi available.
 */
@property (nonatomic, assign) BOOL wifi;
/**
 * Is ICG available.
 */
@property (nonatomic, assign) BOOL icg;
/**
 * Store location - latitude.
 */
@property (nonatomic, assign) double latitude;
/**
 * Store location - longitude.
 */
@property (nonatomic, assign) double longitude;

@end

/**
 * Delegate to receive beacon monitoring notifications.
 */
@protocol MQMonitoringForBeaconDelegate <NSObject>

@optional
/**
 * Did receive ranging beacons notification.
 *
 * @param beacons   Detected beacons with ranging info, which is in the raw CoreLocation beacon property. @see MQBeacon clBeacon.
 */
- (void) questDidRangeBeacons:(NSArray<MQBeacon *> *)beacons;

/**
 * Did detect nearest beacon
 * 
 * @param beacon The detect nearest beacon.
 */
- (void) questDidDetectNearestBeacon:(MQBeacon *)beacon;

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

/**
 * Beacon monitoring delegate.
 */
@property (nonatomic, retain) id<MQMonitoringForBeaconDelegate> monitoringDelegate;

@end
