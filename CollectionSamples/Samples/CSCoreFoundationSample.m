//
// Created by dmitry.zakharov on 4/2/13.
//


#import "CSCoreFoundationSample.h"

static void CSPrintValues(CFTypeRef value, void *context)
{
    NSLog(@"Value: %@", (__bridge NSString *)value);
}

@implementation CSCoreFoundationSample

- (void)run
{
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void *[]){ CFSTR("String 1"), CFSTR("String 2"), CFSTR("String 3") }, 3, &kCFTypeArrayCallBacks);
    CFMutableArrayRef mutableArray = CFArrayCreateMutable(kCFAllocatorDefault, 10, &kCFTypeArrayCallBacks);

    CFArrayApplyFunction(array, CFRangeMake(0, CFArrayGetCount(array)), CSPrintValues, NULL);

    CFRelease(array);
    CFRelease(mutableArray);
}


@end