//
//  SDLBinaryAudioManager.m
//  SmartDeviceLink-Example
//
//  Created by Joel Fischer on 10/24/17.
//  Copyright © 2017 smartdevicelink. All rights reserved.
//

#import "SDLAudioStreamManager.h"

#import "SDLAudioFile.h"
#import "SDLFile.h"
#import "SDLLogMacros.h"
#import "SDLManager.h"
#import "SDLPCMAudioConverter.h"
#import "SDLAudioStreamManagerDelegate.h"
#import "SDLStreamingAudioManagerType.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const SDLErrorDomainAudioStreamManager = @"com.sdl.extension.pcmAudioStreamManager";

@interface SDLAudioStreamManager ()

@property (weak, nonatomic) id<SDLStreamingAudioManagerType> streamManager;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic, nonnull) NSDate *audioPlaybackEnd;

@end

@implementation SDLAudioStreamManager

- (instancetype)initWithManager:(id<SDLStreamingAudioManagerType>)streamManager {
    self = [super init];
    if (!self) { return nil; }
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.queue.suspended = YES;
    
    _streamManager = streamManager;

    _audioPlaybackEnd = [NSDate dateWithTimeIntervalSince1970:0];
    
    return self;
}

- (void)pushWithFileURL:(NSURL *)fileURL {
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        if (!weakOperation || weakOperation.isCancelled) return;
        
        [self sdl_pushWithFileURL:fileURL];
    }];

    [self.queue addOperation:operation];
}

- (void)sdl_pushWithFileURL:(NSURL *)fileURL {
    if (!self.streamManager.isAudioConnected) {
        if (self.delegate != nil) {
            NSError *error = [NSError errorWithDomain:SDLErrorDomainAudioStreamManager code:SDLAudioStreamManagerErrorNotConnected userInfo:nil];
            [self.delegate audioStreamManager:self errorDidOccurForFile:fileURL error:error];
        }
        return;
    }
    
    // Convert and store in the queue
    NSError *error = nil;
    SDLPCMAudioConverter *converter = [[SDLPCMAudioConverter alloc] initWithFileURL:fileURL];
    NSURL *_Nullable outputFileURL = [converter convertFileWithError:&error];
    UInt32 estimatedDuration = converter.estimatedDuration;

    if (outputFileURL == nil) {
        SDLLogE(@"Error converting file to CAF / PCM: %@", error);
        if (self.delegate != nil) {
            [self.delegate audioStreamManager:self errorDidOccurForFile:fileURL error:error];
        }
        return;
    }

    SDLAudioFile *audioFile = [[SDLAudioFile alloc] initWithInputFileURL:fileURL outputFileURL:outputFileURL estimatedDuration:estimatedDuration];
    [self sdl_playAudioFile:audioFile];
}

- (void)sdl_playAudioFile:(SDLAudioFile *)audioFile {
    // Strip the first bunch of bytes (because of how Apple outputs the data) and send to the audio stream, if we don't do this, it will make a weird click sound
    NSData *data = audioFile.data;
    NSData *audioData = [data subdataWithRange:NSMakeRange(5760, (data.length - 5760))];
    
    SDLLogD(@"Playing audio file: %@", audioFile);
    BOOL success = [self.streamManager sendAudioData:audioData];
    NSTimeInterval audioLengthSecs = (double)audioData.length / 32000.0;
    
    // delete the output data. not needed anymore
    [[NSFileManager defaultManager] removeItemAtURL:audioFile.outputFileURL error:nil];
    
    // date1 is now + playback time (only correct if no playback is active)
    NSDate *date1 = [NSDate dateWithTimeIntervalSinceNow:audioLengthSecs];
    // date2 is last known playback endtime + playback time (only true if playback is currently active)
    NSDate *date2 = [self.audioPlaybackEnd dateByAddingTimeInterval:audioLengthSecs];
    
    // date1 > date2 if playback is not active
    if ([date1 compare:date2] == NSOrderedDescending) {
        SDLLogD(@"Adding first audio file to audio buffer");
        // WORKARONUD: the first playback file finish notification should be a second ahead so the audio buffer doesn't run empty
        self.audioPlaybackEnd = [date1 dateByAddingTimeInterval:-1.0];
    } else {
        SDLLogD(@"Adding subsequent audio file to audio buffer");
        self.audioPlaybackEnd = date2;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.audioPlaybackEnd.timeIntervalSinceNow * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SDLLogD(@"Ending Audio file: %@", audioFile);
        if (self.delegate != nil) {
            [self.delegate audioStreamManager:self fileDidFinishPlaying:audioFile.inputFileURL successfully:success];
        }
    });
}

@end

NS_ASSUME_NONNULL_END
