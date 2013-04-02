//
//  CSBasicsSample.m
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import "CSBasicsSample.h"

@interface CSSampleObject : NSObject

@property (nonatomic, assign) NSUInteger value;
//@property (nonatomic, strong) CSSampleObject *another;
+ (instancetype)objectWithValue:(NSUInteger)value;

- (id)objectForKeyedSubscript:(NSString *)subscript;
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

@end



@implementation CSBasicsSample

- (void)run
{
//    [self runArraySample];
//    [self runDictionarySample];
//    [self runSetSample];
}

- (void)runArraySample
{
    double sampleSeed = 12.0;

    struct {
        /* int size; */
        int a, b;
    } theStruct = { /* .size = sizeof(typeof(theStruct)), */ .a = 10, .b = 20 };

    int *cArray = calloc(3, sizeof(typeof(*cArray)));

    for (int index = 0; index < 3; ++index) {
        cArray[index] = (index + 1) * 10;
    }

    NSMutableArray *mutableArray;
    @autoreleasepool {
        id nonRetainedObject = [NSObject new];
        id retainedObject = [NSObject new];

        // This is transformed to arrayWithObjects:count:
        NSArray *readonlyArray = @[
            @10,        // Number.
            @"Hello",   // String.
            @YES,       // Boolean.

            // The struct.
            @[ @(sizeof(theStruct)), [NSValue valueWithBytes:&theStruct objCType:@encode(typeof(theStruct))] ],

            // Some value without making it strong.
            [NSValue valueWithNonretainedObject:nonRetainedObject],

            retainedObject,

            // nil value.
            [NSNull null],

            // Block.
            (^double(int k) {
                return k * sampleSeed;
            }),

            // C Array.
            [NSValue valueWithPointer:cArray],

            // Can have ending comma (,)
        ];

//        NSLog(@"Retain count of Nonretained Value: %lu", _objc_rootRetainCount(nonRetainedObject));
//        NSLog(@"Retain count of Retained Value: %lu", _objc_rootRetainCount(retainedObject));

        mutableArray = [NSMutableArray arrayWithArray:readonlyArray];
    }

    // Indexed access is NSArray # objectAtIndexedSubscript:(NSUInteger)idx.
    typeof(theStruct) *newStruct = malloc((size_t)[mutableArray[3][0] unsignedLongLongValue]);
    [((NSValue *) (mutableArray[3][1])) getValue:newStruct];
    NSLog(@"Value of item a=%d, b=%d", newStruct->a, newStruct->b);

    int *cArray1 = (int *)[[mutableArray lastObject] pointerValue];
    NSLog(@"Array values are: %d, %d, %d", cArray1[0], cArray1[1], cArray1[2]);

    free(cArray1);


    NSMutableArray *sampleArray = [NSMutableArray array];
    [sampleArray addObject:@10];
    [sampleArray addObject:@20];
    // Specific behavior when setting a boundary index value.
    sampleArray[[sampleArray count]] = @30;
    NSLog(@"Sample array:");
    [sampleArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
    }];


#define COUNT_OF_OBJECTS 1000000

//    NSMutableArray *lotsOfObjects = [NSMutableArray arrayWithCapacity:COUNT_OF_OBJECTS];
//    for (typeof(COUNT_OF_OBJECTS) index = 0; index < COUNT_OF_OBJECTS; index += arc4random() % 2 + 1) {
//        [lotsOfObjects addObject:@(index)];
//    }
//
//
//    [lotsOfObjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
//        if ((idx & 1) == 0) {
//            NSLog(@"Even");
//        }
//    }];
//
//    NSUInteger indexOfNewItem = [lotsOfObjects indexOfObject:@50001
//                                               inSortedRange:NSMakeRange(30000, 20000)
//                                                     options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual
//                                             usingComparator:^NSComparisonResult(NSNumber *value1, NSNumber *value2) {
//                                                 return [value1 compare:value2];
//                                             }];
//    NSLog(@"Index of new Item: %d", indexOfNewItem);
//    NSLog(@"Item to the left: %d", [lotsOfObjects[indexOfNewItem - 1] unsignedIntegerValue]);
//    NSLog(@"Item at index: %d", [lotsOfObjects[indexOfNewItem] unsignedIntegerValue]);
//    NSLog(@"Item of the right: %d", [lotsOfObjects[indexOfNewItem + 1] unsignedIntegerValue]);

#undef COUNT_OF_OBJECTS
}

