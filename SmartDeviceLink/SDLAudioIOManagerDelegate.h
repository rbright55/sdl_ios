//
//  SDLAudioIOManager.h
//  Created by Kujtim Shala on 05/25/18.
//

#import <Foundation/Foundation.h>
#import <SmartDeviceLink/SDLResult.h>

@class SDLAudioIOManager;
@class SDLAudioPassThruCapabilities;

NS_ASSUME_NONNULL_BEGIN

@protocol SDLAudioIOManagerDelegate <NSObject>

@optional

// output stream related
- (void)audioManagerDidStartOutputStream:(SDLAudioIOManager *)audioManager;
- (void)audioManagerDidStopOutputStream:(SDLAudioIOManager *)audioManager;
- (void)audioManager:(SDLAudioIOManager *)audioManager didFinishPlayingURL:(NSURL *)url;
- (void)audioManager:(SDLAudioIOManager *)audioManager errorDidOccurForURL:(NSURL *)url error:(NSError *)error;

// input stream related
- (void)audioManager:(SDLAudioIOManager *)audioManager didStartInputStreamWithOptions:(SDLAudioPassThruCapabilities *)options;
- (void)audioManager:(SDLAudioIOManager *)audioManager didReceiveAudioData:(NSData *)audioData;
- (void)audioManager:(SDLAudioIOManager *)audioManager didFinishInputStreamWithResult:(SDLResult)result;

@end

NS_ASSUME_NONNULL_END
