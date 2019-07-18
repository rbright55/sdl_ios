//
//  SDLLockScreenManager.m
//  SmartDeviceLink-iOS
//
//  Created by Joel Fischer on 7/8/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

#import "SDLLockScreenManager.h"

#import "NSBundle+SDLBundle.h"
#import "SDLLogMacros.h"
#import "SDLLockScreenConfiguration.h"
#import "SDLLockScreenStatus.h"
#import "SDLLockScreenViewController.h"
#import "SDLNotificationConstants.h"
#import "SDLOnDriverDistraction.h"
#import "SDLRPCNotificationNotification.h"
#import "SDLScreenshotViewController.h"
#import "SDLViewControllerPresentable.h"
#import "SDLOnHMIStatus.h"
#import "SDLHMILevel.h"


NS_ASSUME_NONNULL_BEGIN

@interface SDLLockScreenManager ()

@property (assign, nonatomic) BOOL canPresent;
@property (strong, nonatomic, readwrite) SDLLockScreenConfiguration *config;
@property (strong, nonatomic) id<SDLViewControllerPresentable> presenter;
@property (copy, nonatomic, nullable) SDLHMILevel hmiLevel;
@property (assign, nonatomic) BOOL userSelected;
@property (assign, nonatomic) BOOL driverDistracted;
@property (assign, nonatomic) BOOL haveDriverDistractionStatus;
@property (strong, nonatomic, nullable) SDLOnDriverDistraction *lastDriverDistractionNotification;
@property (assign, nonatomic, readwrite, getter=isLockScreenDismissable) BOOL lockScreenDismissable;

@end


@implementation SDLLockScreenManager

- (instancetype)initWithConfiguration:(SDLLockScreenConfiguration *)config notificationDispatcher:(nullable id)dispatcher presenter:(id<SDLViewControllerPresentable>)presenter {
    self = [super init];
    if (!self) {
        return nil;
    }

    _canPresent = NO;
    _hmiLevel = nil;
    _userSelected = NO;
    _driverDistracted = NO;
    _haveDriverDistractionStatus = NO;
    _lockScreenDismissable = NO;
    _config = config;
    _presenter = presenter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_hmiLevelDidChange:) name:SDLDidChangeHMIStatusNotification object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_lockScreenIconReceived:) name:SDLDidReceiveLockScreenIcon object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_driverDistractionStateDidChange:) name:SDLDidChangeDriverDistractionStateNotification object:dispatcher];

    return self;
}

- (void)start {
    self.canPresent = NO;

    // Create and initialize the lock screen controller depending on the configuration
    if (!self.config.enableAutomaticLockScreen) {
        self.presenter.lockViewController = nil;
        return;
    } else if (self.config.customViewController != nil) {
        self.presenter.lockViewController = self.config.customViewController;
    } else {
        SDLLockScreenViewController *viewController = nil;

        @try {
            viewController = [[UIStoryboard storyboardWithName:@"SDLLockScreen" bundle:[NSBundle sdlBundle]] instantiateInitialViewController];
        } @catch (NSException *exception) {
            SDLLogE(@"Attempted to instantiate the default SDL Lock Screen and could not find the storyboard. Be sure the 'SmartDeviceLink' bundle is within your main bundle. We're just going to return without instantiating the lock screen");
            return;
        }

        viewController.appIcon = self.config.appIcon;
        viewController.backgroundColor = self.config.backgroundColor;
        self.presenter.lockViewController = viewController;
    }

    self.canPresent = YES;
}

- (void)stop {
    self.canPresent = NO;

    // Remove the lock screen if presented, don't allow it to present again until we start
    if (self.presenter.lockViewController != nil) {
        [self.presenter dismiss];
    }
}

- (nullable UIViewController *)lockScreenViewController {
    return self.presenter.lockViewController;
}

#pragma mark - Notification Selectors

- (void)sdl_hmiLevelDidChange:(SDLRPCNotificationNotification *)notification {
    if (![notification isNotificationMemberOfClass:[SDLOnHMIStatus class]]) {
        return;
    }
    
    SDLOnHMIStatus *hmiStatus = notification.notification;
    
    self.hmiLevel = hmiStatus.hmiLevel;
    if ([self.hmiLevel isEqualToEnum:SDLHMILevelFull] || [self.hmiLevel isEqualToEnum:SDLHMILevelLimited]) {
        self.userSelected = YES;
    } else if ([self.hmiLevel isEqualToEnum:SDLHMILevelNone]) {
        self.userSelected = NO;
    }
}

- (void)sdl_lockScreenIconReceived:(NSNotification *)notification {
    NSAssert([notification.userInfo[SDLNotificationUserInfoObject] isKindOfClass:[UIImage class]], @"A notification was sent with an unanticipated object");
    if (![notification.userInfo[SDLNotificationUserInfoObject] isKindOfClass:[UIImage class]]) {
        return;
    }

    UIImage *icon = notification.userInfo[SDLNotificationUserInfoObject];

    // If the VC is our special type, then add the vehicle icon. If they passed in a custom VC, there's no current way to show the vehicle icon. If they're managing it themselves, they can grab the notification themselves.
    if ([self.lockScreenViewController isKindOfClass:[SDLLockScreenViewController class]]) {
        ((SDLLockScreenViewController *)self.lockScreenViewController).vehicleIcon = icon;
    }
}

