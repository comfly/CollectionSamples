//
// Created by dmitry.zakharov on 4/2/13.
//


#import <Foundation/Foundation.h>


@interface CSKVCComplaintClass : NSObject

#pragma mark - Array sample

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *editableItems;

/* OR, which is more preferable */

#pragma mark - Set sample

@property (nonatomic, strong) NSSet *constSet;
@property (nonatomic, strong) NSMutableSet *mutableSet;

/* OR, which is more preferable */

@end