- (void)runDictionarySample
{
    CSSampleObject *myObject = [CSSampleObject objectWithValue:10];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    // This is dictionaryWithObjects:forKeys:count:.
    NSDictionary *dictionary = @{
            @"Sample key" : @"Sample value",
            (id<NSCopying>)myObject : @"Object value",
            @((intptr_t) button) : @"Some button",
            [NSString class] : @"String class",
            @"TheObject" : myObject,
    };

    NSLog(@"Key1 value: %@", [dictionary objectForKeyedSubscript:@"Sample key"]);

    // Pay attention to copyWithZone method.
    NSLog(@"Value of myObject: %@", dictionary[myObject]);

    // Usage of those objectForKeyedSubscript:/setObject:forKeyedSubscript:
//    myObject[@"value"] = @20;
//    NSLog(@"Value of Value: %@", myObject[@"value"]);

    NSLog(@"Button value: %@", dictionary[@((intptr_t) button)]);

    NSLog(@"String class value is %@", dictionary[[NSString class]]);

    // Shared Key Set.
    // If you have lots of dictionaries with the same set of keys. It conserves memory,
    // and saves processor ticks preventing behavior to call copy on those keys.
    // Also it has specific Hash calculation machinery making hashes for the keys
    // (if they present in Shared Key Set better), trying to remove loop-through-values for the hashes with invocation of isEqual:.
    // The resulting type is not NSSet. It's just an abstract type, so, use 'id'.
    id sharedSetOfKeys = [NSDictionary sharedKeySetForKeys:@[ @"Key1", @"Key2", @10 ]];
    __unused NSMutableDictionary *otherDictionary1 = [NSMutableDictionary dictionaryWithSharedKeySet:sharedSetOfKeys];
    otherDictionary1[@"Key1"] = @"Value11";
    otherDictionary1[@"Key2"] = @"Value12";
    otherDictionary1[@10] = @"Value_1_10";

    __unused NSMutableDictionary *otherDictionary2 = [NSMutableDictionary dictionaryWithSharedKeySet:sharedSetOfKeys];
    otherDictionary1[@"Key1"] = @"Value21";
    otherDictionary1[@"Key2"] = @"Value22";
    otherDictionary1[@10] = @"Value_2_10";

    __unused NSMutableDictionary *otherDictionary3 = [NSMutableDictionary dictionaryWithSharedKeySet:sharedSetOfKeys];
    otherDictionary1[@"Key1"] = @"Value31";
    otherDictionary1[@"Key2"] = @"Value32";
    otherDictionary1[@10] = @"Value_3_10";

    // KVC to the rescue.
    [dictionary setValue:@300 forKeyPath:@"TheObject.value"];
    NSLog(@"Value which we changed with KVC: %d", ((CSSampleObject *)dictionary[@"TheObject"]).value);

    __weak NSString *item;
    @autoreleasepool {
        const NSString *key = @"ItemKey";

        NSString *itemValue = [NSString stringWithFormat:@"%@", key];

        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
            key : itemValue,
        }];

        // Obtained value is autoreleased.
        item = dictionary[key];
        [dictionary removeObjectForKey:key];

        NSLog(@"Item value 1: %@", item);
    }

    NSLog(@"Item value 2: %@", item);


    NSString *item1 = @"Item1";
    NSString *item2 = @"Item2";
    NSDictionary *dict = NSDictionaryOfVariableBindings(item1, item2);
    for (NSString *key in dict) {
        NSLog(@"%@ => %@", key, dict[key]);
    }
}

- (void)runSetSample
{
    CSSampleObject *item1 = [CSSampleObject objectWithValue:10];
    CSSampleObject *item2 = [CSSampleObject objectWithValue:20];

    NSSet *set1 = [NSSet setWithObjects:item1, item2, nil];
    NSLog(@"Contains Item1: %d", [set1 containsObject:item1]);

    item1.value = 30; // Pay attention to hash/isEqual:
    NSLog(@"Contains Item1: %d", [set1 containsObject:item1]);

    CSSampleObject *item3 = [CSSampleObject objectWithValue:20];
    NSLog(@"Equal object exists: %d", [set1 containsObject:item3]);
    NSLog(@"Find member: %@", [set1 member:item3]);

    // KVC is here.
//    item1.another = item2;
//    item2.another = item3;
//    item3.another = nil;
//    NSLog(@"Values for key are %@", [set1 valueForKey:@"value"]);
//
//    item1.another = item2;
//    item2.another = item3;
//    item3.value = 40;
//    item3.another = nil;
//    NSLog(@"Values for keyPath are %@", [set1 valueForKeyPath:@"another.value"]);

    // Pay attention that #allObjects returns the array of the same objects that are in the set.
    // And, the same objects that possibly you posses. So, be careful when modifying.
    NSArray *ar = [set1 allObjects];
    ((CSSampleObject *)ar[0]).value = 180;
    NSLog(@"Values in set are: %@", set1);
    NSLog(@"Value in item1 is: %@", item1);

    // Counted set.
    NSCountedSet *countedSet = [NSCountedSet set];
    [countedSet addObject:@10];
    [countedSet addObject:@10];
    [countedSet addObject:@10];
    [countedSet addObject:@20];
    [countedSet addObject:@20];
    [countedSet addObject:@30];
    NSLog(@"There're %d '10's, %d '20's and %d '30's", [countedSet countForObject:@10], [countedSet countForObject:@20], [countedSet countForObject:@30]);

    // Ordered set.
    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    [orderedSet addObjectsFromArray:@[ item1, item2, item3 ]];

    NSArray *array = [orderedSet array];
    ((CSSampleObject *)[array lastObject]).value = 50;
    NSLog(@"Values after change in Proxy-Array are:");
    for (NSUInteger index = 0, count = [orderedSet count]; index < count; ++index) {
        NSLog(@"Value at index %d is '%@'", index, orderedSet[index]);
    }
}

@end



@implementation CSSampleObject

+ (instancetype)objectWithValue:(NSUInteger)value
{
    CSSampleObject *result = [[self alloc] init];
    result.value = value;

    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [CSSampleObject objectWithValue:self.value];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Value of Copyable Object %d", self.value];
}

- (id)objectForKeyedSubscript:(NSString *)subscript
{
    return [self valueForKey:subscript];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    [self setValue:object forKey:key];
}

@end