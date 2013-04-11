//
// Created by dmitry.zakharov on 4/2/13.
//


#import "CSKVCSample.h"
#import "CSKVCComplaintClass.h"

@interface NSArray (CSCollectionOperations)

// http://funwithobjc.tumblr.com/
- (id)_upcaseJoinForKeyPath:(NSString *)keyPath;

@end

static inline NSDate *CSDateFromYearsSince1970(int years)
{
    return [NSDate dateWithTimeIntervalSince1970:(years) * (365 * 24 * 60 * 60)];
}

#define SO(_name, _birthday, _income) ([CSPerson objectWithName:(_name) birthday:(_birthday) income:(_income)])

@interface CSPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, assign) double income;

@property (nonatomic, copy) NSMutableSet *relatives;

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income;
+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income;

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSSet *)relatives;
+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSSet *)relatives;

- (NSString *)description;

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
    // Sample cases 4
    RUN_CASE(1);
}

// Basic KVC.
- (void)runSample1
{
    CSKVCComplaintClass *sampleClass1 = [[CSKVCComplaintClass alloc] init];

    NSMutableArray *items = [sampleClass1 mutableArrayValueForKey:@"items"];

    [items addObject:@"Item 1"];
    [items addObject:@"Item 2"];
    [items addObject:@"Item 3"];

    NSLog(@"Items: %@", [sampleClass1 valueForKey:@"items"]);

    // Proxy has a strong relation to it's host.
//    NSMutableSet *set = nil;
//    __weak CSKVCComplaintClass *sampleClass;
//    @autoreleasepool {
//        {
//            CSKVCComplaintClass *sampleClass2 = [[CSKVCComplaintClass alloc] init];
//            sampleClass = sampleClass2;
//            set = [sampleClass mutableSetValueForKey:@"set"];
//        }
//
//        [set addObject:@"Set 1"];
//        [set addObject:@"Set 2"];
//        [set addObject:@"Set 3"];
//    }
//
//    if ([sampleClass memberOfSet:@"Set 1"]) {
//        NSLog(@"There's a member set 1");
//    } else {
//        NSLog(@"There is no member set 1");
//    }
}

// Collection operators.
- (void)runSample2
{
    NSArray *sampleItems = @[
            SO(@"Jack", CSDateFromYearsSince1970(0), 10000.0),
            SO(@"John", CSDateFromYearsSince1970(10), 20000.0),
            SO(@"Mark", CSDateFromYearsSince1970(20), 30000.0),
            SO(@"Clark", CSDateFromYearsSince1970(30), 40000.0),
            SO(@"Mary", CSDateFromYearsSince1970(40), 50000.0),
    ];

    CSPrintArrayWithIndex(@"Item %d is %@", [sampleItems valueForKey:@"name"]);

    NSArray *items = [sampleItems valueForKeyPath:@"birthday.timeIntervalSinceReferenceDate"];
    NSLog(@"Birthday timestamps: %@", items);

    // Dictionary sample
    NSDictionary *dictionary = @{
            @"Key" : sampleItems
    };

    NSLog(@"Max income of all: %@", [dictionary valueForKeyPath:@"Key.@max.income"]);
}

// KVC with Predicates.
- (void)runSample3
{
    NSArray *sampleItems = @[
            SO(@"Jack", CSDateFromYearsSince1970(0), 10000.0),
            SO(@"John", CSDateFromYearsSince1970(10), 20000.0),
            SO(@"Mark", CSDateFromYearsSince1970(20), 30000.0),
            SO(@"Clark", CSDateFromYearsSince1970(30), 40000.0),
            SO(@"Mary", CSDateFromYearsSince1970(40), 50000.0),
    ];

    NSPredicate *oldestUpperMiddleClassPerson = [NSPredicate predicateWithFormat:@"birthday = SUBQUERY($people := (%@), $person, $person.income > average($people.income)).@min.birthday", sampleItems];
    NSArray *filteredArray = [sampleItems filteredArrayUsingPredicate:oldestUpperMiddleClassPerson];
    CSPrintArrayNoIndex(@"Name of oldest upper middle class person: %@", [filteredArray valueForKey:@"name"]);

    // You cannot build exactly the same expression as the one above. Private headers only.

    // Yet, the sample.
    NSExpression *nameExpression = [NSExpression expressionForKeyPath:@"name"];
    NSExpression *letterExpression = [NSExpression expressionForConstantValue:@"J"];
    NSPredicate *namePredicate = [NSComparisonPredicate predicateWithLeftExpression:nameExpression rightExpression:letterExpression modifier:NSDirectPredicateModifier type:NSBeginsWithPredicateOperatorType options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];

    NSExpression *incomeExpression = [NSExpression expressionForKeyPath:@"income"];
    NSExpression *sumExpression = [NSExpression expressionForConstantValue:@(15000)];
    NSPredicate *incomePredicate = [NSComparisonPredicate predicateWithLeftExpression:incomeExpression rightExpression:sumExpression modifier:NSDirectPredicateModifier type:NSGreaterThanOrEqualToPredicateOperatorType options:0];

    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ namePredicate, incomePredicate ]];

    CSPrintArrayNoIndex(@"Person name with name starting with \'J\' and income greater than 15000: %@", [[sampleItems filteredArrayUsingPredicate:andPredicate] valueForKey:@"name"]);
}

// Custom operations.
- (void)runSample4
{
    NSArray *sampleItems = @[
            SO(@"Jack", CSDateFromYearsSince1970(0), 10000.0),
            SO(@"John", CSDateFromYearsSince1970(10), 20000.0),
            SO(@"Mark", CSDateFromYearsSince1970(20), 30000.0),
            SO(@"Clark", CSDateFromYearsSince1970(30), 40000.0),
            SO(@"Mary", CSDateFromYearsSince1970(40), 50000.0),
    ];

    // Custom operation on array.
    NSString *upcasedNames = [sampleItems valueForKeyPath:@"@upcaseJoin.name"];
    NSLog(@"Upcased names are: %@", upcasedNames);
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
        _relatives = [NSMutableSet set];
    }

    return self;
}

- (instancetype)initWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSSet *)relatives
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

+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income relatives:(NSSet *)relatives
{
    return [[self alloc] initWithName:name birthday:birthday income:income relatives:relatives];
}

+ (instancetype)objectWithName:(NSString *)name birthday:(NSDate *)birthday income:(double)income
{
    return [[self alloc] initWithName:name birthday:birthday income:income];
}

- (void)setRelatives:(NSMutableSet *)relatives
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

@implementation NSArray (CSCollectionOperations)

- (id)_upcaseJoinForKeyPath:(NSString *)keyPath
{
    NSArray *items = [self valueForKeyPath:keyPath];
    NSMutableString *result = [NSMutableString string];
    for (NSString *item in items) {
        if ([result length] > 0) {
            [result appendString:@", "];
        }
        [result appendString:[item uppercaseString]];
    }
    return result;
}

@end