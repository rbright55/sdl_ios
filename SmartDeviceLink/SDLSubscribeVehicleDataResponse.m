//  SDLSubscribeVehicleDataResponse.m
//


#import "SDLSubscribeVehicleDataResponse.h"

#import "NSMutableDictionary+Store.h"
#import "SDLRPCParameterNames.h"
#import "SDLRPCFunctionNames.h"
#import "SDLVehicleDataResult.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SDLSubscribeVehicleDataResponse

- (instancetype)init {
    if (self = [super initWithName:SDLRPCFunctionNameSubscribeVehicleData]) {
    }
    return self;
}

- (void)setGps:(nullable SDLVehicleDataResult *)gps {
    [parameters sdl_setObject:gps forName:SDLRPCParameterNameGPS];
}

- (nullable SDLVehicleDataResult *)gps {
    return [parameters sdl_objectForName:SDLRPCParameterNameGPS ofClass:SDLVehicleDataResult.class];
}

- (void)setSpeed:(nullable SDLVehicleDataResult *)speed {
    [parameters sdl_setObject:speed forName:SDLRPCParameterNameSpeed];
}

- (nullable SDLVehicleDataResult *)speed {
    return [parameters sdl_objectForName:SDLRPCParameterNameSpeed ofClass:SDLVehicleDataResult.class];
}

- (void)setRpm:(nullable SDLVehicleDataResult *)rpm {
    [parameters sdl_setObject:rpm forName:SDLRPCParameterNameRPM];
}

- (nullable SDLVehicleDataResult *)rpm {
    return [parameters sdl_objectForName:SDLRPCParameterNameRPM ofClass:SDLVehicleDataResult.class];
}

- (void)setFuelLevel:(nullable SDLVehicleDataResult *)fuelLevel {
    [parameters sdl_setObject:fuelLevel forName:SDLRPCParameterNameFuelLevel];
}

- (nullable SDLVehicleDataResult *)fuelLevel {
    return [parameters sdl_objectForName:SDLRPCParameterNameFuelLevel ofClass:SDLVehicleDataResult.class];
}

- (void)setFuelLevel_State:(nullable SDLVehicleDataResult *)fuelLevel_State {
    [parameters sdl_setObject:fuelLevel_State forName:SDLRPCParameterNameFuelLevelState];
}

- (nullable SDLVehicleDataResult *)fuelLevel_State {
    return [parameters sdl_objectForName:SDLRPCParameterNameFuelLevelState ofClass:SDLVehicleDataResult.class];
}

- (void)setFuelRange:(nullable SDLVehicleDataResult *)fuelRange {
    [parameters sdl_setObject:fuelRange forName:SDLRPCParameterNameFuelRange];
}

- (nullable SDLVehicleDataResult *)fuelRange {
    return [parameters sdl_objectForName:SDLRPCParameterNameFuelRange ofClass:SDLVehicleDataResult.class];
}

- (void)setInstantFuelConsumption:(nullable SDLVehicleDataResult *)instantFuelConsumption {
    [parameters sdl_setObject:instantFuelConsumption forName:SDLRPCParameterNameInstantFuelConsumption];
}

- (nullable SDLVehicleDataResult *)instantFuelConsumption {
    return [parameters sdl_objectForName:SDLRPCParameterNameInstantFuelConsumption ofClass:SDLVehicleDataResult.class];
}

- (void)setExternalTemperature:(nullable SDLVehicleDataResult *)externalTemperature {
    [parameters sdl_setObject:externalTemperature forName:SDLRPCParameterNameExternalTemperature];
}

- (nullable SDLVehicleDataResult *)externalTemperature {
    return [parameters sdl_objectForName:SDLRPCParameterNameExternalTemperature ofClass:SDLVehicleDataResult.class];
}

- (void)setPrndl:(nullable SDLVehicleDataResult *)prndl {
    [parameters sdl_setObject:prndl forName:SDLRPCParameterNamePRNDL];
}

