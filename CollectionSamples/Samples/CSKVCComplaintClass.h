//
// Created by dmitry.zakharov on 4/2/13.
//


#import <Foundation/Foundation.h>


@interface CSKVCComplaintClass : NSObject {
  @private
    // NSMutableArray *_items;    // ...or "NSMutableArray *items". Makes "items" key accessible via KVC. Least preferable.
    // NSMutableSet *_set;    // ...or "NSMutableSet *set". Makes "set" key accessible via KVC. Least preferable.
}

#pragma mark - Array sample

// @property (nonatomic, readonly) NSMutableArray *items;  // Less preferable.

/* OR, which is more preferable */

// KVC-Compliance for immutable *items*
- (NSUInteger)countOfItems; // REQUIRED

- (NSString *)objectInItemsAtIndex:(NSUInteger)index; // ...OR...
- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes; // EITHER OF THEM ARE REQUIRED

// OPTIONAL
- (void)getItems:(NSString * __unsafe_unretained [])buffer range:(NSRange)inRange;


// KVC-Compliance for mutable *items*
- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes; // ...OR...
- (void)insertObject:(NSString *)object inItemsAtIndex:(NSUInteger)index; // EITHER OF THEM ARE REQUIRED

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes; // ...OR...
- (void)removeObjectFromItemsAtIndex:(NSUInteger)index; // EITHER OF THEM ARE REQUIRED

// OPTIONAL: PERFORMANCE IMPROVEMENT
- (void)replaceObjectInItemsAtIndex:(NSUInteger)index withObject:(NSString *)object; // ...OR..
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array;

#pragma mark - Set sample

// @property (nonatomic, readonly) NSMutableSet *set;    // Less preferable

/* OR, which is more preferable */

// KVC-Compliance for immutable *set*

// ALL REQUIRED
- (NSUInteger)countOfSet;
- (NSEnumerator *)enumeratorOfSet;
- (NSString *)memberOfSet:(NSString *)object;


// KVC-Compliance for mutable *items*

- (void)addSet:(NSSet *)objects;    // ...OR...
- (void)addSetObject:(NSString *)object; // EITHER OF THEM ARE REQUIRED

- (void)removeSet:(NSSet *)objects;    // ...OR...
- (void)removeSetObject:(NSString *)object; // EITHER OF THEM ARE REQUIRED

// OPTIONAL: PERFORMANCE IMPROVEMENT
- (void)intersectSet:(NSSet *)objects;
- (void)setSet:(NSMutableSet *)set;

@end