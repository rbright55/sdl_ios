//
//  SDLAudioIOManager.h
//  Created by Kujtim Shala on 05/25/18.
//

#import "SDLAudioIOManager.h"

#import <SmartDeviceLink/SmartDeviceLink.h>
#import "SDLAudioIOManagerDelegate.h"

/** Amplifier const settings */
#define INPUT_STREAM_AMPLIFIER_FACTOR_MAX (50.0)
#define INPUT_STREAM_AMPLIFIER_INCREASE_STEP (2.5)

NS_ASSUME_NONNULL_BEGIN

NSString *const SDLErrorDomainAudioIOManager = @"com.sdl.extension.AudioIOManager";

typedef NS_ENUM(NSInteger, SDLAudioIOManagerError) {
    SDLAudioIOManagerErrorNotConnected = -1
};

typedef NS_ENUM(NSInteger, SDLAudioIOManagerState) {
    SDLAudioIOManagerStateStopped = 0,
    SDLAudioIOManagerStateStarting = 1,
    SDLAudioIOManagerStateStarted = 2,
    SDLAudioIOManagerStateStopping = 3,
    SDLAudioIOManagerStatePausing = 4, // only for inputstream. it'll be paused when active and output stream starts
    SDLAudioIOManagerStatePaused = 5, // only for inputstream while output stream is playing
};

@interface SDLAudioIOManager () <SDLAudioStreamManagerDelegate>

@property (assign, nonatomic) SDLAudioIOManagerState outputStreamState;
@property (assign, nonatomic) SDLAudioIOManagerState inputStreamState;

@property (strong, nonatomic, nullable) SDLAudioPassThruCapabilities *inputStreamOptions;
@property (assign, nonatomic) double inputStreamAmplifierFactor;

@property (assign, nonatomic) NSUInteger inputStreamRetryCounter;

@end

@implementation SDLAudioIOManager

- (instancetype)initWithManager:(SDLManager *)sdlManager delegate:(id<SDLAudioIOManagerDelegate>)delegate {
    self = [super init];
    if (!self) { return nil; }

    self.delegate = delegate;
    
    self.sdlManager = sdlManager;
    self.sdlManager.streamManager.audioManager.delegate = self;

    self.outputStreamState = SDLAudioIOManagerStateStopped;
    self.inputStreamState = SDLAudioIOManagerStateStopped;
    
    self.inputStreamOptions = nil;
    self.inputStreamAmplifierFactor = 0;
    
    self.inputStreamRetryCounter = 0;

    return self;
}

- (BOOL)isOutputStreamPlaying {
    return self.outputStreamState != SDLAudioIOManagerStateStopped;
}

- (BOOL)isInputStreamPlaying {
    return self.inputStreamState != SDLAudioIOManagerStateStopped;
}

- (void)setInputStreamState:(SDLAudioIOManagerState)inputStreamState {
    NSLog(@"Change Input Stream state from %@ to %@", [self nameForStreamState:self->_inputStreamState], [self nameForStreamState:inputStreamState]);
    self->_inputStreamState = inputStreamState;
}

- (void)setOutputStreamState:(SDLAudioIOManagerState)outputStreamState {
    NSLog(@"Change Output Stream state from %@ to %@", [self nameForStreamState:self->_outputStreamState], [self nameForStreamState:outputStreamState]);
    self->_outputStreamState = outputStreamState;
}

- (NSString *)nameForStreamState:(SDLAudioIOManagerState)state {
    switch (state) {
        case SDLAudioIOManagerStateStopped:
            return @"Stopped";
        case SDLAudioIOManagerStateStarting:
            return @"Starting";
        case SDLAudioIOManagerStatePaused:
            return @"Paused";
        case SDLAudioIOManagerStatePausing:
            return @"Pausing";
        case SDLAudioIOManagerStateStarted:
            return @"Started";
        case SDLAudioIOManagerStateStopping:
            return @"Stopping";
    }
}

#pragma mark- Output stream area

