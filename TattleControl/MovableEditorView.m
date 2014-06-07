//
//  MovableEditorView.m
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

#import "MovableEditorView.h"
#import "SnapShotView.h"
#import "TAudioManager.h"
#import "TFileManager.h"
#import "TattleControl.h"
#import "CommonMacro.h"
#import <QuartzCore/QuartzCore.h>
#import "TConstants.h"

NSString *const AUDIO_SELECTED_IMAGE        = @"audio_selected.png";
NSString *const AUDIO_UNSELECTED_IMAGE      = @"audio_unselected.png";

NSString *const EMAIL_SELECTED_IMAGE        = @"email_selected.png";
NSString *const EMAIL_UNSELECTED_IMAGE      = @"email_Unselected.png";

NSString *const RECORD_IMAGE    = @"record.png";
NSString *const STOP_IMAGE      = @"stop.png";
NSString *const PLAY_IMAGE      = @"play.png";

NSInteger const kMaxRecordingTime  = 2.0; //in minutes
NSInteger const kSecondsPerMinutes = 60.0;
CGFloat const MovableControlBackgroundAlpha = 0.4;

enum{
    AUDIO_BTN_ID = 100,
    EMAIL_BTN_ID
};
typedef enum NSInteger MovableControlButtonId;

@interface PlayRecordProgressView : UIView

@property (nonatomic) CGFloat value;
@property CGFloat minimumValue;
@property CGFloat maximumValue;
@property CGFloat arcStartAngle;
@property CGFloat cutoutSize;
@property CGFloat valueArcWidth;
@property (nonatomic,strong) UIColor *trackingColor;
@property (nonatomic,strong) CAShapeLayer *unTrackedLayer;

-(void)resetProgressView;

@end

@interface MovableEditorView()

@property(nonatomic, weak) IBOutlet UIButton *audioBtn, *emailBtn;

@property(nonatomic) CGFloat recentlyRecordedAudioPlayBackTime;
@property(nonatomic) NSInteger selectedBtnId, previouslySelectedBtnId;
@property(nonatomic) BOOL isRecordedAudioAvailable;

@property (nonatomic,weak) IBOutlet PlayRecordProgressView *progressView;

-(IBAction)audioPressed:(id)sender;
-(IBAction)emailPressed:(id)sender;

@end

@implementation PlayRecordProgressView
#define kDCControlDegreesToRadians(x) (M_PI * (x) / 180.0)
#define kDCControlRadiansToDegrees(x) ((x) * 180.0 / M_PI)

-(void)awakeFromNib
{
    self.clipsToBounds = NO;
    self.opaque = YES;
    self.cutoutSize = 0.0;
    self.arcStartAngle = 270.0;
    self.minimumValue = 10.0;
    self.maximumValue = 11.0;
    self.valueArcWidth = 1.5;
    self.trackingColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:150.0/255.0 alpha:1];
}

- (void)setValue:(CGFloat)newValue
{
	if (newValue > self.maximumValue)
		_value = self.maximumValue;
	else if (newValue < self.minimumValue)
		_value = self.minimumValue;
	else
		_value = newValue;
	[self setNeedsDisplay];
}
-(void)fillLayerCommonFields:(CAShapeLayer*)subLayer
{
    subLayer.fillColor = [UIColor clearColor].CGColor;
    subLayer.lineWidth = self.frame.size.width/12;
    subLayer.shadowColor = subLayer.fillColor;
    subLayer.shadowRadius = 50.0;
    subLayer.masksToBounds = NO;
    subLayer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    subLayer.shadowOpacity = 0.5f;
    subLayer.shadowPath = subLayer.path;
}

