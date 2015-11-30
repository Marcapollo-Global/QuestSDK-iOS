//
//  FlyerListViewController.m
//  QuestDemo
//
//  Created by Shine Chen on 11/16/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "FlyerListViewController.h"
#import "MQFlyerTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuestSDK/QuestSDK.h>

@interface FlyerListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FlyerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Flyers";
    
    [self.tableView registerNib:[MQFlyerTableViewCell nib] forCellReuseIdentifier:[MQFlyerTableViewCell reuseIdentifier]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flyers count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MQFlyer *flyer = [self.flyers objectAtIndex:indexPath.item];
    
    MQFlyerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MQFlyerTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendFormat:@"%@\n", flyer.flyerId];
    [content appendFormat:@"%@\n", flyer.content];
    [content appendFormat:@"%@\n", flyer.textDescription];
    
    [cell.textLabel setText:content];
    [cell.textLabel setNumberOfLines:0];
    
    if (flyer.type == MQFlyerTypeImage) {
        [cell.imageContent sd_setImageWithURL:[NSURL URLWithString:flyer.content]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

@end
