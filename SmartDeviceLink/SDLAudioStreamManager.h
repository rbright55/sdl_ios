//
//  SDLBinaryAudioManager.h
//  SmartDeviceLink-Example
//
//  Created by Joel Fischer on 10/24/17.
//  Copyright © 2017 smartdevicelink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDLAudioFile;
@class SDLManager;
@class SDLStreamingMediaLifecycleManager;
@protocol SDLStreamingAudioManagerType;
@protocol SDLAudioStreamManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SDLErrorDomainAudioStreamManager;

typedef NS_ENUM(NSInteger, SDLAudioStreamManagerError) {
    SDLAudioStreamManagerErrorNotConnected = -1,
    SDLAudioStreamManagerErrorNoQueuedAudio = -2
};

@interface SDLAudioStreamManager : NSObject

/**
 The delegate describing when files are done playing or any errors that occur
 */
@property (weak, nonatomic) id<SDLAudioStreamManagerDelegate> delegate;

@property (strong, nonatomic, readonly) NSOperationQueue *queue;
@property (strong, nonatomic, nonnull, readonly) NSDate *audioPlaybackEnd;
/**
 Init should only occur with dependencies. use `initWithManager:`

 @return A failure
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Create an audio stream manager with a reference to the parent stream manager.

 @warning For internal use

 @param streamManager The parent stream manager
 @return The audio stream manager
 */
- (instancetype)initWithManager:(id<SDLStreamingAudioManagerType>)streamManager NS_DESIGNATED_INITIALIZER;

/**
 Push a new file URL onto the queue after converting it into the correct PCM format for streaming binary data. Call `playNextWhenReady` to start playing the next completed pushed file.

 @note This happens on a serial background thread and will provide an error callback using the delegate if the conversion fails.

 @param fileURL File URL to convert
 */
- (void)pushWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