-(void)showUnTrackCircle
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    if (!self.unTrackedLayer)
    {
        CAShapeLayer *unTrackedCircle = [CAShapeLayer layer];
        CGMutablePathRef unTrackedPath = CGPathCreateMutable();
        CGPathAddArc(unTrackedPath, nil, centerPoint.x , centerPoint.y, self.frame.size.width/2 -resizeDependsDevice(2) , kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2), kDCControlDegreesToRadians(self.arcStartAngle + 360 - self.cutoutSize / 2), NO);
        unTrackedCircle.path = unTrackedPath;
        
        [self fillLayerCommonFields:unTrackedCircle];
        unTrackedCircle.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        self.unTrackedLayer = unTrackedCircle;
        CGPathRelease(unTrackedPath);
    }
    [self.layer addSublayer:self.unTrackedLayer];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGRect boundsRect = self.bounds;
	float x = boundsRect.size.width / 2;
	float y = boundsRect.size.height / 2;
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, self.valueArcWidth);
    [self.trackingColor set];
    // Drawing code
    CGFloat valueAdjusted = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    CGContextAddArc(context,
                    x,
                    y,
                    boundsRect.size.width / 2 -resizeDependsDevice(2),
                    kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2),
                    kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2 + (360 - self.cutoutSize) * valueAdjusted),
                    0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

-(void)resetProgressView
{
    self.value = 10.0;
    [self.unTrackedLayer removeFromSuperlayer];
}

@end

@implementation MovableEditorView

#pragma mark - setBackground Color for this

-(void)assignBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha
{
    self.backgroundColor = [backgroundColor colorWithAlphaComponent:alpha];
}

-(void)assignBackgroundColor:(UIColor *)backgroundColor
{
    [self assignBackgroundColor:backgroundColor withAlpha:MovableControlBackgroundAlpha];
}

#pragma mark - Shared Control

+(MovableEditorView*)sharedView
{
    static dispatch_once_t predicate = 0;
    static MovableEditorView *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        NSString *nibName = IS_IPAD ? @"MovableEditorViewiPad" : @"MovableEditorView";
        sharedInstance = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
        CGRect frame = [[UIScreen mainScreen] bounds];
        [sharedInstance setFrame:CGRectMake(frame.origin.x, frame.size.height/2, sharedInstance.frame.size.width, sharedInstance.frame.size.height)];
        [sharedInstance assignBackgroundColor:[UIColor blackColor]];//Default
        sharedInstance.layer.cornerRadius = resizeDependsDevice(4.0);
        sharedInstance.layer.shadowColor = [[[UIColor clearColor]colorWithAlphaComponent:0.4 ]CGColor];
        sharedInstance.layer.shadowOpacity = 1.0;
        [sharedInstance addPanGestureRecognizerToContainerView];
        
        [[TAudioManager sharedAudioManager] assignTempFileName:[[TFileManager sharedFileManager] getAudioFilePath]];
        [sharedInstance assignCompletionBlocksForAudioManager];
        
        [sharedInstance.progressView setBackgroundColor:[UIColor clearColor]];
        sharedInstance.progressView.trackingColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        sharedInstance.progressView.valueArcWidth = sharedInstance.progressView.frame.size.width / 12;
    });
    return sharedInstance;
}

#pragma mark reset recording and buttons
-(void)resetRecordingControl
{
    //Change reset recorder image if it is ready to play state
    [self resetRecorderImage];
    [self.progressView resetProgressView];
    [self stopPlaying];
    [self stopRecording];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma Pan Gesture related function
-(void)addPanGestureRecognizerToContainerView
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panningContainerView:)];
    [self addGestureRecognizer:panGesture];
}