- (void)writeOutputStreamWithFileURL:(NSURL *)fileURL {
    // push the audio file to the underlying manager
    [self.sdlManager.streamManager.audioManager pushWithFileURL:fileURL];
    
    if (self.outputStreamState == SDLAudioIOManagerStateStopped) {
        self.outputStreamState = SDLAudioIOManagerStateStarting;

        // in case the input stream is active we have to get it to pause (acutally is stopped but it's an extra case)
        if (self.inputStreamState == SDLAudioIOManagerStateStarting || self.inputStreamState == SDLAudioIOManagerStateStarted) {
            // we should pause the playback and wait for being called again.
            [self sdl_pauseInputStream];
            return;
        }
    }
    
    // in case the input stream is stopping or pausing we will return here and wait until it's fully paused or stopped (there we will start the stream)
    if (self.inputStreamState == SDLAudioIOManagerStateStopping || self.inputStreamState == SDLAudioIOManagerStatePausing) {
        return;
    }
    
    [self sdl_startOutputStream];
}

- (void)sdl_startOutputStream {
    if (self.outputStreamState == SDLAudioIOManagerStateStarting) {
        self.outputStreamState = SDLAudioIOManagerStateStarted;
        
        if ([self.delegate respondsToSelector:@selector(audioManagerDidStartOutputStream:)]) {
            [self.delegate audioManagerDidStartOutputStream:self];
        }
        
        // the input stream is not in our way we can start the output stream
        [self.sdlManager.streamManager.audioManager playNextWhenReady];
    }
}

- (void)sdl_continueOutputStream:(SDLAudioStreamManager * _Nonnull)audioManager {
    if (audioManager.queue.count > 0) {
        // continue dequeuing
        [audioManager playNextWhenReady];
    } else {
        // queue is now empty. stop the output stream
        self.outputStreamState = SDLAudioIOManagerStateStopped;
        
        if ([self.delegate respondsToSelector:@selector(audioManagerDidStopOutputStream:)]) {
            [self.delegate audioManagerDidStopOutputStream:self];
        }
        
        // possible that the input stream is paused. resume it
        if (self.inputStreamState == SDLAudioIOManagerStatePaused) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sdl_startInputStream];
            });
        }
    }
}

- (void)audioStreamManager:(SDLAudioStreamManager *)audioManager fileDidFinishPlaying:(NSURL *)fileURL successfully:(BOOL)successfully {
    if ([self.delegate respondsToSelector:@selector(audioManager:didFinishPlayingURL:)]) {
        [self.delegate audioManager:self didFinishPlayingURL:fileURL];
    }
    
    [self sdl_continueOutputStream:audioManager];
}

- (void)audioStreamManager:(SDLAudioStreamManager *)audioManager errorDidOccurForFile:(NSURL *)fileURL error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(audioManager:errorDidOccurForURL:error:)]) {
        [self.delegate audioManager:self errorDidOccurForURL:fileURL error:error];
    }
    
    [self sdl_continueOutputStream:audioManager];
}

#pragma mark- Input stream area

- (void)startInputStream {
    if (self.inputStreamState != SDLAudioIOManagerStateStopped && self.inputStreamState != SDLAudioIOManagerStatePaused) {
        NSLog(@"AudioManager error. Start input stream not valid. Current input stream state is %li", (long)self.inputStreamState);
        return;
    }
    
    if (self.outputStreamState != SDLAudioIOManagerStateStopped) {
        self.inputStreamState = SDLAudioIOManagerStatePaused;
    } else {
        [self sdl_startInputStream];
    }
}

