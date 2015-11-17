//
//  UIUtils.m
//  QuestDemo
//
//  Created by Shine Chen on 11/17/15.
//  Copyright © 2015 Marcapollo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUtils.h"

@implementation UIUtils

+ (void) alertError:(NSError *)error withParent:(UIViewController *)parent
{
    
    NSMutableString *message = [NSMutableString string];
    if ([error localizedDescription]) {
        [message appendString:[error localizedDescription]];
    }
    if ([error localizedFailureReason]) {
        if ([message length] > 0) {
            [message appendString:@"\n"];
        }
        [message appendString:[error localizedFailureReason]];
    }
    if ([error localizedRecoverySuggestion]) {
        if ([message length] > 0) {
            [message appendString:@"\n"];
        }
        [message appendString:[error localizedRecoverySuggestion]];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [parent presentViewController:alertController animated:YES completion:nil];
}

@end
