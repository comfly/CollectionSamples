//
// Created by comfly on 4/7/13.
//


#import "CSKVOSample.h"

@interface CSKVOComplaintClass : NSObject

- (void)setArray:(NSArray *)array;
- (NSArray *)array;

- (NSUInteger)countOfArray;
- (id)objectInArrayAtIndex:(NSUInteger)index;

- (void)insertObject:(id)object inArrayAtIndex:(NSUInteger)index;
- (void)removeObjectFromArrayAtIndex:(NSUInteger)index;
- (void)replaceObjectInArrayAtIndex:(NSUInteger)index withObject:(id)object;



- (void)setSet:(NSMutableOrderedSet *)set;
- (NSMutableOrderedSet *)set;

- (NSUInteger)countOfSet;
- (id)memberOfSet:(id)object;
- (NSEnumerator *)enumeratorOfSet;
- (id)objectInSetAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfSetObject:(id)object;

- (void)addSetObject:(id)object;
- (void)removeSetObject:(id)object;
- (void)removeSet:(NSSet *)set;
- (void)intersectSet:(NSSet *)objects;

- (void)insertObject:(id)object inSetAtIndex:(NSUInteger)index;
- (void)removeObjectFromSetAtIndex:(NSUInteger)index;
- (void)replaceObjectInSetAtIndex:(NSUInteger)index withObject:(id)object;

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@interface CSKVOSample ()

@end

@implementation CSKVOSample {
  @private
}

- (void)run
{
    CSKVOComplaintClass *sample = [[CSKVOComplaintClass alloc] init];
    [sample setArray:[NSMutableArray arrayWithArray:@[ @YES, @"Hello", [NSMutableArray arrayWithObject:@10 ] ]] ];
    sample.dictionary = [NSMutableDictionary dictionary];
    sample.set = [NSMutableOrderedSet orderedSetWithObjects:@"Value 1", @"Value 2", [NSMutableSet setWithObject:@"SetItem1"], nil];

    // Array samples
    // [self runArraySampleOnSampleObject:sample];
    [self runSetSampleOnSampleObject:sample];
//    [self runDictionarySampleOnSampleObject:sample];
}

- (void)runArraySampleOnSampleObject:(CSKVOComplaintClass *)sample
{
    [sample addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];

    NSMutableArray *kvcArray = [sample mutableArrayValueForKey:@"array"];
    kvcArray[0] = @NO;
    [kvcArray addObject:[NSValue valueWithCGPoint:(CGPoint){ 10.0f, 20.0f }]];
    [((NSMutableArray *) kvcArray[2]) addObject:@"Hello world"];
    [kvcArray removeObjectAtIndex:0];
    [sample setArray:@[ @1, @2, @3 ]];
//        [kvcArray setArray:@[ @1, @2, @3 ]];

    [sample removeObserver:self forKeyPath:@"array" context:NULL];
}

- (void)runSetSampleOnSampleObject:(CSKVOComplaintClass *)sample
{
    [sample addObserver:self forKeyPath:@"set" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];

    NSString *value3 = @"Value 3";
    NSMutableOrderedSet *kvcSet = [sample mutableOrderedSetValueForKey:@"set"];
    [kvcSet addObject:value3];
    [kvcSet addObject:[NSValue valueWithCGPoint:CGPointMake(10.0f, 20.0f)]];
    [((NSMutableSet *) kvcSet[2]) addObject:@"Hello world"];
    [kvcSet removeObject:value3];
    [kvcSet intersectSet:[NSSet setWithObjects:@"Value 2", @"Value 1", nil]];
    [kvcSet minusOrderedSet:[NSOrderedSet orderedSetWithObjects:@"Value 2", @"Value 4", nil]];
    [kvcSet unionOrderedSet:[NSOrderedSet orderedSetWithObjects:@"Hi", @"Bye", nil]];


    NSLog(@"Set values: %@", kvcSet);
    [sample removeObserver:self forKeyPath:@"set" context:NULL];
}

