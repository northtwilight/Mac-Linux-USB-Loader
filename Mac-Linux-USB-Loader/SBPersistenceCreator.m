//
//  SBPersistenceCreator.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import "SBPersistenceCreator.h"

@implementation SBPersistenceCreator

+ (void)createPersistenceFileAtPath:(NSString *)file withSize:(NSUInteger)size __attribute__((pure)) {
	// Initalize the NSTask.
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/bin/dd";
	task.arguments = @[@"if=/dev/zero", [@"of=" stringByAppendingString:file], @"bs=1m", [NSString stringWithFormat:@"count=%ld", (long)size]];
#ifdef DEBUG
	NSLog(@"command: %@ %@", task.launchPath, [task.arguments componentsJoinedByString:@" "]);
#endif
	
	// Launch the NSTask.
	[task launch];
	[task waitUntilExit];
	
	// Create the loopback file.
#ifdef DEBUG
	NSLog(@"Done USB persistence creation!");
#endif
}

+ (void)createLoopbackPersistenceInFile:(NSString *)file __attribute__((pure)) {
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *helperAppPath = [mainBundle.bundlePath stringByAppendingString:@"/Contents/Resources/Tools/mke2fs"];
	
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = helperAppPath;
	task.arguments = @[@"-qF", @"-t", @"ext4", file];
	[task launch];
	[task waitUntilExit];
}

@end
