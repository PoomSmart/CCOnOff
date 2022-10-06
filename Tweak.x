#import <version.h>
#import <BluetoothManager/BluetoothManager.h>
#import <dlfcn.h>

@interface BluetoothManager (Addition)
@property (assign) BOOL ignoreAirplaneModeCheck;
@end

@interface WFWiFiStateMonitor : NSObject
@end

@interface WFControlCenterStateMonitor : WFWiFiStateMonitor
@end

@interface WFControlCenterStateMonitor (Addition)
@property (assign) BOOL forceAirplaneMode;
@end

%group iOS15

%hook BluetoothManager

- (void)bluetoothStateActionWithCompletion:(id)completion {
    BOOL shouldTurnOff = [[self valueForKey:@"_state"] intValue] == 3;
    if (shouldTurnOff) [self setValue:@(99) forKey:@"_state"];
    %orig;
    if (shouldTurnOff) {
        [self setValue:@(1) forKey:@"_state"];
        [self setPowered:NO];
        [self postNotification:@"BluetoothStateChangedNotification"];
    }
}

%end

%end

%group preiOS15

%hook BluetoothManager

%property (assign) BOOL ignoreAirplaneModeCheck;

- (void)_updateAirplaneModeStatus {
    if (self.ignoreAirplaneModeCheck)
        return;
    %orig;
}

- (void)bluetoothStateActionWithCompletion:(id)completion {
    BOOL airplaneMode = [[self valueForKey:@"_airplaneMode"] boolValue];
    [self setValue:@(YES) forKey:@"_airplaneMode"];
    self.ignoreAirplaneModeCheck = YES;
    %orig;
    [self setValue:@(airplaneMode) forKey:@"_airplaneMode"];
    self.ignoreAirplaneModeCheck = NO;
}

%end

%end

%hook WFControlCenterStateMonitor

%property (assign) BOOL forceAirplaneMode;

- (BOOL)_airplaneModeEnabled {
    return self.forceAirplaneMode ? YES : %orig;
}

- (void)performAction:(id)completion {
    self.forceAirplaneMode = YES;
    %orig;
    self.forceAirplaneMode = NO;
}

%end

%ctor {
    dlopen("/System/Library/PrivateFrameworks/BluetoothManager.framework/BluetoothManager", RTLD_NOW);
    dlopen("/System/Library/PrivateFrameworks/WiFiKit.framework/WiFiKit", RTLD_NOW);
    if (IS_IOS_OR_NEWER(iOS_15_0)) {
        %init(iOS15);
    } else {
        %init(preiOS15);
    }
    %init;
}