- (void)runDictionarySampleOnSampleObject:(CSKVOComplaintClass *)sample
{
    [sample addObserver:self forKeyPath:@"dictionary.someKey" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];

    [sample.dictionary setObject:@"Hello" forKey:@"someKey"];
    [sample.dictionary setObject:@"Bye" forKey:@"someKey"];
    [sample.dictionary removeObjectForKey:@"someKey"];

    [sample removeObserver:self forKeyPath:@"dictionary.someKey" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelector:(SEL)
        [@{
                @"array" : [NSValue valueWithPointer:@selector(processArrayChanges:)],
                @"dictionary.someKey" : [NSValue valueWithPointer:@selector(processDictionaryChanges:)],
                @"set" : [NSValue valueWithPointer:@selector(processSetChanges:)]
        }[keyPath] pointerValue] withObject:change];

//    [self performSelector:NSSelectorFromString(@{
//                    @"array" : NSStringFromSelector(@selector(processArrayChanges:)),
//                    @"set" : NSStringFromSelector(@selector(processSetChanges:))
//            }[keyPath]
//    ) withObject:change];
}

- (void)processArrayChanges:(NSDictionary *)change
{
    NSKeyValueChange changeType = (NSKeyValueChange) [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
    switch (changeType) {
            case NSKeyValueChangeInsertion:{
                NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
                NSArray *newValues = change[NSKeyValueChangeNewKey];

                __block NSUInteger valueIndex = 0;
                [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSLog(@"Item at index %d became %@", idx, newValues[valueIndex]);
                    valueIndex++;
                }];
            }

                break;
            case NSKeyValueChangeRemoval: {
                NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
                NSArray *oldValues = change[NSKeyValueChangeOldKey];

                __block NSUInteger valueIndex = 0;
                [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSLog(@"Item at index %d was %@, and now it is gone", idx, oldValues[valueIndex]);
                    valueIndex++;
                }];
            }
                break;
            case NSKeyValueChangeReplacement: {
                NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
                NSArray *oldValues = change[NSKeyValueChangeOldKey];
                NSArray *newValues = change[NSKeyValueChangeNewKey];

                __block NSUInteger valueIndex = 0;
                [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSLog(@"Item at index %d was %@, and now it is %@", idx, oldValues[valueIndex], newValues[valueIndex]);
                    valueIndex++;
                }];
            }
                break;
            case NSKeyValueChangeSetting: {
                NSArray *oldValues = change[NSKeyValueChangeOldKey];
                NSArray *newValues = change[NSKeyValueChangeNewKey];
                NSLog(@"Entire array %@ was replaced with %@", oldValues, newValues);
            }
                break;
        }
}

- (void)processSetChanges:(NSDictionary *)change
{
    NSKeyValueChange changeType = (NSKeyValueChange) [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
    switch (changeType) {
        case NSKeyValueChangeSetting: {
            id oldValue = change[NSKeyValueChangeOldKey];
            id newValue = change[NSKeyValueChangeNewKey];
            NSLog(@"Old value of set was %@ and now it's %@", oldValue, newValue);
        }
            break;
        case NSKeyValueChangeInsertion: {
            NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
            NSArray *newValues = change[NSKeyValueChangeNewKey];

            __block NSUInteger valueIndex = 0;
            [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSLog(@"Item at index %d became %@", idx, newValues[valueIndex]);
                valueIndex++;
            }];
        }
            break;
        case NSKeyValueChangeRemoval: {
            NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
            NSArray *oldValues = change[NSKeyValueChangeOldKey];

            __block NSUInteger valueIndex = 0;
            [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSLog(@"Item at index %d was %@, and now it is gone", idx, oldValues[valueIndex]);
                valueIndex++;
            }];
        }
            break;
        case NSKeyValueChangeReplacement: {
            NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
            NSArray *oldValues = change[NSKeyValueChangeOldKey];
            NSArray *newValues = change[NSKeyValueChangeNewKey];

            __block NSUInteger valueIndex = 0;
            [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSLog(@"Item at index %d was %@, and now it is %@", idx, oldValues[valueIndex], newValues[valueIndex]);
                valueIndex++;
            }];
        }
            break;
        default:
            NSLog(@"Will never occur");
            break;
    }
}

