//
//  SBPersistenceCreator.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUSBDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBPersistenceCreator : NSObject

/**
 * Creates a persistence file on the USB stick of the specified size. The file is
 formatted to contain a loopback ext4 filesystem.
 *
 * @param file The path to the file (which doesn't need to exist) that should be used.
 * @param size An integer size, in megabytes, of the file.
 */
+ (void)createPersistenceFileAtPath:(NSString *)file withSize:(NSUInteger)size;

/**
 * Uses an internal Mac Linux USB Loader tool to create a loopback ext4 filesystem
 inside of the specified file. This is used mainly by createPersistenceFileAtPath:,
 and doesn't really need to be called directly.
 *
 * @param file The path to the file that should be used.
 */
+ (void)createLoopbackPersistenceInFile:(NSString *)file;

@end

NS_ASSUME_NONNULL_END