- (nullable SDLVehicleDataResult *)prndl {
    return [parameters sdl_objectForName:SDLRPCParameterNamePRNDL ofClass:SDLVehicleDataResult.class];
}

- (void)setTirePressure:(nullable SDLVehicleDataResult *)tirePressure {
    [parameters sdl_setObject:tirePressure forName:SDLRPCParameterNameTirePressure];
}

- (nullable SDLVehicleDataResult *)tirePressure {
    return [parameters sdl_objectForName:SDLRPCParameterNameTirePressure ofClass:SDLVehicleDataResult.class];
}

- (void)setOdometer:(nullable SDLVehicleDataResult *)odometer {
    [parameters sdl_setObject:odometer forName:SDLRPCParameterNameOdometer];
}

- (nullable SDLVehicleDataResult *)odometer {
    return [parameters sdl_objectForName:SDLRPCParameterNameOdometer ofClass:SDLVehicleDataResult.class];
}

- (void)setBeltStatus:(nullable SDLVehicleDataResult *)beltStatus {
    [parameters sdl_setObject:beltStatus forName:SDLRPCParameterNameBeltStatus];
}

- (nullable SDLVehicleDataResult *)beltStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameBeltStatus ofClass:SDLVehicleDataResult.class];
}

- (void)setBodyInformation:(nullable SDLVehicleDataResult *)bodyInformation {
    [parameters sdl_setObject:bodyInformation forName:SDLRPCParameterNameBodyInformation];
}

- (nullable SDLVehicleDataResult *)bodyInformation {
    return [parameters sdl_objectForName:SDLRPCParameterNameBodyInformation ofClass:SDLVehicleDataResult.class];
}

- (void)setDeviceStatus:(nullable SDLVehicleDataResult *)deviceStatus {
    [parameters sdl_setObject:deviceStatus forName:SDLRPCParameterNameDeviceStatus];
}

- (nullable SDLVehicleDataResult *)deviceStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameDeviceStatus ofClass:SDLVehicleDataResult.class];
}

- (void)setDriverBraking:(nullable SDLVehicleDataResult *)driverBraking {
    [parameters sdl_setObject:driverBraking forName:SDLRPCParameterNameDriverBraking];
}

- (nullable SDLVehicleDataResult *)driverBraking {
    return [parameters sdl_objectForName:SDLRPCParameterNameDriverBraking ofClass:SDLVehicleDataResult.class];
}

- (void)setWiperStatus:(nullable SDLVehicleDataResult *)wiperStatus {
    [parameters sdl_setObject:wiperStatus forName:SDLRPCParameterNameWiperStatus];
}

- (nullable SDLVehicleDataResult *)wiperStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameWiperStatus ofClass:SDLVehicleDataResult.class];
}

- (void)setHeadLampStatus:(nullable SDLVehicleDataResult *)headLampStatus {
    [parameters sdl_setObject:headLampStatus forName:SDLRPCParameterNameHeadLampStatus];
}

- (nullable SDLVehicleDataResult *)headLampStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameHeadLampStatus ofClass:SDLVehicleDataResult.class];
}

- (void)setEngineOilLife:(nullable NSNumber<SDLBool> *)engineOilLife {
    [parameters sdl_setObject:engineOilLife forName:SDLRPCParameterNameEngineOilLife];
}

- (nullable NSNumber<SDLBool> *)engineOilLife {
    return [parameters sdl_objectForName:SDLRPCParameterNameEngineOilLife];
}

- (void)setEngineTorque:(nullable SDLVehicleDataResult *)engineTorque {
    [parameters sdl_setObject:engineTorque forName:SDLRPCParameterNameEngineTorque];
}

- (nullable SDLVehicleDataResult *)engineTorque {
    return [parameters sdl_objectForName:SDLRPCParameterNameEngineTorque ofClass:SDLVehicleDataResult.class];
}

- (void)setAccPedalPosition:(nullable SDLVehicleDataResult *)accPedalPosition {
    [parameters sdl_setObject:accPedalPosition forName:SDLRPCParameterNameAccelerationPedalPosition];
}

