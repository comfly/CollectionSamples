//
//  CSSample.h
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSample <NSObject>

@required
- (void)run;

@end

@interface CSSample : NSObject <CSSample>

+ (id<CSSample>)instanceForSample:(Class)sampleClass;

@end