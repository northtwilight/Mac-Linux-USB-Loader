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

/*+ (void)writeConfigurationFileAtUSB:(SBUSBDevice *)device distributionFamily:(SBLinuxDistribution)family lacksEfiEnabledKernel:(BOOL)efiDisabled containsLegacyUbuntuVersion:(BOOL)containsLegacyUbuntu shouldSkipBootMenu:(BOOL)shouldSkip {
	NSError *error;
	NSString *distributionId = [SBAppDelegate distributionStringForEquivalentEnum:family];

	NSString *path = [device.path stringByAppendingPathComponent:@"/efi/boot/enterprise.cfg"];
	NSMutableString *string = [NSMutableString stringWithCapacity:30];

	if (family != SBDistributionUnknown) {
		[string appendString:@"#This file is machine generated. Do not modify it unless you know what you are doing.\n\n"];
		if (shouldSkip) [string appendString:@"autoboot 0\n"];
		[string appendFormat:@"entry %@\n", distributionId];
		[string appendFormat:@"family %@\n", ([distributionId isEqualToString:@"Kali"] || [distributionId isEqualToString:@"Tails"]) ? @"Debian" : distributionId];

		if (family == SBDistributionUbuntu) {
			NSMutableString *kernelString = [NSMutableString stringWithString:@"kernel "];

			// I know that this seems a bit redundant, checking for legacy Ubuntu twice, but we have to because if we don't,
			// it would be impossible to have both options be enabled.
			if (efiDisabled) {
				[kernelString appendString:@"/casper/vmlinuz "];
				if (containsLegacyUbuntu) {
					[kernelString appendString:@"file=/cdrom/preseed/ubuntu.seed"];
				}
			} else if (containsLegacyUbuntu) {
				[kernelString appendString:@"/casper/vmlinuz.efi file=/cdrom/preseed/ubuntu.seed"];
			} else {
				[kernelString appendString:@"/casper/vmlinuz.efi "];
			}

			[kernelString appendString:@"\n"];
			[kernelString appendString:@"initrd /casper/initrd\n"];
			[string appendString:kernelString];
		} else if (family == SBDistributionKali) {
			[string appendString:@"kernel /live/vmlinuz findiso=/efi/boot/boot.iso boot=live noconfig=sudo username=root hostname=kali\n"];
			[string appendString:@"\nentry Kali (installer)\n"];
			[string appendString:@"family Debian\ninitrd /install/gtk/initrd.gz\nkernel /install/gtk/vmlinuz findiso=/efi/boot/boot.iso boot=live noconfig=sudo username=root hostname=kali"];
		} else if (family == SBDistributionTails) {
			[string appendString:@"kernel /live/vmlinuz findiso=/efi/boot/boot.iso boot=live config live-media=removable noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 nox11autologin module=Tails quiet splash\n"];
		} else if (family == SBDistributionDebian) {
			[string appendString:@"kernel /live/vmlinuz findiso=/efi/boot/boot.iso boot=live config live-config quiet splash"];
		}
	} else {
		// The user has selected the "Other" option in the distribution family.
		// Put text into the configuration file telling the user how to use it.
		[string appendString:@"# enterprise.cfg\n"];
		[string appendString:@"#\n"];
		[string appendString:@"# This file is used to configure Enterprise. You need to fill out the following parameters "];
		[string appendString:@"according to how your desired Linux distribution configures its ISO file.\n\n"];
		[string appendString:@"entry Custom Linux\n"];
		[string appendString:@"kernel /path/to/kernel ...\n"];
		[string appendString:@"initrd /path/to/initrd\n"];
		[string appendString:@"# Please see https://sevenbits.github.io/Enterprise/ for more information.\n"];
	}

	// Delete the old configuration file; otherwise we can't write a new one.
	if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
		NSLog(@"Error removing old configuration file: %@", error);
	}

	// Write the new configuration file.
	BOOL success = [string writeToFile:path atomically:NO encoding:NSASCIIStringEncoding error:&error];
	if (!success) {
		NSLog(@"Error writing configuration file: %@", error);
	}

	// Hide the configuration file if the user has indicated that they desire this behavior.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"HideConfigurationFile"]) {
		BOOL result = [NSFileManager toggleVisibilityForFile:path isDirectory:NO];
		if (!result) {
			NSLog(@"Failed to hide configuration file.");
		}
	}
}*/

@end
