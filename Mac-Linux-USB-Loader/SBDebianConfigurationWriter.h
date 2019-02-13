//
//  SBDebianConfigurationWriter.h
//  Mac Linux USB Loader
//
//  Created by SevenBits on 2/17/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

#import "SBEnterpriseConfigurationWriter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBDebianConfigurationWriter : SBEnterpriseConfigurationWriter

@end

@interface SBKaliConfigurationWriter : SBDebianConfigurationWriter

@end

@interface SBTailsConfigurationWriter : SBDebianConfigurationWriter

@end

NS_ASSUME_NONNULL_END