- (void)sdl_startInputStream {
    if (self.inputStreamState != SDLAudioIOManagerStateStopped && self.inputStreamState != SDLAudioIOManagerStatePaused) {
        NSLog(@"AudioManager error. Start input stream (internal) not valid. Current input stream state is %li", (long)self.inputStreamState);
        return;
    }
    
    // prepare the input stream state
    self.inputStreamState = SDLAudioIOManagerStateStarting;
    
    // find a proper apt setting. best would be 16bit,16khz but at least one capable option is selected
    SDLAudioPassThruCapabilities *audioOptions = self.sdlManager.registerResponse.audioPassThruCapabilities.lastObject;
    
    // fallback options are set. PCM with 16bit and 16khz still preferred (sufficient for voice recognition)
    for (SDLAudioPassThruCapabilities *item in self.sdlManager.registerResponse.audioPassThruCapabilities) {
        if (![item.audioType isEqualToEnum:SDLAudioTypePCM]) continue;
        if (![item.bitsPerSample isEqualToEnum:SDLBitsPerSample16Bit]) continue;
        if (![item.samplingRate isEqualToEnum:SDLSamplingRate16KHZ]) continue;
        
        audioOptions = item;
        break;
    }
    
    // split the text into multiple lines.
    NSArray<NSString *> *lines = [self.inputStreamText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    self.inputStreamOptions = audioOptions;
    self.inputStreamAmplifierFactor = 0;
    
    // create a request we will be sending
    SDLPerformAudioPassThru *performAudioInput = [[SDLPerformAudioPassThru alloc] init];
    performAudioInput.audioType = audioOptions.audioType;
    performAudioInput.bitsPerSample = audioOptions.bitsPerSample;
    performAudioInput.samplingRate = audioOptions.samplingRate;
    performAudioInput.initialPrompt = [NSArray arrayWithObject:self.inputStreamPrompt];
    performAudioInput.maxDuration = @1000000;
    performAudioInput.audioPassThruDisplayText1 = lines.count > 0 ? lines[0] : nil;
    performAudioInput.audioPassThruDisplayText2 = lines.count > 1 ? lines[1] : nil;
    performAudioInput.muteAudio = @YES;
    
    __weak SDLAudioIOManager * weakSelf = self;
    
    // this is the important area... handle the microphone audio data
    performAudioInput.audioDataHandler = ^(NSData * _Nullable audioData) {
        __strong SDLAudioIOManager * strongSelf = weakSelf;
        if (strongSelf == nil || audioData == nil) {
            return;
        }
        
        __strong id<SDLAudioIOManagerDelegate> d = strongSelf.delegate;
        
        if (strongSelf.inputStreamState == SDLAudioIOManagerStateStarting) {
            strongSelf.inputStreamState = SDLAudioIOManagerStateStarted;
            
            if (d && [d respondsToSelector:@selector(audioManager:didStartInputStreamWithOptions:)]) {
                [d audioManager:strongSelf didStartInputStreamWithOptions:audioOptions];
            }
        }
        
        if (strongSelf.inputStreamState == SDLAudioIOManagerStateStarted) {
            if (d && [d respondsToSelector:@selector(audioManager:didReceiveAudioData:)]) {
                NSMutableData *mutableAudioData = [audioData mutableCopy];
                double factor = [strongSelf sdl_calculateAmplifierFactor:[mutableAudioData bytes] size:mutableAudioData.length];
                
                if (factor > strongSelf.inputStreamAmplifierFactor) {
                    strongSelf.inputStreamAmplifierFactor = MIN(MIN(factor, strongSelf.inputStreamAmplifierFactor + INPUT_STREAM_AMPLIFIER_INCREASE_STEP), INPUT_STREAM_AMPLIFIER_FACTOR_MAX);
                } else {
                    strongSelf.inputStreamAmplifierFactor = factor;
                }
                
                [strongSelf sdl_applyAmplifierFactor:strongSelf.inputStreamAmplifierFactor data:[mutableAudioData mutableBytes] size:mutableAudioData.length];
                
                [d audioManager:strongSelf didReceiveAudioData:mutableAudioData];
            }
        }
    };
    
    // send the request out to the head unit
    NSLog(@"Sending request %@", [performAudioInput serializeAsDictionary:0]);
    [self.sdlManager sendRequest:performAudioInput withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Response received %@", [response serializeAsDictionary:0]);
        __strong SDLAudioIOManager * strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        if (strongSelf.inputStreamState == SDLAudioIOManagerStateStarting && [response.resultCode isEqualToEnum:SDLResultRejected] && self.inputStreamRetryCounter < 3) {
            // this state can be true if the request is rejected so we set the state back to paused and retry in a bit
            self.inputStreamRetryCounter++;
            strongSelf.inputStreamState = SDLAudioIOManagerStatePaused;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf sdl_startInputStream];
            });
            // do not notify that it didn't work
            return;
        } else if (strongSelf.inputStreamState == SDLAudioIOManagerStatePausing) {
            // the response is received because we wanted to pause the input stream
            strongSelf.inputStreamState = SDLAudioIOManagerStatePaused;
        } else {
            // the input stream was started (or even stopping) and now we want to finally stop it
            strongSelf.inputStreamState = SDLAudioIOManagerStateStopped;
        }
        
        // reset the retry counter in case previous tries were rejected
        self.inputStreamRetryCounter = 0;
        
        // notify about the result (except it was rejected and we want to retry
        __strong id<SDLAudioIOManagerDelegate> d = strongSelf.delegate;
        if (d && [d respondsToSelector:@selector(audioManager:didFinishInputStreamWithResult:)]) {
            [d audioManager:strongSelf didFinishInputStreamWithResult:response.resultCode];
        }
        
        // if output stream is starting. now it's time to do so.
        if (strongSelf.outputStreamState == SDLAudioIOManagerStateStarting) {
            [strongSelf sdl_startOutputStream];
        }
    }];
}

