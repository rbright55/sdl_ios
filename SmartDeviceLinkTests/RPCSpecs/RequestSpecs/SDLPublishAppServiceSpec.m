//
//  SDLPublishAppServiceSpec.m
//  SmartDeviceLinkTests
//
//  Created by Nicole on 2/5/19.
//  Copyright © 2019 smartdevicelink. All rights reserved.
//

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

#import "SDLAppServiceManifest.h"
#import "SDLPublishAppService.h"
#import "SDLNames.h"

QuickSpecBegin(SDLPublishAppServiceSpec)

describe(@"Getter/Setter Tests", ^ {
    __block SDLAppServiceManifest *testAppServiceManifest = nil;

    beforeEach(^{
        testAppServiceManifest = [[SDLAppServiceManifest alloc] initWithServiceName:@"serviceName" serviceType:SDLAppServiceTypeMedia serviceIcon:nil allowAppConsumers:true uriPrefix:nil rpcSpecVersion:nil handledRPCs:nil];
    });

    it(@"Should set and get correctly", ^ {
        SDLPublishAppService *testRequest = [[SDLPublishAppService alloc] init];
        testRequest.appServiceManifest = testAppServiceManifest;

        expect(testRequest.appServiceManifest).to(equal(testAppServiceManifest));
    });

    it(@"Should return nil if not set", ^{
        SDLPublishAppService *testRequest = [[SDLPublishAppService alloc] init];

        expect(testRequest.appServiceManifest).to(beNil());
    });

    describe(@"initializing", ^{
        it(@"Should initialize correctly with a dictionary", ^{
            NSDictionary *dict = @{SDLNameRequest:@{
                                           SDLNameParameters:@{
                                                   SDLNameAppServiceManifest:testAppServiceManifest
                                                   },
                                           SDLNameOperationName:SDLNamePublishAppService}};
            SDLPublishAppService *testRequest = [[SDLPublishAppService alloc] initWithDictionary:dict];

            expect(testRequest.appServiceManifest).to(equal(testAppServiceManifest));
        });

        it(@"Should initialize correctly with initWithAppServiceManifest:", ^{
            SDLPublishAppService *testRequest = [[SDLPublishAppService alloc] initWithAppServiceManifest:testAppServiceManifest];

            expect(testRequest.appServiceManifest).to(equal(testAppServiceManifest));
        });
    });
});

QuickSpecEnd
