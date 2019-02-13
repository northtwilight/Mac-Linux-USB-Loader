//
//  SBEnterpriseConfigurationWriter.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 10/24/14.
//  Copyright (c) 2014 SevenBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBUSBDevice.h"

typedef struct {
	BOOL shouldSkipBootMenu;
	BOOL shouldHideConfigurationFile;
} SBEnterpriseConfigurationWriterSettings;

/**
 * Writes Enterprise configuration files.
 *
 * This is an abstract class. You should not create an instance of
 * this class. Instead, you should interact with its subclasses.
 * You can retrieve the subclass you should use by calling the
 * distributionWriterForDistributionType: method.
 */
@interface SBEnterpriseConfigurationWriter : NSObject

/**
 * Gets the correct configuration writer subclass for the specified
 * distribution type.
 *
 * @param dist The distribution whose configuration file we need to
 *             write.
 * @return The correct configuration writer subclass for the specified
 *         distribution type.
 */
+ (instancetype _Nullable)writerForDistributionType:(SBLinuxDistribution)dist;

/**
 * Writes the configuration file to the specified path.
 * This method requires a settings object to specify, e.g.,
 * whether or not to skip the boot menu.
 *
 * @param path The path to write to.
 * @param settings The settings object.
 * @param err An optional error object.
 * @return YES if the file was successfully written, NO otherwise. On
 *         failure, the error object will be supplied.
 */
- (BOOL)writeConfigurationToFile:(NSString * _Nonnull)path
					withSettings:(SBEnterpriseConfigurationWriterSettings)settings
						andError:(NSError * _Nonnull * _Nullable)err;

/**
 * Writes the Enterprise configuration for the given distribution to the specified USB device.
 */
//+ (void)writeConfigurationFileAtUSB:(SBUSBDevice *)device distributionFamily:(SBLinuxDistribution)family lacksEfiEnabledKernel:(BOOL)isMacUbuntu containsLegacyUbuntuVersion:(BOOL)containsLegacyUbuntu shouldSkipBootMenu:(BOOL)shouldSkip;

/// The path to the Linux kernel inside of this ISO.
@property (readonly, nonatomic, copy) NSString * _Nonnull kernelPath;
/// Which kernel parameters need to be passed on boot.
@property (readonly, nonatomic, copy) NSString * _Nonnull kernelParams;
/// The path to the Linux initrd inside of this ISO.
@property (readonly, nonatomic, copy) NSString * _Nonnull initrdPath;
/// The distribution family.
@property (readonly, nonatomic, copy) NSString * _Nonnull family;
/// The distribution name.
@property (readonly, nonatomic, copy) NSString * _Nonnull distributionName;

@end