- (void)stopInputStream {
    switch (self.inputStreamState) {
        case SDLAudioIOManagerStatePaused:
            // stream is paused so immediately set it to stopped.
            self.inputStreamState = SDLAudioIOManagerStateStopped;
            break;
        case SDLAudioIOManagerStatePausing:
            // stream is pausing we already sent a end request so update the status to stopping
            self.inputStreamState = SDLAudioIOManagerStateStopping;
            break;
        case SDLAudioIOManagerStateStarted:
        case SDLAudioIOManagerStateStarting:
            // if input stream is starting or already started we have to send a request to stop it
            self.inputStreamState = SDLAudioIOManagerStateStopping;
            [self.sdlManager sendRequest:[[SDLEndAudioPassThru alloc] init]];
            break;
        default:
            // other states are irrelevant
            break;
    }
}

- (void)sdl_pauseInputStream {
    switch (self.inputStreamState) {
        case SDLAudioIOManagerStateStarted:
        case SDLAudioIOManagerStateStarting:
            // if input stream is starting or already started we have to send a request to stop it but the status will be pausing (or paused later on)
            self.inputStreamState = SDLAudioIOManagerStatePausing;
            [self.sdlManager sendRequest:[[SDLEndAudioPassThru alloc] init]];
            break;
        default:
            // other states are irrelevant
            break;
    }
}

- (double)sdl_calculateAmplifierFactor:(const void *)bytedata size:(NSUInteger)size {
    double factor = INPUT_STREAM_AMPLIFIER_FACTOR_MAX;
    
    if ([self.inputStreamOptions.bitsPerSample isEqualToEnum:SDLBitsPerSample16Bit]) {
        // divide count to short elements
        size = size >> 1;
        
        // create pointer with short type (2 byte int)
        int16_t *shortbuffer = (int16_t *)bytedata;
        
        for (int i = 0; i < size; i++) {
            int16_t a = shortbuffer[i];
            double f;
            if (a >= 0) {
                f = ((double)INT16_MAX) / ((double)a);
            } else {
                f = ((double)INT16_MIN) / ((double)a);
            }
            
            factor = MIN(factor, f);
        }
    } else {
        // create pointer with byte type (signed byte int)
        int8_t *bytebuffer = (int8_t *)bytedata;
        
        for (int i = 0; i < size; i++) {
            int8_t a = bytebuffer[i];
            double f;
            if (a >= 0) {
                f = ((double)INT8_MAX) / ((double)a);
            } else {
                f = ((double)INT8_MIN) / ((double)a);
            }
            
            factor = MIN(factor, f);
        }
    }
    
    return factor;
}

- (void)sdl_applyAmplifierFactor:(double)factor data:(void *)bytedata size:(NSUInteger)size {
    if (factor == 1.0) {
        return;
    }
    
    if ([self.inputStreamOptions.bitsPerSample isEqualToEnum:SDLBitsPerSample16Bit]) {
        // divide count to short elements
        size = size >> 1;
        
        // create pointer with short type (2 byte int)
        int16_t *shortbuffer = (int16_t *)bytedata;
        
        // loop through all samples
        for (int i = 0; i < size; i++) {
            int16_t a = shortbuffer[i];
            // apply the amplifier factor with the best precision and round it
            a = (int16_t)(round(((double)a) * factor));
            // write the amplified sample value back to the buffer
            shortbuffer[i] = a;
        }
    } else {
        // create pointer with byte type (signed byte int)
        int8_t *bytebuffer = (int8_t *)bytedata;
        
        // loop through all samples
        for (int i = 0; i < size; i++) {
            // get the sample value
            int8_t a = bytebuffer[i];
            // apply the amplifier factor with the best precision and round it
            a = (int8_t)(round(((double)a) * factor));
            // write the amplified sample value back to the buffer
            bytebuffer[i] = a;
        }
    }
}


@end

NS_ASSUME_NONNULL_END
