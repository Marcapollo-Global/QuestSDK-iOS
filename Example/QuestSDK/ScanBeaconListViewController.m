//
//  ScanBeaconListViewController.m
//  QuestSDK
//
//  Created by Shine Chen on 11/28/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "ScanBeaconListViewController.h"
#import <QuestSDK/QuestSDK.h>

NSInteger const NEAREST_BEACON_SECTION = 0;
NSInteger const RANGIN_BEACONS_SECTION = 1;

@interface ScanBeaconListViewController () <MQMonitoringForBeaconDelegate>

@property (nonatomic, retain) MQBeacon *nearestBeacon;

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
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:RANGIN_BEACONS_SECTION];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) questDidDetectNearestBeacon:(MQBeacon *)beacon
{
    self.nearestBeacon = beacon;
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:NEAREST_BEACON_SECTION];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    switch (section) {
        case NEAREST_BEACON_SECTION:
            return @"Nearest";
            break;
        case RANGIN_BEACONS_SECTION:
            return @"Ranging";
            break;
        default:
            return @"";
            break;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NEAREST_BEACON_SECTION:
            return (self.nearestBeacon) ? 1 : 0;
            break;
        case RANGIN_BEACONS_SECTION:
            return [self.beacons count];
            break;
        default:
            return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MQBeacon *beacon;
    switch (indexPath.section) {
        case NEAREST_BEACON_SECTION:
            beacon = self.nearestBeacon;
            break;
        case RANGIN_BEACONS_SECTION:
            beacon = [self.beacons objectAtIndex:indexPath.item];;
            break;;
        default:
            beacon = nil;
            break;
    }
    
    return [self tableView:tableView cellForBeacon:beacon];
}

@end
