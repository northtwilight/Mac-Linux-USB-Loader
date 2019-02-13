//
//  SBUSBDevice.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/18/14.
//  Copyright (c) 2014 SevenBits. All rights reserved.
//

#import "SBUSBDevice.h"
#import "NSString+Extensions.h"

@implementation SBUSBDevice

#pragma mark - Instance methods
- (instancetype)init {
	self = [super init];
	if (self) {
		// Add your subclass-specific initialization here.
	}
	return self;
}

- (NSString *)enterpriseConfigurationPath {
	return [self.path stringByAppendingPathComponent:@"/efi/boot/enterprise.cfg"];
}

- (BOOL)openConfigurationFileWithError:(NSError **)error {
	NSString *path = self.enterpriseConfigurationPath;
	NSString *deprecatedPath = [self.path stringByAppendingPathComponent:@"/efi/boot/.MLUL-Live-USB"];
	NSURL *outURL = [[NSFileManager defaultManager] setupSecurityScopedBookmarkForUSBAtPath:self.path withWindowForSheet:nil];
	[outURL startAccessingSecurityScopedResource];
	NSFileManager *fm = [NSFileManager defaultManager];

	BOOL success = NO;

	// If the file doesn't exist, print out an error and exit.
	if (![fm fileExistsAtPath:path] && ![fm fileExistsAtPath:deprecatedPath]) {
		if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
		return NO;
	}

	// Try to open the configuration file in TextEdit.
	if (![[NSWorkspace sharedWorkspace] openFile:path withApplication:@"TextEdit"]) {
		success = [[NSWorkspace sharedWorkspace] openFile:deprecatedPath withApplication:@"TextEdit"];

		if (!success) NSLog(@"Couldn't open configuration file.");
	}
	[outURL stopAccessingSecurityScopedResource];

	if (!success && error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
	return success;
}

@end