-(CGPoint)checkViewOutOfBounds:(UIView*)snapView withBaseView:(UIView*)baseView
{
    NSLog(@"Snap view Frame %f %f",snapView.center.x,snapView.center.y);
    CGPoint leftTopCorner = CGPointMake( snapView.frame.size.width/2,  snapView.frame.size.height/2);
    CGPoint rightTopCorner = CGPointMake( baseView.frame.size.width - snapView.frame.size.width/2, snapView.frame.size.height/2);
    CGPoint leftBottomCornor = CGPointMake( snapView.frame.size.width/2, baseView.frame.size.height -  snapView.frame.size.height/2);
    CGPoint rightBottomCornor = CGPointMake( baseView.frame.size.width - snapView.frame.size.width/2, baseView.frame.size.height -  snapView.frame.size.height/2);
    if ( snapView.center.x < leftTopCorner.x && snapView.center.y < leftTopCorner.y)
        return leftTopCorner;
    else if ( snapView.center.x > rightTopCorner.x  && snapView.center.y < rightTopCorner.y)
        return rightTopCorner;
    else if ( snapView.center.x < leftBottomCornor.x && snapView.center.y > leftBottomCornor.y)
        return leftBottomCornor;
    else if (snapView.center.x  > rightBottomCornor.x && snapView.center.y > rightBottomCornor.y )
        return rightBottomCornor;
    else if ( snapView.center.x < leftTopCorner.x)
        return CGPointMake(leftTopCorner.x, snapView.center.y);
    else if (snapView.center.y < leftTopCorner.y)
        return CGPointMake(snapView.center.x,leftTopCorner.y);
    else if (snapView.center.x > rightTopCorner.x )
        return CGPointMake(rightTopCorner.x, snapView.center.y);
    else if (snapView.center.y < rightTopCorner.y)
        return CGPointMake(snapView.center.x,rightTopCorner.y);
    else if ( snapView.center.x < leftBottomCornor.x )
        return CGPointMake(leftBottomCornor.x, snapView.center.y);
    else if ( snapView.center.y > leftBottomCornor.y)
        return CGPointMake(snapView.center.x, leftBottomCornor.y);
    else if ( snapView.center.x  > rightBottomCornor.x)
        return CGPointMake(rightBottomCornor.x, snapView.center.y);
    else if ( snapView.center.y > rightBottomCornor.y)
        return CGPointMake(snapView.center.x, rightBottomCornor.y);
    else
        return CGPointZero;
}

-(void)panningContainerView:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self.superview];
    CGPoint finalTranslation = CGPointZero;
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateEnded)
    {
        if (CGPointEqualToPoint((finalTranslation =[self checkViewOutOfBounds:gesture.view withBaseView:self.superview]),CGPointZero))
            return;
        else
            gesture.view.center = finalTranslation;
    }
    [gesture setTranslation:CGPointMake(0, 0) inView:self.window];
}

#pragma Save currently selected btn id to maintain state
-(void)setSelectedBtnId:(NSInteger)selectedBtnId
{
    _selectedBtnId = selectedBtnId;
    if(selectedBtnId == AUDIO_BTN_ID)
    {
        [self addNoButtonSelectedView];
    }
    else
    {
        [self stopRecording];
        [self stopPlaying];
        if(selectedBtnId == EMAIL_BTN_ID)
        {
            [self setHidden:YES];
            UIImage *image = [[TattleControl sharedControl] takeScreenShotImageForView:[SnapShotView sharedView]];
            [self setHidden:NO];
            if(image)
            {
                if([[TFileManager sharedFileManager] saveImage:image])
                    [self sendScreenShotAndAudio];
            }
            else
            {
                NSLog(@"Error: Failed to get screen shot ");
            }
        }
    }
}

#pragma send screen shot
-(void)sendScreenShotAndAudio
{
    [[TattleControl sharedControl] sendScreenShotAudioFiles];
}

#pragma mark - No button seleted view to base view
-(void)addNoButtonSelectedView
{
    [[SnapShotView sharedView] addNoSelectionView];
}

#pragma mark assigning completion and progress block
-(void)assignCompletionBlocksForAudioManager
{
    [[TAudioManager sharedAudioManager] setPlayingCompletionBlock:^{
        self.isRecordedAudioAvailable = NO;
        [self.progressView resetProgressView];
        [self changeAudioButtonImageToStartRecodring];
    }];
    [[TAudioManager sharedAudioManager] setRecordingProgressBlock:^(NSString* recordingTime, CGFloat seconds, float pitchLevel){
        CGFloat percent = (CGFloat)(seconds/(kSecondsPerMinutes * kMaxRecordingTime));
        self.progressView.value = self.progressView.minimumValue + percent;
        if(seconds > (kSecondsPerMinutes * kMaxRecordingTime))
        {
            [self audioPressed:self.audioBtn];
            [self.progressView resetProgressView];
        }
    }];
    [[TAudioManager sharedAudioManager] setPlayingProgressBlock:^(NSString *timeString, CGFloat seconds, CGFloat totalDuaration){
        CGFloat percent = (CGFloat)(seconds/totalDuaration);
        self.progressView.value = self.progressView.minimumValue + percent;
        if(seconds >= totalDuaration)
        {
            [self audioPressed:self.audioBtn];
            [self.progressView resetProgressView];
        }
    }];
}