- (void)processDictionaryChanges:(NSDictionary *)change
{
    NSKeyValueChange changeType = (NSKeyValueChange) [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    switch (changeType) {
        case NSKeyValueChangeSetting:
            NSLog(@"Set new value is %@", newValue);
            break;
        case NSKeyValueChangeInsertion:
            NSLog(@"Inserted new value is %@", newValue);
            break;
        case NSKeyValueChangeRemoval:
            NSLog(@"Removed value is %@", oldValue);
            break;
        case NSKeyValueChangeReplacement:
            NSLog(@"Old value was %@ and became %@", oldValue, newValue);
            break;
    }
}

@end


@implementation CSKVOComplaintClass {
  @private
    NSMutableArray *_theArray;
    NSMutableOrderedSet *_theSet;
}

- (void)setArray:(NSArray *)array
{
    if (array != _theArray) {
        [self willChangeValueForKey:@"array"];
        _theArray = [array mutableCopy];
        [self didChangeValueForKey:@"array"];
    }
}

- (NSArray *)array
{
    return _theArray;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"array"]) {
        return NO;
    }

    return [super automaticallyNotifiesObserversForKey:key];
}

- (NSUInteger)countOfArray
{
    return [_theArray count];
}

- (id)objectInArrayAtIndex:(NSUInteger)index1
{
    return _theArray[index1];
}

- (void)insertObject:(id)object inArrayAtIndex:(NSUInteger)index1
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"array"];
    [_theArray insertObject:object atIndex:index1];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"array"];
}

- (void)removeObjectFromArrayAtIndex:(NSUInteger)index1
{
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"array"];
    [_theArray removeObjectAtIndex:index1];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"array"];
}

- (void)replaceObjectInArrayAtIndex:(NSUInteger)index withObject:(id)object
{
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"array"];
    [_theArray replaceObjectAtIndex:index withObject:object];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"array"];
}




- (void)setSet:(NSMutableOrderedSet *)set
{
    if (_theSet != set) {
        [self willChangeValueForKey:@"set"];
        _theSet = set;
        [self didChangeValueForKey:@"set"];
    }
}

- (NSMutableOrderedSet *)set
{
    return _theSet;
}

- (NSUInteger)countOfSet
{
    return [_theSet count];
}

- (id)memberOfSet:(id)object
{
    NSUInteger index = [_theSet indexOfObject:object];
    if (index != NSNotFound) {
        return [_theSet objectAtIndex:index];
    } else {
        return nil;
    }
}

- (NSEnumerator *)enumeratorOfSet
{
    return [_theSet objectEnumerator];
}

- (id)objectInSetAtIndex:(NSUInteger)index1
{
    return [_theSet objectAtIndex:index1];
}

- (NSUInteger)indexOfSetObject:(id)object
{
    NSUInteger index = [_theSet indexOfObject:object];
    return index;
}

- (void)addSetObject:(id)object
{
    [self willChangeValueForKey:@"set" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:object]];
    [_theSet addObject:object];
    [self didChangeValueForKey:@"set" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:object]];
}

- (void)removeSetObject:(id)object
{
    [self willChangeValueForKey:@"set" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:object]];
    [_theSet removeObject:object];
    [self didChangeValueForKey:@"set" withSetMutation:NSKeyValueMinusSetMutation usingObjects:[NSSet setWithObject:object]];
}

- (void)removeSet:(NSSet *)set
{
    [self willChangeValueForKey:@"set" withSetMutation:NSKeyValueMinusSetMutation usingObjects:set];
    for (id item in set) {
        [_theSet removeObject:item];
    }
    [self didChangeValueForKey:@"set" withSetMutation:NSKeyValueMinusSetMutation usingObjects:set];
}

- (void)intersectSet:(NSSet *)objects
{
    [self willChangeValueForKey:@"set" withSetMutation:NSKeyValueIntersectSetMutation usingObjects:objects];
    [_theSet intersectSet:objects];
    [self didChangeValueForKey:@"set" withSetMutation:NSKeyValueIntersectSetMutation usingObjects:objects];
}

- (void)insertObject:(id)object inSetAtIndex:(NSUInteger)index1
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
    [_theSet insertObject:object atIndex:index1];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
}

- (void)removeObjectFromSetAtIndex:(NSUInteger)index1
{
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
    [_theSet removeObjectAtIndex:index1];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
}

- (void)replaceObjectInSetAtIndex:(NSUInteger)index1 withObject:(id)object
{
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
    [_theSet replaceObjectAtIndex:index1 withObject:object];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index1] forKey:@"set"];
}

@end
