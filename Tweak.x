#import <BluetoothManager/BluetoothManager.h>
#import <dlfcn.h>

@interface BluetoothManager (Addition)
@property(assign) BOOL ignoreAirplaneModeCheck;
@end

@interface WFWiFiStateMonitor : NSObject
@end

@interface WFControlCenterStateMonitor : WFWiFiStateMonitor
@end

@interface WFControlCenterStateMonitor (Addition)
@property(assign) BOOL forceAirplaneMode;
@end

%hook BluetoothManager

%property(assign) BOOL ignoreAirplaneModeCheck;

- (void)_updateAirplaneModeStatus {
    if (self.ignoreAirplaneModeCheck)
        return;
    %orig;
}

- (void)bluetoothStateActionWithCompletion:(void *)completion {
    BOOL airplaneMode = [[self valueForKey:@"_airplaneMode"] boolValue];
    [self setValue:@(YES) forKey:@"_airplaneMode"];
    self.ignoreAirplaneModeCheck = YES;
    %orig;
    [self setValue:@(airplaneMode) forKey:@"_airplaneMode"];
    self.ignoreAirplaneModeCheck = NO;
}

%end

%hook WFControlCenterStateMonitor

%property(assign) BOOL forceAirplaneMode;

- (BOOL)_airplaneModeEnabled {
    return self.forceAirplaneMode ? YES : %orig;
}

- (void)performAction:(void *)completion {
    self.forceAirplaneMode = YES;
    %orig;
    self.forceAirplaneMode = NO;
}

%end

%ctor {
    dlopen("/System/Library/PrivateFrameworks/BluetoothManager.framework/BluetoothManager", RTLD_NOW);
    dlopen("/System/Library/PrivateFrameworks/WiFiKit.framework/WiFiKit", RTLD_NOW);
    %init;
}