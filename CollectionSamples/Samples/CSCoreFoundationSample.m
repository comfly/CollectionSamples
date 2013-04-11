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
    // Samples 1 + 3 + 1 = 5
    RUN_CASE(1);
}

// CFArray samples.
- (void)runSample1
{
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void *[]){ CFSTR("String 1"), CFSTR("String 2"), CFSTR("String 3") }, 3, &kCFTypeArrayCallBacks);
    CFArrayApplyFunction(array, CFRangeMake(0, CFArrayGetCount(array)), CSPrintValues, NULL);

    // Makes a fixed-sized array with the capacity of 10.
    CFMutableArrayRef mutableArray = CFArrayCreateMutable(kCFAllocatorDefault, 10, &kCFTypeArrayCallBacks);

    extern CFStringRef CSCopyDescriptionFunction(const void *value);

    // Array of simple integers.
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.release = NULL;
    callbacks.retain = NULL;
    callbacks.equal = NULL;
    callbacks.copyDescription = CSCopyDescriptionFunction;

    // Specifying zero in *capacity* parameter makes the array of variable size.
    CFMutableArrayRef mutableArrayOfIntegers = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);

    CFArrayAppendValue(mutableArrayOfIntegers, (const void *)10);
    CFArrayAppendValue(mutableArrayOfIntegers, (const void *)20);
    CFArrayAppendValue(mutableArrayOfIntegers, (const void *)30);

    for (int index = 0; index < CFArrayGetCount(mutableArrayOfIntegers); ++index) {
        int value = (int) CFArrayGetValueAtIndex(mutableArrayOfIntegers, index);
        NSLog(@"Value at index %d is %d", index, value);
    }

    // This will fail.
//    NSMutableArray *intValues = (__bridge_transfer NSMutableArray *)mutableArrayOfIntegers;
//    NSLog(@"Values %@", intValues);
//    for (int index = 0; index < [intValues count]; ++index) {
//        int value = (int) [intValues objectAtIndex:index];
//        NSLog(@"Value at index from NSArray %d is %d", index, value);
//    }


    CFRelease(mutableArrayOfIntegers);
    CFRelease(array);
    CFRelease(mutableArray);
}

static CFStringRef CSCopyDescriptionFunction(const void *value)
{
    int intValue = (int)value;
    return (__bridge CFStringRef) [NSString stringWithFormat:@"%d", intValue];
}

// CFDictionary sample with weak.
- (void)runSample2
{
    // Simply array-like dictionary with weak values.

    // Pointer-sized integer keys.
    CFDictionaryKeyCallBacks *keyCallBacks = NULL;

    // Weak values.
    CFDictionaryValueCallBacks weakValuesCallbacks = { 0, NULL, NULL, CFCopyDescription, CFEqual };
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(NULL, 0, keyCallBacks, &weakValuesCallbacks);

    CFStringRef value1 = CFStringCreateWithCString(NULL, "Hello", kCFStringEncodingUTF8);

    NSLog(@"Retain count before adding: %ld", CFGetRetainCount(value1));

    CFDictionaryAddValue(dictionary, (const void *)1, value1);

    NSLog(@"Retain count after adding: %ld", CFGetRetainCount(value1));

    CFRelease(value1);

    // The following will fail.
//    CFStringRef value = CFDictionaryGetValue(dictionary, (const void *)1);
//
//    NSLog(@"Retain count after releasing: %ld", CFGetRetainCount(value));
//    CFShow(value);

    CFRelease(dictionary);
}