- (nullable SDLVehicleDataResult *)accPedalPosition {
    return [parameters sdl_objectForName:SDLRPCParameterNameAccelerationPedalPosition ofClass:SDLVehicleDataResult.class];
}

- (void)setSteeringWheelAngle:(nullable SDLVehicleDataResult *)steeringWheelAngle {
    [parameters sdl_setObject:steeringWheelAngle forName:SDLRPCParameterNameSteeringWheelAngle];
}

- (nullable SDLVehicleDataResult *)steeringWheelAngle {
    return [parameters sdl_objectForName:SDLRPCParameterNameSteeringWheelAngle ofClass:SDLVehicleDataResult.class];
}

- (void)setECallInfo:(nullable SDLVehicleDataResult *)eCallInfo {
    [parameters sdl_setObject:eCallInfo forName:SDLRPCParameterNameECallInfo];
}

- (nullable SDLVehicleDataResult *)eCallInfo {
    return [parameters sdl_objectForName:SDLRPCParameterNameECallInfo ofClass:SDLVehicleDataResult.class];
}

- (void)setAirbagStatus:(nullable SDLVehicleDataResult *)airbagStatus {
    [parameters sdl_setObject:airbagStatus forName:SDLRPCParameterNameAirbagStatus];
}

- (nullable SDLVehicleDataResult *)airbagStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameAirbagStatus ofClass:SDLVehicleDataResult.class];
}

- (void)setEmergencyEvent:(nullable SDLVehicleDataResult *)emergencyEvent {
    [parameters sdl_setObject:emergencyEvent forName:SDLRPCParameterNameEmergencyEvent];
}

- (nullable SDLVehicleDataResult *)emergencyEvent {
    return [parameters sdl_objectForName:SDLRPCParameterNameEmergencyEvent ofClass:SDLVehicleDataResult.class];
}

- (void)setClusterModes:(nullable SDLVehicleDataResult *)clusterModes {
    [parameters sdl_setObject:clusterModes forName:SDLRPCParameterNameClusterModes];
}

- (nullable SDLVehicleDataResult *)clusterModes {
    return [parameters sdl_objectForName:SDLRPCParameterNameClusterModes ofClass:SDLVehicleDataResult.class];
}

- (void)setMyKey:(nullable SDLVehicleDataResult *)myKey {
    [parameters sdl_setObject:myKey forName:SDLRPCParameterNameMyKey];
}

- (nullable SDLVehicleDataResult *)myKey {
    return [parameters sdl_objectForName:SDLRPCParameterNameMyKey ofClass:SDLVehicleDataResult.class];
}

- (void)setElectronicParkBrakeStatus:(nullable SDLVehicleDataResult *)electronicParkBrakeStatus {
    [parameters sdl_setObject:electronicParkBrakeStatus forName:SDLRPCParameterNameElectronicParkBrakeStatus];
}

- (nullable SDLVehicleDataResult *)electronicParkBrakeStatus {
    return [parameters sdl_objectForName:SDLRPCParameterNameElectronicParkBrakeStatus ofClass:[SDLVehicleDataResult class]];
}

- (void)setTurnSignal:(nullable SDLVehicleDataResult *)turnSignal {
    [parameters sdl_setObject:turnSignal forName:SDLRPCParameterNameTurnSignal];
}

- (nullable SDLVehicleDataResult *)turnSignal {
    return [parameters sdl_objectForName:SDLRPCParameterNameTurnSignal ofClass:[SDLVehicleDataResult class]];
}

- (void)setCloudAppVehicleID:(nullable SDLVehicleDataResult *)cloudAppVehicleID {
    [parameters sdl_setObject:cloudAppVehicleID forName:SDLRPCParameterNameCloudAppVehicleID];
}

- (nullable SDLVehicleDataResult *)cloudAppVehicleID {
    return [parameters sdl_objectForName:SDLRPCParameterNameCloudAppVehicleID ofClass:SDLVehicleDataResult.class];
}

@end

NS_ASSUME_NONNULL_END
