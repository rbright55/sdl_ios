//
//  SDLSoftButtonObject.m
//  SmartDeviceLink
//
//  Created by Joel Fischer on 2/22/18.
//  Copyright © 2018 smartdevicelink. All rights reserved.
//

#import "SDLSoftButtonObject.h"

#import "SDLError.h"
#import "SDLSoftButtonState.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDLSoftButtonObject()

@property (strong, nonatomic) NSString *currentStateName;

@end

@implementation SDLSoftButtonObject

- (instancetype)initWithName:(NSString *)name states:(NSArray<SDLSoftButtonState *> *)states initialStateName:(NSString *)initialStateName handler:(SDLRPCButtonNotificationHandler)eventHandler {
    self = [super init];
    if (!self) { return nil; }

    // Make sure there aren't two states with the same name
    if ([self sdl_hasTwoStatesOfSameName:states]) {
        return nil;
    }

    _name = name;
    _states = states;
    _currentStateName = initialStateName;
    _eventHandler = eventHandler;

    return self;
}

- (instancetype)initWithName:(NSString *)name state:(SDLSoftButtonState *)state handler:(SDLRPCButtonNotificationHandler)eventHandler {
    return [self initWithName:name states:@[state] initialStateName:state.name handler:eventHandler];
}

- (BOOL)transitionToState:(NSString *)stateName {
    if ([self stateWithName:stateName] == nil) {
        return NO;
    }

    self.currentStateName = stateName;

    return YES;
}

- (SDLSoftButtonState *)currentState {
    SDLSoftButtonState *state = [self stateWithName:self.currentStateName];

    if (state == nil) {
        @throw [NSException sdl_invalidSoftButtonStateException];
    } else {
        return state;
    }
}

- (nullable SDLSoftButtonState *)stateWithName:(NSString *)stateName {
    for (SDLSoftButtonState *state in self.states) {
        if ([state.name isEqualToString:stateName]) {
            return state;
        }
    }

    return nil;
}

- (BOOL)sdl_hasTwoStatesOfSameName:(NSArray<SDLSoftButtonState *> *)states {
    for (NSUInteger i = 0; i < states.count; i++) {
        NSString *stateName = states[i].name;
        for (NSUInteger j = 0; j < states.count; j++) {
            if ([states[j].name isEqualToString:stateName]) {
                return YES;
            }
        }
    }

    return NO;
}

@end

NS_ASSUME_NONNULL_END
