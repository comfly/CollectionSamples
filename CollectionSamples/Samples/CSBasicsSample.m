//
//  CSBasicsSample.m
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import "CSBasicsSample.h"

@implementation CSBasicsSample

- (void)run
{
    double sampleSeed = 12.0;
    
    struct {
        int a, b;
    } theStruct = { 10, 20 };
    
    id object = [NSNumber numberWithDouble:sampleSeed];
    
    NSArray *array = @[
                       @10,
                       @"Hello",
                       @YES,
                       [NSValue value:&theStruct withObjCType:@encode(typeof(theStruct))],
                       [NSValue valueWithNonretainedObject:object],
                       [NSNull null],
                       (^double(int k) {
                           return k * sampleSeed;
                       }),
                       // Can have ending comma (,)
                       ];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Item in array at index %d of type (%@) with value: %@", idx, [obj class], obj);
    }];
}

@end
