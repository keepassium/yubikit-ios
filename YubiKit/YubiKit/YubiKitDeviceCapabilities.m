// Copyright 2018-2019 Yubico AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>

#import "UIDeviceAdditions.h"
#import "UIDevice+Testing.h"

#import "YubiKitDeviceCapabilities.h"

@interface YubiKitDeviceCapabilities()

@property (class, nonatomic, readonly) id<YKFUIDeviceProtocol> currentUIDevice;

@end

@implementation YubiKitDeviceCapabilities

+ (BOOL)supportsQRCodeScanning {
    if (self.currentUIDevice.ykf_deviceModel == YKFDeviceModelSimulator) {
        return NO;
    }
    
    if (@available(iOS 8, *)) {
        return YES;
    }
    return NO;
}

+ (BOOL)supportsNFCScanning {
    if (self.currentUIDevice.ykf_deviceModel == YKFDeviceModelSimulator) {
        return NO;
    }
    if (@available(iOS 11, *)) {
        // This check was introduced to avoid some random crashers caused by CoreNFC on devices which are not NFC enabled.
        if ([self deviceIsNFCEnabled]) {
            return NFCNDEFReaderSession.readingAvailable;
        }
        return NO;
    }
    return NO;
}

+ (BOOL)supportsISO7816NFCTags {
    if (self.currentUIDevice.ykf_deviceModel == YKFDeviceModelSimulator) {
        return NO;
    }
    if (@available(iOS 13, *)) {
        // This check was introduced to avoid some random crashers caused by CoreNFC on devices which are not NFC enabled.
        if ([self deviceIsNFCEnabled]) {
            return NFCTagReaderSession.readingAvailable;
        }
        return NO;
    }
    return NO;
}

+ (BOOL)supportsMFIAccessoryKey {
    if (self.currentUIDevice.ykf_deviceModel == YKFDeviceModelSimulator) {
        return NO;
    }
    if ([self supportsMFIOverUSBC]) {
        return YES;
    }
    if (@available(iOS 10, *)) {
        return [self systemSupportsMFIAccessoryKey];
    }
    return NO;
}

+ (BOOL)supportsMFIOverUSBC {
    return [self deviceIsUSBCEnabled];
}

#pragma mark - Helpers

+ (id<YKFUIDeviceProtocol>)currentUIDevice {
    return UIDevice.currentDevice;
}

+ (BOOL)deviceIsUSBCEnabled {
    static BOOL ykfDeviceCapabilitiesDeviceIsUSBCEnabled = YES;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        YKFDeviceModel deviceModel = self.currentUIDevice.ykf_deviceModel;
        ykfDeviceCapabilitiesDeviceIsUSBCEnabled =
            deviceModel == YKFDeviceModelIPadPro3 ||
            deviceModel == YKFDeviceModelIPadPro4 ||
            deviceModel == YKFDeviceModelIPadAir4 ||
            deviceModel == YKFDeviceModelIPadPro5 ||
            deviceModel == YKFDeviceModelIPadAir5 ||
            deviceModel == YKFDeviceModelIPadMini6 ||
            deviceModel == YKFDeviceModelIPad10 ||
            deviceModel == YKFDeviceModelIPadPro6 ||
            deviceModel == YKFDeviceModelIPhone15 ||
            deviceModel == YKFDeviceModelUnknown; // A newer device which is not in the list yet
    });

    return ykfDeviceCapabilitiesDeviceIsUSBCEnabled;
}

+ (BOOL)deviceIsNFCEnabled {
    static BOOL ykfDeviceCapabilitiesDeviceIsNFCEnabled = YES;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        YKFDeviceModel deviceModel = self.currentUIDevice.ykf_deviceModel;
        ykfDeviceCapabilitiesDeviceIsNFCEnabled =
            deviceModel == YKFDeviceModelIPhone7 || deviceModel == YKFDeviceModelIPhone7Plus ||
            deviceModel == YKFDeviceModelIPhone8 || deviceModel == YKFDeviceModelIPhone8Plus ||
            deviceModel == YKFDeviceModelIPhoneX ||
            deviceModel == YKFDeviceModelIPhoneXS || deviceModel == YKFDeviceModelIPhoneXSMax || deviceModel == YKFDeviceModelIPhoneXR ||
            deviceModel == YKFDeviceModelIPhone11 ||
            deviceModel == YKFDeviceModelIPhoneSE2 ||
            deviceModel == YKFDeviceModelIPhoneSE3 ||
            deviceModel == YKFDeviceModelIPhone12 ||
            deviceModel == YKFDeviceModelIPhone13 ||
            deviceModel == YKFDeviceModelIPhone14 ||
            deviceModel == YKFDeviceModelIPhone15 ||
            deviceModel == YKFDeviceModelUnknown; // A newer device which is not in the list yet
    });

    return ykfDeviceCapabilitiesDeviceIsNFCEnabled;
}

+ (BOOL)systemSupportsMFIAccessoryKey {
    static BOOL ykfDeviceCapabilitiesSystemSupportsMFIAccessoryKey = YES;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // iOS 11.2 Versions
        NSArray *excludedVersions = @[@"11.2", @"11.2.1", @"11.2.2", @"11.2.5"];
        
        NSString *systemVersion = self.currentUIDevice.systemVersion;
        if ([excludedVersions containsObject:systemVersion]) {
            ykfDeviceCapabilitiesSystemSupportsMFIAccessoryKey = NO;
        } else {
            ykfDeviceCapabilitiesSystemSupportsMFIAccessoryKey = YES;
        }
    });

    return ykfDeviceCapabilitiesSystemSupportsMFIAccessoryKey;
}

@end
