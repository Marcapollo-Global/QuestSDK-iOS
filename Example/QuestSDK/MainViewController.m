//
//  MainViewController.m
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MainViewController.h"
#import <QuestSDK/QuestSDK.h>

#import "BeaconListViewController.h"
#import "StoreListViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *rows;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *versionInfo;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"QuestSDK Demo";
    
    self.rows = [NSMutableArray arrayWithObjects:
                 @"Auth",
                 @"List application beacons",
                 @"List application stores",
                 nil];
    
    [self.versionInfo setText:[NSString stringWithFormat:@"Quest SDK Version: %@", [QuestSDK sdkVersion]]];
    
    [[QuestSDK sharedInstance] setAppKey:@"ec1a07a0-389c-11e4-b7f4-5b0b1df46947"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) log:(NSString *)msg
{
    [self.textView setText:[NSMutableString stringWithFormat:@"%@\n%@", self.textView.text, msg]];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length -1, 1)];
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![[QuestSDK sharedInstance] isAuthorized]) {
        return 1;
    }
    return [self.rows count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.rows objectAtIndex:indexPath.item];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell.textLabel setText:item];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s, %@", __FUNCTION__, indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.item) {
        case 0:
            [self auth];
            break;
        case 1:
            [self listAppBeacons];
            break;
        case 2:
            [self listAppStores];
            break;
        default:
            break;
    }
}

#pragma mark - QuestSDK

- (void) auth
{
    NSLog(@"%s", __FUNCTION__);
    
    [self log:@"auth"];
    
    [[QuestSDK sharedInstance] auth:^(NSError *error) {
        [self log:[NSString stringWithFormat:@"auth complete"]];
        if (error) {
            [self log:[error description]];
            return;
        }
        
        [self.tableView reloadData];
    }];
}

- (void) listAppBeacons
{
    NSLog(@"%s", __FUNCTION__);
    
    [self log:@"listAppBeacons"];
    
    [[QuestSDK sharedInstance] listAppBeacons:^(NSArray *data, NSError *error) {
        [self log:[NSString stringWithFormat:@"listAppBeacons complete"]];
        if (error) {
            [self log:[error description]];
            return;
        }
        
        [self log:[data description]];
        
        if (data) {
            [self showAppBeacons:data];
        }
    }];
}

- (void) listAppStores
{
    NSLog(@"%s", __FUNCTION__);
    
    [self log:@"listAppStores"];
    
    [[QuestSDK sharedInstance] listAppStores:^(NSArray *data, NSError *error) {
        
        if (error) {
            [self log:[error description]];
            return;
        }
        
        [self log:[data description]];
        
        if (data) {
            [self showAppStores:data];
        }
    }];
}

#pragma mark - Navigation
- (void) showAppBeacons:(NSArray *)beacons
{
    BeaconListViewController *viewController = [[BeaconListViewController alloc] initWithNibName:@"BeaconListViewController" bundle:nil];
    viewController.beacons = beacons;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) showAppStores:(NSArray *) stores
{
    StoreListViewController *viewController = [[StoreListViewController alloc] initWithNibName:@"StoreListViewController" bundle:nil];
    viewController.stores = stores;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
