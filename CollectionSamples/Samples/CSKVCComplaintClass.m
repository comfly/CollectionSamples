//
// Created by dmitry.zakharov on 4/2/13.
//


#import "CSKVCComplaintClass.h"

@interface CSKVCComplaintClass ()

@property (nonatomic, strong) NSMutableArray *theArray;
@property (nonatomic, strong) NSMutableSet *theSet;

@end

@implementation CSKVCComplaintClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        _theArray = [[NSMutableArray alloc] init];
        _theSet = [[NSMutableSet alloc] init];
    }

    return self;
}

- (NSUInteger)countOfItems
{
    return [self.theArray count];
}

- (NSString *)objectInItemsAtIndex:(NSUInteger)index
{
    return self.theArray[index];
}

- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes
{
    return [self.theArray objectsAtIndexes:indexes];
}

- (void)getItems:(NSString * __unsafe_unretained [])buffer range:(NSRange)inRange
{
    [self.theArray getObjects:buffer range:inRange];
}

- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.theArray insertObjects:array atIndexes:indexes];
}

- (void)insertObject:(NSString *)object inItemsAtIndex:(NSUInteger)index
{
    [self.theArray insertObject:object atIndex:index];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.theArray removeObjectsAtIndexes:indexes];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)index
{
    [self.theArray removeObjectAtIndex:index];
}

- (void)replaceObjectInItemsAtIndex:(NSUInteger)index withObject:(NSString *)object
{
    [self.theArray replaceObjectAtIndex:index withObject:object];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array
{
    [self.theArray replaceObjectsAtIndexes:indexes withObjects:array];
}

- (NSUInteger)countOfSet
{
    return [self.theSet count];
}

- (NSEnumerator *)enumeratorOfSet
{
    return [self.theSet objectEnumerator];
}

- (NSString *)memberOfSet:(NSString *)object
{
    return [self.theSet member:object];
}

- (void)addSet:(NSSet *)objects
{
    [self.theSet addObjectsFromArray:[objects allObjects]];
}

- (void)addSetObject:(NSString *)object
{
    [self.theSet addObject:object];
}

- (void)removeSet:(NSSet *)objects
{
    [[objects allObjects] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [self.theSet removeObject:obj];
    }];
}

- (void)removeSetObject:(NSString *)object
{
    [self.theSet removeObject:object];
}

- (void)intersectSet:(NSSet *)objects
{
    [self.theSet intersectSet:objects];
}

- (void)setSet:(NSMutableSet *)set
{
    [self.theSet setSet:set];
}


@end