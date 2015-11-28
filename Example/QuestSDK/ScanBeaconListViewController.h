//
//  ScanBeaconListViewController.h
//  QuestSDK
//
//  Created by Shine Chen on 11/28/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconListViewController.h"

@class MQBeacon;

@interface ScanBeaconListViewController : BeaconListViewController

@property (nonatomic, retain) MQBeacon *beaconGroupToScan;

@end
