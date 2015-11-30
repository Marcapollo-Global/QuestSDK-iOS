//
//  MQFlyerTableViewCell.m
//  QuestSDK
//
//  Created by Shine Chen on 11/30/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import "MQFlyerTableViewCell.h"

@implementation MQFlyerTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"MQFlyerTableViewCell" bundle:nil];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
