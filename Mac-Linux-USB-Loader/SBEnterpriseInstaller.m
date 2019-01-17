//
//  SBEnterpriseInstaller.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import <copyfile.h>
#import "SBDocument.h"
#import "SBEnterpriseInstaller.h"

#define SBNumberOfCopyfileStates 3
typedef NS_ENUM(unsigned int, State) {
	NotStarted = 0,
	InProgress,
	Finished,
};

@implementation SBEnterpriseInstaller {
	copyfile_state_t _copyfileState[SBNumberOfCopyfileStates];
	State _state;
	NSTimer *_progressTimer;

	SBDocument * _Nonnull _attachedDocument;
}

- (instancetype)initWithAttachedDocument:(SBDocument *)doc {
	self = [super init];
	if (self) {
		_progressTimer = nil;

		if (doc) {
			_attachedDocument = doc;
		}
	}
	return self;
}

- (void)dealloc {
	if (_state > NotStarted) {
		for (unsigned int i = 0; i < SBNumberOfCopyfileStates; i++) {
			copyfile_state_free(_copyfileState[i]);
		}

		[_progressTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
		_progressTimer = nil;
	}
}

- (void)startTimerIfNotActive {
	if (_attachedDocument && (!self->_progressTimer || _state != InProgress)) {
		self->_progressTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(outputProgress:) userInfo:@{} repeats:YES];
		[NSRunLoop.mainRunLoop addTimer:self->_progressTimer forMode:NSRunLoopCommonModes];
	}
}

- (BOOL)copyInstallationFilesToUSB:(SBUSBDevice *)usb
				 withSourceISOPath:(NSString *)fromPath {
	// Create an operation for the operation queue to copy over the necessary files.
	usb.USBIsInUse = YES;
	NSString *finalISOCopyPath = [usb.path stringByAppendingPathComponent:@"/efi/boot/boot.iso"];

	const char * const toPath = finalISOCopyPath.UTF8String;
	
	NSLog(@"from: %@ to: %s", fromPath, toPath);
	NSLog(@"Will start copying");
	
	int returnCode;
	_copyfileState[0] = copyfile_state_alloc();
	{
		_state = InProgress;

		[self startTimerIfNotActive];
		returnCode = copyfile(fromPath.UTF8String, toPath, _copyfileState[0], COPYFILE_ALL);
		
		if (returnCode == 0) {
			_state = Finished;
		} else {
			NSLog(@"Did finish copying with return code %d", returnCode);
		}
	}
	
	NSLog(@"Did finish copying with return code %d", returnCode);
	return YES;
}

- (BOOL)copyEnterpriseFilesToUSB:(SBUSBDevice *)usb
			 andEnterpriseSource:(SBEnterpriseSourceLocation *)source {
	// Create an operation for the operation queue to copy over the necessary files.
	usb.USBIsInUse = YES;
	NSString *finalEnterpriseCopyPath = [usb.path stringByAppendingPathComponent:@"/efi/boot/bootX64.efi"];
	NSString *finalGRUBCopyPath = [usb.path stringByAppendingPathComponent:@"/efi/boot/boot.efi"];
	
	// First, copy Enterprise.
	const char *fromPath = [source.path stringByAppendingPathComponent:@"bootX64.efi"].UTF8String;
	const char *toPath = finalEnterpriseCopyPath.UTF8String;
	
	NSLog(@"from: %s to: %s", fromPath, toPath);
	NSLog(@"Will start copying");
	
	int returnCode;
	_copyfileState[1] = copyfile_state_alloc();
	{
		_state = InProgress;

		[self startTimerIfNotActive];
		returnCode = copyfile(fromPath, toPath, _copyfileState[1], COPYFILE_ALL);
		if (returnCode != 0) {
			NSLog(@"Did finish copying with return code %d", returnCode);
		}
	}
	
	// Next, copy GRUB.
	fromPath = [source.path stringByAppendingPathComponent:@"boot.efi"].UTF8String;
	toPath = finalGRUBCopyPath.UTF8String;
	
	NSLog(@"from: %s to: %s", fromPath, toPath);
	NSLog(@"Will start copying");
	
	_copyfileState[2] = copyfile_state_alloc();
	{
		_state = InProgress;

		returnCode = copyfile(fromPath, toPath, _copyfileState[2], COPYFILE_ALL);
		if (returnCode != 0) {
			NSLog(@"Did finish copying with return code %d", returnCode);
		} else {
			_state = Finished;
		}
	}
	
	NSLog(@"Did finish copying with return code %d", returnCode);
	return YES;
}

- (void)outputProgress:(NSTimer *)timer {
	switch (_state) {
		case NotStarted:
			NSLog(@"Not started yet");
			break;
			
		case Finished:
			NSLog(@"Finished");
			break;
			
		case InProgress: {
			off_t copiedBytes = 0;
			int returnCode = 0;

			for (unsigned int i = 0; i < SBNumberOfCopyfileStates; i++) {
				// Internally copyfile_state_t seems to be a pointer,
				// but this might not be portable.
				if (!_copyfileState[i]) continue;

				off_t tmp_cpy = 0;
				returnCode |= copyfile_state_get(_copyfileState[i], COPYFILE_STATE_COPIED, &tmp_cpy);
				copiedBytes += tmp_cpy;
			}

			if (returnCode == 0) {
				//NSLog(@"Copied %@ so far", [NSByteCountFormatter stringFromByteCount:copiedBytes countStyle:NSByteCountFormatterCountStyleFile]);
				_attachedDocument.installationProgressBar.doubleValue = copiedBytes;
			}
			else {
				NSLog(@"Could not retrieve copyfile state");
			}
			
			break;
		}
	}
}

+ (BOOL)enableStartupDiskSupportForUSB:(SBUSBDevice *)usb {
	// Create the paths to the necessary files and folders
	NSString *finalPath = [usb.path stringByAppendingPathComponent:@"/System/Library/CoreServices/"];
	NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"SystemVersion" ofType:@"plist"];
	NSError *err;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// Create dummy files to fool OS X
	[fm createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:nil];
	[fm copyItemAtPath:plistFilePath toPath:[finalPath stringByAppendingPathComponent:@"SystemVersion.plist"] error:&err];
	[@"Dummy EFI boot loader to fool OS X" writeToFile:[finalPath stringByAppendingPathComponent:@"boot.efi"] atomically:YES encoding:NSASCIIStringEncoding error:&err];
	[@"Dummy kernel to fool OS X" writeToFile:[usb.path stringByAppendingPathComponent:@"mach_kernel"] atomically:YES encoding:NSASCIIStringEncoding error:&err];
	
	// Add an app icon
	NSString *diskIconPath = [[NSBundle mainBundle] pathForResource:@"mlul-disk" ofType:@"icns"];
	[fm copyItemAtPath:diskIconPath toPath:[usb.path stringByAppendingPathComponent:@".VolumeIcon.icns"] error:&err];
	//[NSTask launchedTaskWithLaunchPath:@"/usr/bin/SetFile" arguments:@[@"-a", @"C", self.path]];
	
	return YES;
}

@end
