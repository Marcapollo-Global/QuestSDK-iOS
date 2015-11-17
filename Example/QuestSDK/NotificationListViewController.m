//
//  NotificationListViewController.m
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "NotificationListViewController.h"
#import <QuestSDK/QuestSDK.h>

@interface NotificationListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation NotificationListViewController

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
    return [self.notifications count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MQNotification *notification = [self.notifications objectAtIndex:indexPath.item];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    [cell.textLabel setText:notification.message];
    [cell.textLabel setNumberOfLines:0];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
