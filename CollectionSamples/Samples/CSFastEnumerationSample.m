#import <Foundation/Foundation.h>
#import "CSFastEnumerationSample.h"


@interface CSRandomValuesGenerator : NSObject <NSFastEnumeration>

- (instancetype)initWithMaxItem:(NSUInteger)maxItem stopItem:(NSUInteger)stopItem;

@end

@interface CSFastEnumerationSample ()

@end

@implementation CSFastEnumerationSample

- (void)run
{
    CSRandomValuesGenerator *generator = [[CSRandomValuesGenerator alloc] initWithMaxItem:30 stopItem:7];
    for (NSNumber *randomNumber in generator) {
        int value = [randomNumber intValue];
        NSLog(@"Next random value: %d", value);
    }
}

@end



@implementation CSRandomValuesGenerator {
  @private
    NSUInteger _maxItem;
    NSUInteger _stopItem;

    unsigned long _mutationsCounter;
}

- (instancetype)initWithMaxItem:(NSUInteger)maxItem stopItem:(NSUInteger)stopItem
{
    self = [self init];
    if (self) {
        _maxItem = maxItem;
        _stopItem = stopItem;
        _mutationsCounter = 0UL;
    }

    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len
{
    if (state->state == 0UL) {
        // We entered enumeration for the first time. Initialize
        state->state = 1UL; // Off we go.

        state->extra[0] = _maxItem; // Further we can access them to get the options.
        state->extra[1] = _stopItem;
        
        state->mutationsPtr = state->extra; // We do not support mutations, therefore we go with some constant value.
                                            // Otherwise, mutationsPtr must point to a counter of mutations
                                            // which will be compared with the prev. version of the field by the engine
                                            // as soon as the control leaves the method.
                                            // Our mutators must update the value to prevent mutations in iterators.
    } else if (state->state == 2UL) {
        // Done.
        return 0;
    }

    state->itemsPtr = buffer;   // Buffer is optional. We can ignore it and go with state->itemsPtr solely.
    // Let's get some items.
    for (NSUInteger nextItemIndex = 0; nextItemIndex < len; ++nextItemIndex) {
        int nextRandom = arc4random() % _maxItem;
        state->itemsPtr[nextItemIndex] = @(nextRandom);
        if (nextRandom == _stopItem) {
            // Signal stop the next time.
            state->state = 2UL; // Which means an end of the sequence.
            return nextItemIndex + 1;
        }
    }

    return len;
}

@end