//
//  SBUbuntuConfigurationWriter.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 1/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBEnterpriseConfigurationWriter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBUbuntuConfigurationWriter : SBEnterpriseConfigurationWriter

@end

@interface SBLinuxMintConfigurationWriter : SBUbuntuConfigurationWriter

@end

@interface SBElementaryConfigurationWriter : SBUbuntuConfigurationWriter

@end

NS_ASSUME_NONNULL_END
