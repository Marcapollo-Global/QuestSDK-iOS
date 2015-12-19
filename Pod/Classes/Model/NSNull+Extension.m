//
//  NSNull+Extension.m
//  Pods
//
//  Created by Shine Chen on 12/19/15.
//
//

#import "NSNull+Extension.h"

@implementation NSNull (Extension)

- (double) doubleValue
{
    return 0.0;
}
- (BOOL) boolValue
{
    return false;
}
- (int) intValue
{
    return 0;
}
- (NSInteger) integerValue
{
    return 0;
}
- (NSString *) description
{
    return @"";
}

@end
