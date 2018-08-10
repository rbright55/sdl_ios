//
//  SDLWazeAudioManager.h
//  Created by Kujtim Shala on 05/25/18.
//

#import <Foundation/Foundation.h>
#import <SmartDeviceLink/SDLResult.h>

@class SDLWazeAudioManager;
@class SDLAudioPassThruCapabilities;

NS_ASSUME_NONNULL_BEGIN

@protocol SDLWazeAudioManagerDelegate <NSObject>

@optional

// output stream related
- (void)audioManagerDidStartOutputStream:(SDLWazeAudioManager *)audioManager;
- (void)audioManagerDidStopOutputStream:(SDLWazeAudioManager *)audioManager;
- (void)audioManager:(SDLWazeAudioManager *)audioManager didFinishPlayingURL:(NSURL *)url;
- (void)audioManager:(SDLWazeAudioManager *)audioManager errorDidOccurForURL:(NSURL *)url error:(NSError *)error;

// input stream related
- (void)audioManager:(SDLWazeAudioManager *)audioManager didStartInputStreamWithOptions:(SDLAudioPassThruCapabilities *)options;
- (void)audioManager:(SDLWazeAudioManager *)audioManager didReceiveAudioData:(NSData *)audioData;
- (void)audioManager:(SDLWazeAudioManager *)audioManager didFinishInputStreamWithResult:(SDLResult)result;

@end

NS_ASSUME_NONNULL_END
