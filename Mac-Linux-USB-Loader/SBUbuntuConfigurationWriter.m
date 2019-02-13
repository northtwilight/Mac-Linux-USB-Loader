//
//  SBUbuntuConfigurationWriter.m
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import "SBUbuntuConfigurationWriter.h"

@implementation SBUbuntuConfigurationWriter

- (NSString *)kernelPath {
	return @"/casper/vmlinuz";
}

- (NSString *)kernelParams {
	return @"";
}

- (NSString *)initrdPath {
	return @"/casper/initrd";
}

- (NSString *)family {
	return @"Ubuntu";
}

- (NSString *)distributionName {
	return @"Ubuntu";
}

@end

@implementation SBLinuxMintConfigurationWriter

- (NSString *)initrdPath {
	return @"/casper/initrd.lz";
}

- (NSString *)distributionName {
	return @"Linux Mint";
}

@end

@implementation SBElementaryConfigurationWriter

- (NSString *)initrdPath {
	return @"/casper/initrd.lz";
}

- (NSString *)distributionName {
	return @"elementary OS";
}

@end
