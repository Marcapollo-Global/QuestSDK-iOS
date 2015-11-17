//
//  StoreListViewController.m
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "StoreListViewController.h"
#import "BeaconListViewController.h"
#import "UIUtils.h"
#import <QuestSDK/QuestSDK.h>

@interface StoreListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation StoreListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stores count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MQStore *store = [self.stores objectAtIndex:indexPath.item];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"%@\n", store.uuid];
    [content appendFormat:@"%@\n", store.name];
    [content appendFormat:@"%@\n", store.address];
    [content appendFormat:@"%@\n", store.website];
    [content appendFormat:@"%f, %f\n", store.latitude, store.longitude];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [cell.textLabel setText:content];
    [cell.textLabel setNumberOfLines:0];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%s: %@", __FUNCTION__, indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self listStoreBeacons:[self.stores objectAtIndex:indexPath.item]];
}

#pragma mark - action
- (void) listStoreBeacons:(MQStore *)store
{
    NSLog(@"%s: %@", __FUNCTION__, store.uuid);
    
    [[QuestSDK sharedInstance] listStoreBeacons:store withComplete:^(NSArray *data, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [UIUtils alertError:error withParent:self];
            return;
        }
        
        [self showBeacons:data];
    }];
}

#pragma mark - Navigation

- (void) showBeacons:(NSArray *)beacons
{
    BeaconListViewController *viewController = [[BeaconListViewController alloc] initWithNibName:@"BeaconListViewController" bundle:nil];
    viewController.beacons = beacons;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
