//
//  CSSample.c
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import "CSSample.h"

@implementation CSSample

+ (id<CSSample>)instanceForSample:(Class)sampleClass
{
    return [[sampleClass alloc] init];
}

- (void)run
{
    [NSException raise:NSInternalInconsistencyException format:@"Method %@ in class %@ is abstract and must be overriden in subclasses", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

@end