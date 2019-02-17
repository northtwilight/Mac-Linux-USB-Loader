//
//  SBEnterpriseConfigurationWriter.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 10/24/14.
//  Copyright (c) 2014 SevenBits. All rights reserved.
//

#import "SBEnterpriseConfigurationWriter.h"
#import "SBAppDelegate.h"
#import <sys/xattr.h>

#import "SBUbuntuConfigurationWriter.h"
#import "SBDebianConfigurationWriter.h"

@implementation SBEnterpriseConfigurationWriter

- (instancetype)init {
	self = [super init];
	if (self) {
		NSLog(@"SBEnterpriseConfigurationWriter should not be initialized directly.");
	}
	return self;
}

#pragma mark - Need to be overridden
- (NSString *)kernelPath {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
								 userInfo:nil];
}

- (NSString *)kernelParams {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
								 userInfo:nil];
}

- (NSString *)initrdPath {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
								 userInfo:nil];
}

- (NSString *)family {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
								 userInfo:nil];
}

- (NSString *)distributionName {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
								 userInfo:nil];
}

#pragma mark -
+ (instancetype _Nullable) writerForDistributionType:(SBLinuxDistribution)dist {
	switch (dist) {
		case SBDistributionUbuntu:
			return [SBUbuntuConfigurationWriter new];
		case SBDistributionElementaryOS:
			return [SBElementaryConfigurationWriter new];
		case SBDistributionLinuxMint:
			return [SBLinuxMintConfigurationWriter new];
		case SBDistributionDebian:
			return [SBDebianConfigurationWriter new];
		case SBDistributionKali:
			return [SBKaliConfigurationWriter new];
		case SBDistributionTails:
			return [SBTailsConfigurationWriter new];
		default:
			return nil;
	}
}

#pragma mark -
- (BOOL)writeConfigurationToFile:(NSString * _Nonnull)path
					withSettings:(SBEnterpriseConfigurationWriterSettings)settings
						andError:(NSError * _Nonnull * _Nullable)err {
	NSError *error = nil;
	NSMutableString *string = [[NSMutableString alloc] init];

	if (settings.shouldSkipBootMenu) {
		[string appendString:@"autoboot 0\n"];
	}

	[string appendFormat:@"entry %@\n", self.distributionName];
	if (self.family.length > 0)
		[string appendFormat:@"family %@\n", self.family];
	if (self.kernelPath.length > 0)
		[string appendFormat:@"kernel %@ %@\n", self.kernelPath, self.kernelParams];
	if (self.initrdPath.length > 0)
		[string appendFormat:@"initrd %@\n", self.initrdPath];
	BOOL success = [string writeToFile:path atomically:NO encoding:NSASCIIStringEncoding error:&error];

	if (success && settings.shouldHideConfigurationFile) {
		BOOL wasHidden = [NSFileManager toggleVisibilityForFile:path isDirectory:NO];
		if (!wasHidden && err) {
			*err = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOTSUP userInfo:nil];
			return NO;
		}
	}

	if (!success && err)
		*err = error;

	return success;
}

@end
