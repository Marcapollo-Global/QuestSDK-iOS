//
//  MQFlyerTableViewCell.h
//  QuestSDK
//
//  Created by Shine Chen on 11/30/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQFlyerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageContent;

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;

@end
