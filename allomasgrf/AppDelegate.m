//
//  AppDelegate.m
//  allomasgrf
//
//  Created by Kiss Ferenc on 2014.02.06..
//  Copyright (c) 2014 Kiss Ferenc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	// Insert code here to initialize your application
//	NSString *docpath = [[[NSProcessInfo processInfo] environment] objectForKey: @"SRCROOT"];
//	NSTask *task = [NSTask launchedTaskWithLaunchPath: [docpath stringByAppendingPathComponent: @"create.sh"] arguments: [NSArray array]];

//	[task waitUntilExit];

	NSURL* scriptURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource: @"reloadOTTD" ofType: @"scpt"]];
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL: scriptURL error: nil];
	[appleScript executeAndReturnError: nil];
	[[NSApplication sharedApplication] terminate: self];
}

@end
