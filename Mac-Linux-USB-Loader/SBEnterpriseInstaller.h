//
//  SBEnterpriseInstaller.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUSBDevice.h"
#import "SBEnterpriseSourceLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBEnterpriseInstaller : NSObject

/**
 * Initializes a new object with an optional document to which progress
 * should be reported.
 *
 * @param doc An optional document to which progress should be reported.
 * @return The initialized object.
 */
- (instancetype)initWithAttachedDocument:(SBDocument *)doc;

/**
 * Copies the ISO file to the USB device represented by this object.
 *
 * @param usb The USB drive to which the files should be copied.
 * @param fromPath The path of the ISO file to be copied.
 * @return YES if the operation succeeded, NO if it did not.
 */
- (BOOL)copyInstallationFilesToUSB:(SBUSBDevice *)usb
				 withSourceISOPath:(NSString *)fromPath;

/**
 * Copies the Enterprise boot loader to the USB device represented by this object.
 * This method does not attempt to deal with any potential sandboxing issues, such as
 * security scoped bookmarks, instead assuming that the user already has granted
 * access to the target USB device.
 *
 * @param usb The USB drive to which the files should be copied.
 * @param source The source to use for the Enterprise bootloader files.
 * @return YES if the operation succeeded, NO if it did not.
 */
- (BOOL)copyEnterpriseFilesToUSB:(SBUSBDevice *)usb
			 andEnterpriseSource:(SBEnterpriseSourceLocation *)source;

/**
 * Configures this USB drive with the files and options that are needed to add it to
 * the Startup Disk selector in System Preferences.
 *
 * @param usb The USB drive to configure.
 * @return YES if the operation succeeded, NO if it did not.
 */
+ (BOOL)enableStartupDiskSupportForUSB:(SBUSBDevice *)usb;

@end

NS_ASSUME_NONNULL_END