// Copying CFDictionary. __bridging sample.
- (void)runSample3
{
    // Keys are strings and values are strings that are copied on Setting.
    extern const CFStringRef CSCopier(CFAllocatorRef allocator, CFStringRef value);
    extern void CSReleaser(CFAllocatorRef allocator, CFStringRef value);

    CFDictionaryValueCallBacks copyingValuesDictionary = { 0, (CFDictionaryRetainCallBack) CSCopier, (CFDictionaryReleaseCallBack) CSReleaser, CFCopyDescription, CFEqual };
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &copyingValuesDictionary);

    CFMutableStringRef valueBeforeAdding = CFStringCreateMutableCopy(NULL, 7, CFSTR("Value 1"));
    CFDictionarySetValue(dictionary, CFSTR("Key 1"), valueBeforeAdding);
    CFStringRef valueAfterAdding = CFDictionaryGetValue(dictionary, CFSTR("Key 1"));

    NSLog(@"Before adding and after adding are equal: %d", valueBeforeAdding == valueAfterAdding);
    CFRelease(valueBeforeAdding);

    // Create wrapper with preserving behavior pattern.
    NSMutableString *valueBeforeAdding2 = [NSMutableString stringWithFormat:@"Hello"];
    NSMutableDictionary *wrapper = (__bridge NSMutableDictionary *)dictionary;
    [wrapper setObject:valueBeforeAdding2 forKey:@"Key 2"];

    NSMutableString *valueAfterAdding2 = wrapper[@"Key 2"];
    NSLog(@"Before adding and after adding are equal: %d", valueBeforeAdding2 == valueAfterAdding2);

    CFRelease(dictionary);
}


// NULL values are allowed.
- (void)runSample4
{
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(0, 0, &kCFCopyStringDictionaryKeyCallBacks, NULL);
    CFDictionarySetValue(dictionary, CFSTR("Key"), (CFStringRef)NULL);
    CFStringRef nullValue = CFDictionaryGetValue(dictionary, CFSTR("Key"));
    NSLog(@"Null value is %@", (__bridge NSString *)nullValue ?: @"NULL");
    CFStringRef possibleValue;
    if (CFDictionaryGetValueIfPresent(dictionary, CFSTR("Key 1"), (const void **)&possibleValue)) {
        NSLog(@"We have a value with Key 1: %@", (__bridge NSString *)possibleValue);
    }
    CFRelease(dictionary);
}

static const CFStringRef CSCopier(CFAllocatorRef allocator, CFStringRef value)
{
    CFTypeRef copy = CFStringCreateCopy(NULL, value);
    return copy;
}

static void CSReleaser(CFAllocatorRef allocator, CFStringRef value)
{
    CFRelease(value);
}

- (void)runSample5
{
    CFTreeContext context = { 0, (void *) CFSTR("Root"), CFRetain, CFRelease, CFCopyDescription };
    CFTreeRef root = CFTreeCreate(NULL, &context);

    context.info = (void *) CFSTR("Leaf 2");
    CFTreeRef leftChild = CFTreeCreate(NULL, &context);
    CFTreeAppendChild(root, leftChild);
    CFRelease(leftChild);

    context.info = (void *) CFSTR("Leaf 1");
    CFTreeRef rightChild = CFTreeCreate(NULL, &context);
    CFTreeAppendChild(root, rightChild);
    CFRelease(rightChild);

    extern CFComparisonResult CSStringComparator(CFTreeRef, CFTreeRef, void *);
    CFTreeSortChildren(root, (CFComparatorFunction) CSStringComparator, NULL);

    CFTreeRef child = CFTreeGetFirstChild(root);
    while (child) {
        CFTreeContext context;
        CFTreeGetContext(child, &context);
        NSLog(@"Child value is %@", (__bridge NSString *) (CFStringRef)context.info);
        child = CFTreeGetNextSibling(child);
    }

    CFRelease(root);
}

static CFComparisonResult CSStringComparator(CFTreeRef value1, CFTreeRef value2, void *context)
{
    CFTreeContext context1;
    CFTreeGetContext(value1, &context1);
    CFTreeContext context2;
    CFTreeGetContext(value2, &context2);
    return CFStringCompare((CFStringRef) context1.info, (CFStringRef)context2.info, 0);
}

@end