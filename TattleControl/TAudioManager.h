//
//  TAudioManager.h
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
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/* enumeration Constant for Recording status, this constant used for UI appearance
 @TRecordingStatusStarted : recorder already started and being in recording.
 @TRecordingStatusPaused : recorder in pause state.
 @TRecordingStatusAlreadyStopped: recorder stopped.
 @TRecordingStatusResumed : Recorder going to resume state from pause.
 @TRecordingStatusFailedToStart: Fail Due to hardware support, logging describ failed reason.
 @TRecordingStatusFailedToStartAudioSession: Fail due to audio session, that means, if you don't allow with microphone in your setting, audio session will fail
 */

typedef enum TRecordingStatus{
    
    TRecordingStatusStarted,
    TRecordingStatusPaused,
    TRecordingStatusAlreadyStopped,
    TRecordingStatusResumed,
    TRecordingStatusFailedToStart,
    TRecordingStatusFailedToStartAudioSession,
    TRecordingStatusUnkownState
}TRecordingStatus;

/* enumeration for Recorder. this constant show state of recorder.
 @TRecorderStatusIdle: Recorder yet to be start
 @TRecorderStatusRecording: Recorder started and being in recording
 @TRecorderStatusPaused : Recorder in pause state.
 */

typedef enum TRecorderStatus{
    
    TRecorderStatusIdle,
    TRecorderStatusRecording,
    TRecorderStatusPaused,
    TRecorderStatusUnkown
}TRecorderStatus;

/* enumeration Constant for playing status which used fro UI Appearance
 @TPlayingStatusStarted : player already started and being in playing.
 @TPlayingStatusPaused : player in pause state.
 @TPlayingStatusStopped: playing stopped.
 @TPlayingStatusResumed : player going to resume state from pause.
 @TPlayingStatusFailedToStart: Fail Due to hardware support, logging describ failed reason.
 @TPlayingStatusFailedToStartAudioSession: Fail due to audio session, that means, if you don't allow with microphone in your setting, audio session will fail
 */

typedef enum TPlayingStatus{
    TPlayingStatusStarted,
    TPlayingStatusPaused,
    TPlayingStatusStopped,
    TPlayingStatusResumed,
    TPlayingStatusFailedToStart,
    TPlayingStatusFailedToStartAudioSession,
    TPlayingStatusUnknownState
    
}TPlayingStatus;

/* enumeration for player. this constant show state of player.
 @TPlayerStatusIdle: player yet to be start
 @TPlayerStatusPlaying: player started and being in playing
 @TPlayerStatusPaused : Player in pause state.
 */

typedef enum TPlayerStatus{
    TPlayerStatusIdle,
    TPlayerStatusPlaying,
    TPlayerStatusPaused
}TPlayerStatus;

/* Recording progress block periodically return recording time and corresponding pictch lever    */
typedef void (^TRecordingProgressBlock) (NSString* recordingTime, CGFloat seconds,float pitchLevel);

/* Playing progress block periodically retrun playing time with respect to total duration */
typedef void (^TPlayingProgressBlock) (NSString* currentPlayingTime, CGFloat seconds, CGFloat totalDuration);

/* Playing completion block once player finish playing corresponding audio file which used to make UI Changes */
typedef void (^TPlayingCompletionBlock) ();

/* If error occur during playing, this block get called to make changes in UI */
typedef void (^TAudioPlayerDecodeErrorBlock) (NSError *decodeError);


@interface TAudioManager : NSObject <AVAudioPlayerDelegate>

@property(nonatomic, copy) TRecordingProgressBlock recordingProgressBlock;
@property(nonatomic, copy) TPlayingProgressBlock playingProgressBlock;
@property(nonatomic, copy) TPlayingCompletionBlock playingCompletionBlock;
@property(nonatomic, copy) TAudioPlayerDecodeErrorBlock audioPlayerErrorBlock;

//Shared control for audio related methods
+(TAudioManager*)sharedAudioManager;

//Start recording with created file path(Document directory), if file doesn't exist at file path, recorder will fail to start
-(TRecordingStatus)startRecording:(NSString*)fileName;
//This will change recorder state to from pause to resume or vice versa.
-(TRecordingStatus)toggleRecording;
//This method going to stop recorder.
-(TRecordingStatus)stopRecording;

//Start playing with file path, if file doesn't exist at file path, player will fail to start
-(TPlayingStatus)startPlaying:(NSString*)fileName;
//This will change player state from pause to resume or vice versa.
-(TPlayingStatus)togglePlaying;
//This method going to stop player.
-(TPlayingStatus)stopPlaying;

//Getting Current status of the recoder
-(TRecorderStatus)getRecorderStatus;
//Getting Current status of the player
-(TPlayerStatus)getPlayerStatus;

//Assign file name for recording.
-(void)assignTempFileName:(NSString*)fileName;
@end
