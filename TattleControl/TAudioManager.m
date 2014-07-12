//
//  TAudioManager.m
/*
 Copyright (c) 2014 TattleUI (http://www.npcompete.com/)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "TAudioManager.h"
#import "TFileManager.h"
#import "TConstants.h"
#import "TLogControlMacro.h"

@interface TAudioManager()
{
    float pitch;
}

@end

@interface TAudioManager()

@property(nonatomic, strong) NSMutableDictionary *recordingParamsDicionary;
@property(nonatomic, strong) NSString *recordingFormat;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) NSString *fileName;

@property(nonatomic, strong) NSTimer *playerTimer;
@property(nonatomic, strong) NSTimer *pitchTimer;
@property(nonatomic) BOOL isRecorderPaused, isPlayerPaused;

@end

@implementation TAudioManager

+(TAudioManager*)sharedAudioManager{
    
    static dispatch_once_t predicate = 0;
    static TAudioManager *sharedInstance = nil;
    dispatch_once(&predicate,  ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)assignTempFileName:(NSString*)fileName
{
    self.fileName = fileName;
}

#pragma amrk Recorder related functions
#pragma mark getRecorderStatus
-(TRecorderStatus)getRecorderStatus
{
    if (self.recorder.isRecording)
        return TRecorderStatusRecording;
    
    else if (self.isRecorderPaused)
        return TRecorderStatusPaused;
    else
        return TRecorderStatusIdle;
}

-(NSMutableDictionary*)recordingParamsDicionary
{
    if(!_recordingParamsDicionary)
    {
        _recordingParamsDicionary = [[NSMutableDictionary alloc]init];
        
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TFORMAT_ID] forKey: AVFormatIDKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TSAMPLE_RATE] forKey: AVSampleRateKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TNUMBER_OF_CHANNEL] forKey:AVNumberOfChannelsKey];
        
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TBIT_RATE_KEY] forKey:AVEncoderBitRateKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TBIT_DEPTH_KEY] forKey:AVLinearPCMBitDepthKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInteger:TAUDIO_QUALITY] forKey: AVEncoderAudioQualityKey];
        
    }
    return _recordingParamsDicionary;
}

-(AVAudioRecorder*)recorder{
    
    if(!_recorder)
    {
        self.fileName = (self.fileName) ? self.fileName : [[TFileManager sharedFileManager] getAudioFilePath];

        NSError *recordingError = nil;
        _recorder = [[ AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.fileName] settings:self.recordingParamsDicionary error:&recordingError];
        _recorder.meteringEnabled = YES;
        
        if (recordingError)
        {
            TLog(@"Recodring error: %@", recordingError.description);
        }
    }
    return _recorder;
}

#pragma mark StartRecorder and timer
-(void)startRecorderAndTimer
{
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    self.isRecorderPaused = NO;
    [self enableRecordingPitchTimer];
}

#pragma mark StopRecorder and timer
-(void)stopRecorderAndInvalidateTimer
{
    self.isRecorderPaused = NO;
    [self.recorder stop];
    [self invalidateRecorderAndTimer];
}

#pragma mark EnableRecordingPitchTimer
-(void)enableRecordingPitchTimer
{
    self.pitchTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target: self selector: @selector(pitchTimerCallBack:) userInfo: nil repeats: YES];
}

#pragma mark DisableRecorderAndPitchTimer
-(void)invalidateRecorderAndTimer
{
    self.recorder = nil;
    [self.pitchTimer invalidate];
}

#pragma mark Start Recording
-(TRecordingStatus)startRecording:(NSString*)fileName
{
    if(![self.fileName isEqualToString:fileName])
    {
        self.fileName = fileName;
        self.recorder = nil;
    }
    
    if(self.recorder.isRecording || self.isRecorderPaused)
    {
        return [self toggleRecording];
    }
    else
    {
        //Activate audio session
        if(![self activateAudioSession])
            return TRecordingStatusFailedToStartAudioSession;
        
        if ([self.recorder prepareToRecord] == YES)
        {
            [self startRecorderAndTimer];
            [[TFileManager sharedFileManager]rollbackTheRecordedAudios];
            return TRecordingStatusStarted;
        }
        else
        {
            TLog(@"Error: Recorder not ready:");
            return TRecordingStatusFailedToStart;
        }
    }
}

#pragma mark Toggle recording
-(TRecordingStatus)toggleRecording
{
    if(self.recorder.recording)
    {
        [self pauseRecording];
        return TRecordingStatusPaused;
    }
    else
    {
        [self resumeRecording];
        return TRecordingStatusResumed;
    }
}

#pragma mark PauseRecording
-(TRecordingStatus)pauseRecording
{
    [self.recorder pause];
    self.isRecorderPaused = YES;
    [self.pitchTimer invalidate];
    return TRecordingStatusPaused;
}

#pragma mark resumeRecording
-(TRecordingStatus)resumeRecording
{
    [self startRecorderAndTimer];
    return TRecordingStatusResumed;
}

#pragma mark PauseRecording
-(TRecordingStatus)stopRecording
{
    TRecorderStatus recorderStatus = [self getRecorderStatus];

    if(recorderStatus == TRecorderStatusPaused || recorderStatus == TRecorderStatusRecording)
    {
        [self stopRecorderAndInvalidateTimer];
        return TRecordingStatusAlreadyStopped;
    }
    return TRecordingStatusUnkownState;
}

#pragma mark PitchTimerCallback
-(void)pitchTimerCallBack:(NSTimer*)timer
{
    [self.recorder updateMeters];
    float linear1 = pow (10, [self.recorder averagePowerForChannel:0] / 20);
    
    if (linear1>0.03)
        pitch = linear1+.20;
    else
        pitch = 0.0;
    
    pitch =linear1;
    
    float minutes = floor(self.recorder.currentTime/60);
    float seconds = self.recorder.currentTime - (minutes * 60);
    
    NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
    if(self.recordingProgressBlock)
        self.recordingProgressBlock(time, self.recorder.currentTime,pitch);
}

#pragma mark audioplayer related functions
#pragma mark Enable Player Timer
-(void)enablePlayerTimer
{
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(playerTimerCallBack:) userInfo: nil repeats: YES];
}

#pragma mark InvalidatePlayeranTimer
-(void)invalidatePlayerAndTimer
{
    self.player = nil;
    [self.playerTimer invalidate];
}

#pragma mark startPlayerAndTimer
-(void)startplayerAndTimer
{
    [self.player play];
    self.isPlayerPaused = NO;
    [self enablePlayerTimer];
}

#pragma mark stopPayerAndInvalidateTimer
-(void)stopPlayerAndInvalidateTimer
{
    self.isPlayerPaused = NO;
    [self.player stop];
    [self invalidatePlayerAndTimer];
}

#pragma mark getPlayerStatus
-(TPlayerStatus)getPlayerStatus
{
    if(self.player.isPlaying)
        return TPlayerStatusPlaying;

    else if(self.isPlayerPaused)
        return TPlayerStatusPaused;
    
    else
        return TPlayerStatusIdle;
}

#pragma mark
#pragma mark playerTimerCallback
-(void)playerTimerCallBack:(NSTimer*)timer{
    
    if(self.playingProgressBlock)
    {
        float minutes = floor(self.player.currentTime/60);
        float seconds = self.player.currentTime - (minutes * 60);
        
        NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
        self.playingProgressBlock(time, self.player.currentTime, self.player.duration);
    }
}

#pragma mark activateAudioSession
-(BOOL)activateAudioSession{

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    if(![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err])
    {
        TLog(@"Error: failed to set category for audio session+++ description %@", err.description);
        return NO;
    }
    
    if(![audioSession setCategory:AVAudioSessionCategoryMultiRoute error:&err])
    {
        TLog(@"Error: failed to set category for audio session+++ description %@", err.description);
        return NO;
    }
    
    BOOL active = [audioSession setActive: YES error: &err];
    if (!active)
        TLog(@"Failed to set category on AVAudioSession+++ Description %@", err.description);
    
    return YES;
}

#pragma mark AVAudiopayer delegates
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    if(self.playingCompletionBlock)
        self.playingCompletionBlock();
        
    [self stopPlaying];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    TLog(@"Error: AudioPlayer DecodeError Occured %@", error.description);
    if(self.audioPlayerErrorBlock)
        self.audioPlayerErrorBlock(error);
}

#pragma mark startplaying
-(TPlayingStatus)startPlaying:(NSString*)fileName{
    
    if(self.player.isPlaying || self.isPlayerPaused)
    {
        TPlayingStatus status = [self togglePlaying];
        return status;
    }
    else
    {
        //Activate audio session
        if(![self activateAudioSession])
            return TPlayingStatusFailedToStartAudioSession;
        
        //Load audio url
        NSURL *url = [NSURL fileURLWithPath:fileName];
        NSError *error;

        //create audio player with url
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.player.numberOfLoops = 0;
        [self.player setDelegate: self];

        //Check the player is ready for play
        if(![self.player prepareToPlay]){
            TLog(@"Failed to start player %@", error.description);
            return TPlayingStatusFailedToStart;
        }
        
        [self startplayerAndTimer];
        return TPlayingStatusStarted;
    }
}

#pragma mark togglePlaying
-(TPlayingStatus)togglePlaying
{
    if(self.player.isPlaying)
    {
        return  [self pausePlayer];
    }

    else if(self.isPlayerPaused)
    {
        return  [self resumePlayer];
    }
    
    return TPlayingStatusUnknownState;
}

#pragma mark resumePlaying
-(TPlayingStatus)resumePlayer
{
    [self.player play];
    [self enablePlayerTimer];
    return TPlayingStatusResumed;
}

#pragma mark pausePlaying
-(TPlayingStatus)pausePlayer
{
    [self.player pause];
    self.isPlayerPaused = YES;
    [self.playerTimer invalidate];
    return TPlayingStatusPaused;
}

#pragma mark setCurrentPlaying time
-(void)setCurrentPlayingTime:(double)secs
{
    if (self.player.isPlaying || self.isPlayerPaused)
    {
        [self.player setCurrentTime:secs];
    }
    else
    {
        TLog(@"Error: Can't set current time. Audio  player not started yet");
    }
}

#pragma invalidateCompletionBlock
-(void)invalidateAllProgressBlock
{
    self.playingProgressBlock = nil;
    self.playingCompletionBlock = nil;
    
    self.recordingProgressBlock = nil;
    self.audioPlayerErrorBlock = nil;
}

#pragma mark stopPlaying
-(TPlayingStatus)stopPlaying
{
    [self.player stop];
    [self invalidatePlayerAndTimer];
    self.isPlayerPaused = NO;
    return TPlayingStatusStopped;
}

@end
