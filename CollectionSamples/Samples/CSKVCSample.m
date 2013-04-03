//
// Created by dmitry.zakharov on 4/2/13.
//


#import "CSKVCSample.h"
#import "CSKVCComplaintClass.h"

static inline NSDate *CSDateFromYearsSince1970(int years)
{
    return [NSDate dateWithTimeIntervalSince1970:(years) * (365 * 24 * 60 * 60)];
}

#define SO(_name, _birthday, _income) ([CSPerson objectWithName:(_name) birthday:(_birthday) income:(_income)])

@interface CSPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, assign) double income;

@property (nonatomic, copy) NSMutableOrderedSet *relatives;

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income;
+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income;

- (id)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSOrderedSet *)relatives;
- (NSString *)description;
+ (id)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSOrderedSet *)relatives;


@end


@implementation CSKVCSample

static void CSPrintArrayNoIndex(NSString *formatStringForItem, NSArray *array)
{
    [array enumerateObjectsUsingBlock:^(NSObject *object, NSUInteger index, BOOL *stop) {
        NSLog(formatStringForItem, object);
    }];
}

static void CSPrintArrayWithIndex(NSString *formatStringForItem, NSArray *array)
{
    [array enumerateObjectsUsingBlock:^(NSObject *object, NSUInteger index, BOOL *stop) {
        NSLog(formatStringForItem, index, object);
    }];
}


- (void)run
{
//    [self runBasicKVCSample];
    [self runKVCOperationsSample];
}

- (void)runBasicKVCSample
{
    CSKVCComplaintClass *sampleClass = [[CSKVCComplaintClass alloc] init];

    NSMutableArray *items = [sampleClass mutableArrayValueForKey:@"items"];

    [items addObject:@"Item 1"];
    [items addObject:@"Item 2"];
    [items addObject:@"Item 3"];

    NSLog(@"Items: %@", [sampleClass valueForKey:@"items"]);

    NSMutableSet *set = [sampleClass mutableSetValueForKey:@"set"];

    [set addObject:@"Set 1"];
    [set addObject:@"Set 2"];
    [set addObject:@"Set 3"];

    if ([sampleClass memberOfSet:@"Set 1"]) {
        NSLog(@"There's a member set 1");
    } else {
        NSLog(@"There is no member set 1");
    }
}

- (void)runKVCOperationsSample
{
    NSArray *sampleItems = @[
            SO(@"Jack", CSDateFromYearsSince1970(0), 10000.0),
            SO(@"John", CSDateFromYearsSince1970(10), 20000.0),
            SO(@"Mark", CSDateFromYearsSince1970(20), 30000.0),
            SO(@"Mary", CSDateFromYearsSince1970(30), 40000.0),
    ];

//    CSPrintArrayWithIndex(@"Item %d is %@", [sampleItems valueForKey:@"name"]);

    NSPredicate *minButGreaterThanAverageIncome = [NSPredicate predicateWithFormat:@"income = min(subquery($all_incomes := (%@.income), $income, $income > average($all_incomes)))", sampleItems];
    NSArray *filteredArray = [sampleItems filteredArrayUsingPredicate:minButGreaterThanAverageIncome];
    NSLog(@"Filtered array: %@", filteredArray);
//    double resultingItem = [[[sampleItems filteredArrayUsingPredicate:minButGreaterThanAverageIncome] valueForKeyPath:@"@min.income"] doubleValue];
//    NSLog(@"Minimal but greater than average value is %.2f", resultingItem);
}

@end


@implementation CSPerson

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _birthday = birthday;
        _income = income;
    }

    return self;
}

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSOrderedSet *)relatives
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _birthday = birthday;
        _income = income;
        _relatives = [relatives mutableCopy];
    }

    return self;
}

+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSOrderedSet *)relatives
{
    return [[self alloc] initWithName:name birthday:birthday income:income relatives:relatives];
}

+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income
{
    return [[self alloc] initWithName:name birthday:birthday income:income];
}

- (void)setRelatives:(NSMutableOrderedSet *)relatives
{
    if (_relatives != relatives) {
        _relatives = [relatives mutableCopy];
    }
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"name=%@", self.name];
    [description appendFormat:@", birthday=%@", self.birthday];
    [description appendFormat:@", income=%.2f", self.income];
    [description appendString:@">"];

    return description;
}

- (NSString *)debugDescription
{
    return [self description];
}

@end