#pragma mark change audio button image to start recording
-(void)changeAudioButtonImageToStartRecodring
{
    [[SnapShotView sharedView] sendNoSelectionViewToBack];
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:RECORD_IMAGE] forState:UIControlStateNormal];
}

#pragma mark change audio button image to stop
-(void)changeAudioButtonImageToStop
{
    [self.progressView showUnTrackCircle];
    [[SnapShotView sharedView] getNoSelectionViewToFront];
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:STOP_IMAGE] forState:UIControlStateNormal];
}

-(void)changeAudioButtonImageToStartPlaying
{
    [self.progressView resetProgressView];
    [[SnapShotView sharedView] sendNoSelectionViewToBack];
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:PLAY_IMAGE] forState:UIControlStateNormal];
}

#pragma mark change audio button image to start playing
-(void)stopRecording
{
    if([[TAudioManager sharedAudioManager] getRecorderStatus] == TRecorderStatusRecording)
    {
        [[TAudioManager sharedAudioManager] stopRecording];
        [self.progressView resetProgressView];
        [self changeAudioButtonImageToStartRecodring];
    }
}

-(void)stopPlaying
{
    if([[TAudioManager sharedAudioManager] getPlayerStatus] == TPlayerStatusPlaying)
    {
        [[TAudioManager sharedAudioManager] stopPlaying];
        [self.progressView resetProgressView];
        [self changeAudioButtonImageToStartRecodring];
    }
}

-(IBAction)audioPressed:(id)sender
{
    [self controlRecorderAndPlayer];
}

-(IBAction)emailPressed:(id)sender
{
    [self setSelectedBtnId:EMAIL_BTN_ID];
}

#pragma mark audio button fuctionality
-(void)controlRecorderAndPlayer{
    if([[TAudioManager sharedAudioManager] getRecorderStatus] == TRecorderStatusIdle || [[TAudioManager sharedAudioManager] getRecorderStatus] == TRecorderStatusUnkown)//Recorder status idle, unknown
    {
        if(self.isRecordedAudioAvailable == YES)
        {
            if([[TAudioManager sharedAudioManager] getPlayerStatus] == TPlayerStatusIdle)
            {
                NSString *recentlyRecordedFilePath = [[TFileManager sharedFileManager] getRecentlyRecordedAudioFilePath];
                if(recentlyRecordedFilePath)
                {
                    if([[TAudioManager sharedAudioManager] startPlaying:recentlyRecordedFilePath] != TPlayingStatusStarted)
                    {
                        [self changeAudioButtonImageToStartRecodring];
                        return;
                    }
                    [self changeAudioButtonImageToStop];
                }
                else
                {
                    NSLog(@"Error: No recorded audio file found");
                }
            }
            else if([[TAudioManager sharedAudioManager] getPlayerStatus] == TPlayerStatusPlaying)
            {
                [self stopPlaying];
                [self resetRecorderImage];
            }
        }
        else
        {
            if([[TAudioManager sharedAudioManager] startRecording:[[TFileManager sharedFileManager] getAudioFilePath]] != TRecordingStatusStarted)
            {
                return;
            }
            self.previouslySelectedBtnId = self.selectedBtnId;
            [self setSelectedBtnId:AUDIO_BTN_ID];
            //Change to stop button image
            [self changeAudioButtonImageToStop];
        }
    }
    else if([[TAudioManager sharedAudioManager] getRecorderStatus] == TRecorderStatusRecording)//Recorder status recording
    {
        [[TAudioManager sharedAudioManager] stopRecording];
        [self.progressView resetProgressView];
        
        //Change to start playing
        [self changeAudioButtonImageToStartPlaying];
        self.isRecordedAudioAvailable = YES;
    }
}

-(void)resetRecorderImage
{
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:RECORD_IMAGE] forState:UIControlStateNormal];
    self.isRecordedAudioAvailable = NO;
}

@end
