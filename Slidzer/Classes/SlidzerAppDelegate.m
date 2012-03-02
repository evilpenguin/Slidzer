//
//  SlidzerAppDelegate.m
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import "SlidzerAppDelegate.h"

@implementation SlidzerAppDelegate
@synthesize window;

#pragma mark -
#pragma mark == SlidzerAppDelegate ==

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect statusBarFrame   = [[UIApplication sharedApplication] statusBarFrame];
    CGRect windowFrame      = [[UIScreen mainScreen] bounds];
    CGRect viewFrame        = CGRectMake(0.0f, statusBarFrame.size.height, windowFrame.size.width, windowFrame.size.height - statusBarFrame.size.height);
    
    window = [[UIWindow alloc] initWithFrame:windowFrame];
    window.backgroundColor = [UIColor blackColor];
    
    puzzleBoardViewController = [[PuzzleBoardViewController alloc] initWithFrame:viewFrame];
    [window addSubview:puzzleBoardViewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}

#pragma mark -
#pragma mark == Memory ==

- (void)dealloc {
    [window release];
    [puzzleBoardViewController release];
    [super dealloc];
}

@end
