//
//  SBUSBDevice.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/18/14.
//  Copyright (c) 2014 SevenBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBGlobals.h"
#import "SBDocument.h"
#import "SBEnterpriseSourceLocation.h"

@interface SBUSBDevice : NSObject

/// An enumeration containing various supported Linux distributions.
typedef NS_ENUM (NSInteger, SBUSBDriveFileSystem) {
	/// An enum type representing the FAT32 file system.
	SBUSBDriveFileSystemFAT32,
	/// An enum type representing the HFS+ file system.
	SBUSBDriveFileSystemHFS,
	/// An enum type representing an unknown file system.
	SBUSBDriveFileSystemOther
};

/// The path (including the mount point) of the USB drive represented by this object.
@property (nonatomic, strong) NSString *path;

/// The "name" of the USB; really just its drive label.
@property (nonatomic, strong) NSString *name;

/// The file system of the USB drive.
@property (nonatomic) SBUSBDriveFileSystem fileSystem;

/// Whether the USB is currently being used.
@property BOOL USBIsInUse;

/**
 * Configures this USB drive with the files and options that are needed to add it to the Startup Disk selector
 * in System Preferences.
 *
 * @param error A pointer which will point to an NSError object containing failure information if the file cannot be opened.
 * @return YES if the operation succeeded, NO if it did not.
 */
- (BOOL)openConfigurationFileWithError:(NSError **)error;

@end
