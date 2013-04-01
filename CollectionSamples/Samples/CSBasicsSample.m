//
//  CSBasicsSample.m
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import "CSBasicsSample.h"

@interface CSCopyableObject : NSObject

@property (nonatomic, assign) NSUInteger value;
+ (instancetype)objectWithValue:(NSUInteger)value;
- (id)objectForKeyedSubscript:(id)subscript;

@end



@implementation CSBasicsSample

- (void)run
{
//    [self runArraySample];
    [self runDictionarySample];
}

- (void)runArraySample
{
    double sampleSeed = 12.0;

    struct {
        int a, b;
    } theStruct = { .a = 10, .b = 20 };


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
}

- (void)runDictionarySample
{
    CSCopyableObject *myObject = [CSCopyableObject objectWithValue:10];

    // This is dictionaryWithObjects:forKeys:count:.
    NSDictionary *dictionary = @{
            @"Key1" : @"Value1",
            (id<NSCopying>)myObject : @"Value2",
    };

    NSLog(@"Key1 value: %@", [dictionary objectForKeyedSubscript:@"Key1"]);

    // Pay attention to copyWithZone method.
    NSLog(@"Value of myObject: %@", dictionary[myObject]);

    // Usage of those objectForKeyedSubscript:
    NSLog(@"Value of Value: %@", myObject[@"value"]);

    // Shared Key Set.
    id sharedSetOfKeys = [NSDictionary sharedKeySetForKeys:@[ ]];
    NSMutableDictionary *otherDictionary = [NSMutableDictionary dictionaryWithSharedKeySet:sharedSetOfKeys];
}

@end



@implementation CSCopyableObject

+ (instancetype)objectWithValue:(NSUInteger)value
{
    CSCopyableObject *result = [[self alloc] init];
    result.value = value;

    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [CSCopyableObject objectWithValue:self.value];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Value of Copyable Object %d", self.value];
}

- (id)objectForKeyedSubscript:(id)subscript
{
    NSString *subs = (NSString *) subscript;
    return [self valueForKey:subs];
}

@end