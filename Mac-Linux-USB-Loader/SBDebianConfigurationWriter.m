//
//  SBDebianConfigurationWriter.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 2/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import "SBDebianConfigurationWriter.h"

@implementation SBDebianConfigurationWriter

- (NSString *)kernelPath {
	return @"/live/vmlinuz";
}

- (NSString *)kernelParams {
	return @"findiso=/efi/boot/boot.iso boot=live config live-config quiet splash";
}

- (NSString *)initrdPath {
	return @"";
}

- (NSString *)family {
	return @"Debian";
}

- (NSString *)distributionName {
	return @"Debian";
}

@end

@implementation SBKaliConfigurationWriter

// This is overwritten for Kali because we need to write
// separate entries for both the live CD and installer.
- (BOOL)writeConfigurationToFile:(NSString * _Nonnull)path
					withSettings:(SBEnterpriseConfigurationWriterSettings)settings
						andError:(NSError * _Nonnull * _Nullable)err {
	NSError *error = nil;
	NSMutableString *string = [NSMutableString new];
	const char *s = "entry Kali (live)\n"
	"family Debian\n"
	"kernel /live/vmlinuz findiso=/efi/boot/boot.iso boot=live noconfig=sudo username=root hostname=kali\n"
	"\n"
	"entry Kali (install)\n"
	"family Debian\n"
	"kernel install/gtk/vmlinuz findiso=/efi/boot/boot.iso boot=live noconfig=sudo username=root hostname=kali\n";

	if (settings.shouldSkipBootMenu) {
		[string appendString:@"autoboot 0\n"];
	}
	[string appendString:[NSString stringWithUTF8String:s]];

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

@implementation SBTailsConfigurationWriter

- (NSString *)kernelParams {
	return @"/live/vmlinuz findiso=/efi/boot/boot.iso boot=live config live-media=removable noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 nox11autologin module=Tails quiet splash";
}

- (NSString *)distributionName {
	return @"Tails";
}

@end
