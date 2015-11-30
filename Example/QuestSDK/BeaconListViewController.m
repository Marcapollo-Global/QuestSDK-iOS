//
//  BeaconListViewController.m
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "BeaconListViewController.h"
#import <QuestSDK/QuestSDK.h>
#import <CoreLocation/CoreLocation.h>

#import "FlyerListViewController.h"
#import "NotificationListViewController.h"
#import "StoreListViewController.h"
#import "ScanBeaconListViewController.h"
#import "UIUtils.h"

@interface BeaconListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation BeaconListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Beacons";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beacons count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MQBeacon *beacon = [self.beacons objectAtIndex:indexPath.item];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"%@\n(%ld, %ld)", beacon.uuid, beacon.major, beacon.minor];
    if (beacon.tagName) {
        [content appendFormat:@"\n%@", beacon.tagName];
    }
    
    if (beacon.clBeacon) {
        [content appendFormat:@"\nrssi = %ld, proximity=%ld", beacon.clBeacon.rssi, beacon.clBeacon.proximity];
    }
    
    [cell.textLabel setText:content];
    
    [cell.textLabel sizeToFit];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MQBeacon *beacon = [self.beacons objectAtIndex:indexPath.item];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:beacon.uuid preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    // If raw CoreLocation CLBeacon is not available
    if (!beacon.clBeacon) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Scan" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self scan:beacon];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"List Flyers" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self listFlyers:beacon];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"List Notifications" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self listNotifications:beacon];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"List Stores" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self listStores:beacon];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Actions

- (void) listFlyers:(MQBeacon *)beacon
{
    if (!beacon.major || !beacon.minor) {
        beacon = [beacon copy];
        beacon.major = 1;
        beacon.minor = 1;
    }
    
    [[QuestSDK sharedInstance] listBeaconFlyers:beacon withComplete:^(NSArray *data, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
            [UIUtils alertError:error withParent:self];
            return;
        }
        
        [self showFlyers:data];
    }];
}

- (void) listNotifications:(MQBeacon *)beacon
{
    if (!beacon.major || !beacon.minor) {
        beacon = [beacon copy];
        beacon.major = 1;
        beacon.minor = 1;
    }
    
    [[QuestSDK sharedInstance] listBeaconNotifications:beacon withComplete:^(NSArray *data, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
            [UIUtils alertError:error withParent:self];
            return;
        }
        
        [self showNotifications:data];
        
    }];
}

- (void) listStores:(MQBeacon *) beacon
{
    if (!beacon.major || !beacon.minor) {
        beacon = [beacon copy];
        beacon.major = 1;
        beacon.minor = 1;
    }
    
    [[QuestSDK sharedInstance] listBeaconStores:beacon withComplete:^(NSArray *data, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [UIUtils alertError:error withParent:self];
            return;
        }
        
        [self showStores:data];
    }];
}

#pragma mark - Navigation

- (void) showFlyers:(NSArray *) flyers
{
    NSLog(@"%s", __FUNCTION__);
    FlyerListViewController *viewController = [[FlyerListViewController alloc] initWithNibName:@"FlyerListViewController" bundle:nil];
    
    viewController.flyers = flyers;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) showNotifications:(NSArray *)notifications
{
    NSLog(@"%s", __FUNCTION__);
    NotificationListViewController *viewController = [[NotificationListViewController alloc] initWithNibName:@"NotificationListViewController" bundle:nil];
    
    viewController.notifications = notifications;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) showStores:(NSArray *) stores
{
    NSLog(@"%s", __FUNCTION__);
    StoreListViewController *viewController = [[StoreListViewController alloc] initWithNibName:@"StoreListViewController" bundle:nil];
    viewController.stores = stores;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) scan:(MQBeacon *) beacon
{
    NSLog(@"%s", __FUNCTION__);
    
    ScanBeaconListViewController *viewController = [[ScanBeaconListViewController alloc] initWithNibName:@"BeaconListViewController" bundle:nil];
    viewController.beaconGroupToScan = beacon;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
