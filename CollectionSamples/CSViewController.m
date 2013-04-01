//
//  CSViewController.m
//  CollectionSamples
//
//  Created by Dmitry Zakharov on 4/1/13.
//  Copyright (c) 2013 Dmitry Zakharov. All rights reserved.
//

#import "CSBasicsSample.h"
#import "CSSample.h"

#import "CurrentSample.h"

#import "CSViewController.h"

@interface CSViewController ()

@end

@implementation CSViewController

- (IBAction)runSampleTapped
{
    CSSample *activeSample = [CSSample instanceForSample:[CURRENT_SAMPLE class]];
    [activeSample run];
}

@end
