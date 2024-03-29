//
// Created by dmitry.zakharov on 4/2/13.
//


#import "CSNewCollectionsSample.h"

@interface CSSpecialCopyableObject : NSObject<NSCopying>

@property (nonatomic, assign) NSUInteger value;

- (instancetype)initWithValue:(NSUInteger)value;
+ (instancetype)objectWithValue:(NSUInteger)value;

@end




@implementation CSNewCollectionsSample

- (void)run
{
    // Samples 4
    RUN_CASE(4);
}

// Arrays sample.
- (void)runSample1
{
// Easy-to-create weak pointer array.
    __unused __weak NSString *theItem;
    @autoreleasepool {
        NSPointerArray *weakPointerArray = [NSPointerArray weakObjectsPointerArray];

        __strong NSArray *normalArray;
        @autoreleasepool {
            NSString *item1 = [NSString stringWithFormat:@"Item %d", 1];
            NSString *item2 = [NSString stringWithFormat:@"Item %d", 2];
            NSString *item3 = [NSString stringWithFormat:@"Item %d", 3];

            // But what if we pass __bridge_retained???
            [weakPointerArray addPointer:(__bridge void *)item1];
            [weakPointerArray addPointer:(__bridge void *)item2];
            [weakPointerArray addPointer:(__bridge void *)item3];

            // You can add NULLs.
            [weakPointerArray addPointer:NULL];
            NSLog(@"Last item: %d", (unsigned int) [weakPointerArray pointerAtIndex:[weakPointerArray count] - 1]);
            NSLog(@"Count of items before compact: %d", [weakPointerArray count]);
            [weakPointerArray compact];
            NSLog(@"Count of items after compact: %d", [weakPointerArray count]);

            // You can get an array of strongly-referenced object from weak array.
            normalArray = [weakPointerArray allObjects];
        }

        {
            NSString *item1 = (__bridge NSString *)[weakPointerArray pointerAtIndex:0];
            NSLog(@"1. Item1 = %@", item1); // Not NULL because of normalArray is __strong.
        }

        NSLog(@"__strong NSArray: %@", normalArray); // Array is alive.

        theItem = (__bridge NSString *)[weakPointerArray pointerAtIndex:0];
        NSLog(@"2. Item1 = %@", theItem);
    }

    // Strongs are destroyed. Weaks are NULLed.
    NSLog(@"Item1 = %@, address: %x, and retain count is %d", theItem, (unsigned int)theItem, _objc_rootRetainCount(theItem));
    // _objc_autoreleasePoolPrint();
}


// Custom functions sample.
- (void)runSample2
{
    // Commence the fun part.

//    @autoreleasepool {
//        // Let's go with the copier.
//        NSPointerArray *customFuncArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsCopyIn | NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality];
//
//        CSSpecialCopyableObject *object1 = [CSSpecialCopyableObject objectWithValue:10];
//        [customFuncArray addPointer:(__bridge void *)object1];
//    }

//    @autoreleasepool {
//        // Let's go with C Arrays.
//        int *items = calloc(3, sizeof(*items));
//        items[0] = 10;
//        items[1] = 20;
//        items[2] = 30;
//
//        NSPointerArray *customFuncArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality];
//        [customFuncArray addPointer:items];
//
//        int *newItems = [customFuncArray pointerAtIndex:0];
//        // They are equal, as NO-OP is done when inserting Pointers into the array.
//        NSLog(@"NewItems is equal to Items: %d", items == newItems);
//        for (int index = 0; index < 3; ++index) {
//            NSLog(@"Item at index %d is %d", index, newItems[index]);
//        }
//
//        free(items);
//    }
}

// Hashtable sample.
- (void)runSample3
{
    @autoreleasepool {
        // Let's go with the strings copying.

        NSMutableString *string1 = [NSMutableString stringWithFormat:@"String %d", 1];
        NSHashTable *hashTable = [NSHashTable hashTableWithOptions:NSHashTableCopyIn];
        {
            NSMutableString *string2 = [NSMutableString stringWithString:@"String 1"];
            NSMutableString *string3 = [NSMutableString stringWithFormat:@"String %d", 3];
            [hashTable addObject:string1];
            [hashTable addObject:string2];
            [hashTable addObject:string3];
        }

        // Addresses are not equal as we set up Hash to copy values.
        // Yet, only one 'String 1' is present as of hashes and equality.
        NSLog(@"Address of item1: %p", (__bridge void *)string1);
        [[hashTable allObjects] enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
            NSLog(@"Address of item from array at index %d: %p; value: %@", idx, (__bridge void *)value, value);
        }];

        NSLog(@"Count of items %d", [hashTable count]);
    }
}

// Map sample.
- (void)runSample4
{
    @autoreleasepool {
        // Let's go with the strings copying.

        NSMutableString *key1 = [NSMutableString stringWithFormat:@"String %d", 1];
        NSMapTable *map = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory | NSPointerFunctionsObjectPersonality valueOptions:NSMapTableCopyIn];
        @autoreleasepool {
            NSMutableString *key2 = [NSMutableString stringWithString:@"String 2"];
            NSMutableString *key3 = [NSMutableString stringWithFormat:@"String %d", 3];

            CSSpecialCopyableObject *value1 = [CSSpecialCopyableObject objectWithValue:10];
            NSLog(@"Value1 address is %p", (__bridge void *) value1);

            [map setObject:value1 forKey:key1];
            [map setObject:[CSSpecialCopyableObject objectWithValue:20] forKey:key2];
            [map setObject:[CSSpecialCopyableObject objectWithValue:30] forKey:key3];
        }

        // The keys are dead.
        NSLog(@"Address of key1: %p", (__bridge void *)key1);
        NSLog(@"Number of items %d", [map count]);

        NSLog(@"Dictionary representation: ");
        [[map dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            NSLog(@"Address of key from map %p; value: %@", (__bridge void *) key, key);
            NSLog(@"Address of value from map %p; value: %@", (__bridge void *) value, value);
            NSLog(@"Value for %@ is %@", key, value);
        }];

        NSLog(@"Map representation: ");
        NSEnumerator *keyEnumerator = [map keyEnumerator];

        NSString *key;
        while ((key = [keyEnumerator nextObject])) {
            NSLog(@"Value for Key \'%@\' is \'%@\'", key, [map objectForKey:key]);
        }
    }
}

@end



@implementation CSSpecialCopyableObject

- (instancetype)initWithValue:(NSUInteger)value
{
    self = [self init];
    if (self) {
        _value = value;
    }

    return self;
}

+ (instancetype)objectWithValue:(NSUInteger)value
{
    return [[self alloc] initWithValue:value];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSLog(@"We're in copyWithZone:");
    return [[self class] objectWithValue:self.value];
}

// IMPLEMENT HASH AND EQUALSTO: HERE

@end