//
//  SDLWazeAudioManager.h
//  Created by Kujtim Shala on 05/25/18.
//

#import <Foundation/Foundation.h>
#import "SDLWazeAudioManagerDelegate.h"

@class SDLManager;
@class SDLTTSChunk;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SDLErrorDomainWazeAudioManager;

@interface SDLWazeAudioManager : NSObject

@property (weak, nonatomic) SDLManager *sdlManager;
@property (weak, nonatomic) id<SDLWazeAudioManagerDelegate> delegate;

@property (assign, nonatomic, readonly) BOOL isOutputStreamPlaying;
@property (assign, nonatomic, readonly) BOOL isInputStreamPlaying;

@property (strong, nonatomic, readwrite) SDLTTSChunk *inputStreamPrompt;
@property (strong, nonatomic, readwrite) NSString *inputStreamText;

- (instancetype)initWithManager:(nonnull SDLManager *)sdlManager delegate:(id<SDLWazeAudioManagerDelegate>)delegate;

- (void)writeOutputStreamWithFileURL:(NSURL *)fileURL;

- (void)startInputStream;
- (void)stopInputStream;

@end

NS_ASSUME_NONNULL_END