- (void)sdl_appDidBecomeActive:(NSNotification *)notification {
    [self sdl_checkLockScreen];
}

- (void)sdl_driverDistractionStateDidChange:(SDLRPCNotificationNotification *)notification {
    if (![notification isNotificationMemberOfClass:[SDLOnDriverDistraction class]]) {
        return;
    }

    self.lastDriverDistractionNotification = notification.notification;
    self.haveDriverDistractionStatus = YES;
    self.driverDistracted = [self.lastDriverDistractionNotification.state isEqualToEnum:SDLDriverDistractionStateOn] ? YES : NO;
    [self sdl_checkLockScreen];
    [self sdl_updateLockScreenDismissable];
}

#pragma mark - Private Helpers

- (void)sdl_checkLockScreen {
    if (self.lockScreenViewController == nil) {
        return;
    }

    // Present the VC depending on the lock screen status
    BOOL lockScreenDismissableEnabled = [self.lastDriverDistractionNotification.lockScreenDismissalEnabled boolValue];
    if ([self.lockScreenStatus isEqualToEnum:SDLLockScreenStatusRequired]) {
        if (!self.presenter.presented && self.canPresent && !lockScreenDismissableEnabled) {
            [self.presenter present];
        }
    } else if ([self.lockScreenStatus isEqualToEnum:SDLLockScreenStatusOptional]) {
        if (self.config.showInOptionalState && !self.presenter.presented && self.canPresent && !lockScreenDismissableEnabled) {
            [self.presenter present];
        } else if (!self.config.showInOptionalState && self.presenter.presented) {
            [self.presenter dismiss];
        }
    } else if ([self.lockScreenStatus isEqualToEnum:SDLLockScreenStatusOff]) {
        if (self.presenter.presented) {
            [self.presenter dismiss];
        }
    }
}

- (void)sdl_updateLockScreenDismissable {
    BOOL lastLockScreenDismissableEnabled = [self.lastDriverDistractionNotification.lockScreenDismissalEnabled boolValue];
    if (self.lastDriverDistractionNotification == nil || self.lastDriverDistractionNotification.lockScreenDismissalEnabled == nil ||
        ![self.lastDriverDistractionNotification.lockScreenDismissalEnabled boolValue]) {
        self.lockScreenDismissable = NO;
    } else {
        self.lockScreenDismissable = YES;
    }
    
    if (lastLockScreenDismissableEnabled != self.lockScreenDismissable) {
        [self sdl_updateLockscreenViewControllerWithDismissableState:self.lockScreenDismissable];
    }
}

- (void)sdl_updateLockscreenViewControllerWithDismissableState:(BOOL)enabled {
    if (![self.lockScreenViewController isKindOfClass:[SDLLockScreenViewController class]]) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakself;
        SDLLockScreenViewController *lockscreenViewController = (SDLLockScreenViewController *)strongSelf.lockScreenViewController;
        if (enabled) {
            [lockscreenViewController addDismissGestureWithCallback:^{
                [strongSelf.presenter dismiss];
            }];
            lockscreenViewController.lockedLabelText = strongSelf.lastDriverDistractionNotification.lockScreenDismissalWarning;
        } else {
            [(SDLLockScreenViewController *)strongSelf.lockScreenViewController removeDismissGesture];
            lockscreenViewController.lockedLabelText = nil;
        }
    });
}

- (SDLLockScreenStatus)lockScreenStatus {
    if (self.hmiLevel == nil || [self.hmiLevel isEqualToEnum:SDLHMILevelNone]) {
        // App is not active on the car
        return SDLLockScreenStatusOff;
    } else if ([self.hmiLevel isEqualToEnum:SDLHMILevelBackground]) {
        // App is in the background on the car
        if (self.userSelected) {
            // It was user selected
            if (self.haveDriverDistractionStatus && !self.driverDistracted) {
                // We have the distraction status, and the driver is not distracted
                return SDLLockScreenStatusOptional;
            } else {
                // We don't have the distraction status, and/or the driver is distracted
                return SDLLockScreenStatusRequired;
            }
        } else {
            return SDLLockScreenStatusOff;
        }
    } else if ([self.hmiLevel isEqualToEnum:SDLHMILevelFull] || [self.hmiLevel isEqualToEnum:SDLHMILevelLimited]) {
        // App is in the foreground on the car in some manner
        if (self.haveDriverDistractionStatus && !self.driverDistracted) {
            // We have the distraction status, and the driver is not distracted
            return SDLLockScreenStatusOptional;
        } else {
            // We don't have the distraction status, and/or the driver is distracted
            return SDLLockScreenStatusRequired;
        }
    } else {
        // This shouldn't be possible.
        return SDLLockScreenStatusOff;
    }
}

@end

NS_ASSUME_NONNULL_END
