//
//  ScanBeaconListViewController.m
//  QuestSDK
//
//  Created by Shine Chen on 11/28/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "ScanBeaconListViewController.h"
#import <QuestSDK/QuestSDK.h>

@interface ScanBeaconListViewController () <MQMonitoringForBeaconDelegate>

@end

@implementation ScanBeaconListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Detecting";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [QuestSDK sharedInstance].monitoringDelegate = self;
    [[QuestSDK sharedInstance] startMonitoringForBeacon:self.beaconGroupToScan];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [QuestSDK sharedInstance].monitoringDelegate = nil;
    [[QuestSDK sharedInstance] stopMonitoringForBeacon:self.beaconGroupToScan];
}

#pragma mark - MQMonitoringForBeaconDelegate
- (void) questDidRangeBeacons:(NSArray<MQBeacon *> *)beacons
{
    self.beacons = beacons;
    
    [self.tableView reloadData];
}

@end
