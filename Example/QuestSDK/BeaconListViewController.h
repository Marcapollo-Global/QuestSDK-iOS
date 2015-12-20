//
//  BeaconListViewController.h
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MQBeacon;

@interface BeaconListViewController : UIViewController

@property (nonatomic, retain) NSArray *beacons;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (UITableViewCell *) tableView:(UITableView *)tableView cellForBeacon:(MQBeacon *)beacon;

@end
