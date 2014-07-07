//
//  TattleControl.m
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

#import "TattleControl.h"
#import "CommonMacro.h"
#import "SnapShotView.h"
#import "TFileManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TPopupView.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#define SquareButtonSize 40
#define DefaultSpotImageColor [UIColor colorWithRed:30.0/255.0 green:153.0/255.0 blue:246.0/255.0 alpha:0.75];

typedef enum SpotImageSizeFactor : NSUInteger {
    SpotImageSizeFactorCornerLineWidth = 12,/* for iPhone, iPad = 2 * iPhone...*/
    SpotImageSizeFactorCornerLineThickness = 5,
    SpotImageSizeFactorCenterLineWidth = 8,
    SpotImageSizeFactorCenterLineThickness = 1,
    SpotImageSizeFactorCenterRadius = 4
}SpotImageSizeFactor;

NSString const *kMimeTypeAudio  = @"audio/aac";
NSString const *kMimeTypeImage  = @"image/png";

NSString const *kAudioPrefix    = @"audio";
NSString const *kImagePrefix    = @"image";

NSString const *kEmailSentResult   = @"Result";
NSString const *kEmailSentMessage  = @"Mail Sent Successfully";
NSString const *kOKButtonTitle     = @"OK";

NSInteger const kMailSuccess    = 1008;

@interface TattleControl ()<MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) UIButton *snapShotBtn;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic,strong) UIImage *spotImage;
@property (nonatomic,strong) UIColor *spotImageColor;
@property (nonatomic, strong) id presentedVC;
@property (nonatomic,strong) TPopupView *confirmationView;
@property (nonatomic, strong) NSMutableArray *emailRecipients, *eMailCCRecipients;
@property (nonatomic, strong) NSString *emailSubject;

@end

@implementation TattleControl

#pragma mark - Control Creation and Assign Frame

- (void)assignButtonWithFrame:(CGRect)frame
{
    self.frame = CGRectMake(100,200, frame.size.width, frame.size.height);
    self.snapShotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapShotBtn.frame = frame;
    [self.snapShotBtn addTarget:self action:@selector(snapButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.snapShotBtn];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panning:)];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - Tattle Shared Control

+(TattleControl*)sharedControl
{
    static dispatch_once_t predicate = 0;
    static TattleControl *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance assignButtonWithFrame:CGRectMake(0, 0,resizeDependsDevice(SquareButtonSize),resizeDependsDevice(SquareButtonSize))];
        sharedInstance.spotImageColor = DefaultSpotImageColor;
        sharedInstance.backgroundColor = [UIColor clearColor];
        sharedInstance.emailRecipients = [NSMutableArray array];
        sharedInstance.eMailCCRecipients = [NSMutableArray array];
    });
    return sharedInstance;
}

#pragma mark - Spot Button action.

-(void)snapButtonFired:(UIButton*)snapButton
{
    NSLog(@"Snap button Fired");
    [snapButton setHidden:YES];
    [self setNeedsDisplay];
    [[SnapShotView sharedView] assignBackgroundColorWithImage:[self getScreenShotImageWithOutStatusBar]];
    [self.window insertSubview:[[SnapShotView sharedView] getBaseView] aboveSubview:self];
    [[SnapShotView sharedView] addScribbleControllToSnapView];
    [self addPopUpAnimationToView:[SnapShotView sharedView] isPopIn:YES];
}

#pragma mark - Enable Screen shot Control to this Window

-(void)enableTattleToWindow:(UIWindow*)baseWindow
{
    self.window = baseWindow;    
    [baseWindow addSubview:self];
}

-(void)changeSpotImageColor:(UIColor*)spotColor
{
    self.spotImageColor = spotColor;
}

#pragma mark - Email Configuration

-(void)addRecipientMailId:(NSString*)recipientMailId
{
    if (recipientMailId)
        [self.emailRecipients addObject:recipientMailId];
}

-(void)addCCMailId:(NSString*)ccMailId
{
    if (ccMailId)
        [self.eMailCCRecipients addObject:ccMailId];
}

-(void)assignMailSubject:(NSString*)subject
{
    if (subject)
        self.emailSubject = subject;
}

-(void)assignRecipientEmailId:(NSString*)toEmailId withCCId:(NSString*)ccId emailSubject:(NSString*)subject
{
    [self addRecipientMailId:toEmailId];
    [self addCCMailId:ccId];
    [self assignMailSubject:subject];
}


#pragma mark - Change Scribble color

-(void)setScribbleColor:(UIColor*)scribbleColor
{
    [[SnapShotView sharedView] changeScribbleColor:scribbleColor];
}

#pragma mark - Set Movable Control Background Color

-(void)setMovableControlBackgroundColor:(UIColor*)backgroundColor
{
    [[SnapShotView sharedView] setMovableControlBackgroundColor:backgroundColor];
}

-(void)setMovableControlBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha
{
    [[SnapShotView sharedView] setMovableControlBackgroundColor:backgroundColor withAlpha:alpha];
}


#pragma mark - Panning Handle

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

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self.window];
    CGPoint finalTranslation = CGPointZero;
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateEnded)
    {
        if (CGPointEqualToPoint((finalTranslation =[self checkViewOutOfBounds:gesture.view withBaseView:self.window]),CGPointZero))
            return;
        else
            gesture.view.center = finalTranslation;
    }
    [gesture setTranslation:CGPointMake(0, 0) inView:self.window];
}

#pragma mark - Set Spot Image

-(void)setSpotButtonImage:(UIImage*)image
{
    self.spotImage = image;
    if (self.snapShotBtn)
        [self.snapShotBtn setBackgroundImage:self.spotImage forState:UIControlStateNormal];
}

#pragma mark - Spot Image drawing

-(void)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint forContext:(CGContextRef)context
{
    CGContextMoveToPoint(context, fromPoint.x,fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x,toPoint.y);
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.spotImage)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.spotImageColor.CGColor);
        
        //Left Corner
        CGContextSetLineWidth(context,resizeDependsDevice(SpotImageSizeFactorCornerLineThickness));
        [self drawLineFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, resizeDependsDevice(SpotImageSizeFactorCornerLineWidth)) forContext:context];
        [self drawLineFromPoint:CGPointMake(0,0) toPoint:CGPointMake(resizeDependsDevice(SpotImageSizeFactorCornerLineWidth), 0) forContext:context];
        //Right Corner
        [self drawLineFromPoint:CGPointMake(self.frame.size.width, 0) toPoint:CGPointMake(self.frame.size.width - resizeDependsDevice(SpotImageSizeFactorCornerLineWidth), 0) forContext:context];
        [self drawLineFromPoint:CGPointMake(self.frame.size.width,0) toPoint:CGPointMake(self.frame.size.width,resizeDependsDevice(SpotImageSizeFactorCornerLineWidth)) forContext:context];
        //Bottom Left corner
        [self drawLineFromPoint:CGPointMake(0, self.frame.size.height) toPoint:CGPointMake(0, self.frame.size.height -resizeDependsDevice(SpotImageSizeFactorCornerLineWidth)) forContext:context];
        [self drawLineFromPoint:CGPointMake(0, self.frame.size.height) toPoint:CGPointMake(resizeDependsDevice(SpotImageSizeFactorCornerLineWidth), self.frame.size.height) forContext:context];
        //Botto Right Corner
        [self drawLineFromPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width - resizeDependsDevice(SpotImageSizeFactorCornerLineWidth), self.frame.size.height) forContext:context];
        [self drawLineFromPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width,self.frame.size.height - resizeDependsDevice(SpotImageSizeFactorCornerLineWidth)) forContext:context];
        
        CGContextSetLineWidth(context, resizeDependsDevice(SpotImageSizeFactorCenterLineThickness));
        [self drawLineFromPoint:CGPointMake(self.frame.size.width/2, 0) toPoint:CGPointMake(self.frame.size.width/2, resizeDependsDevice(SpotImageSizeFactorCenterLineWidth)) forContext:context];
        [self drawLineFromPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width/2,self.frame.size.height-resizeDependsDevice(SpotImageSizeFactorCenterLineWidth)) forContext:context];
        [self drawLineFromPoint:CGPointMake(0, self.frame.size.height/2) toPoint:CGPointMake(resizeDependsDevice(SpotImageSizeFactorCenterLineWidth), self.frame.size.height/2) forContext:context];
        [self drawLineFromPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2) toPoint:CGPointMake(self.frame.size.width - resizeDependsDevice(SpotImageSizeFactorCenterLineWidth), self.frame.size.height/2) forContext:context];
        
        CGContextAddArc(context, self.frame.size.width/2,self.frame.size.height/2, resizeDependsDevice(SpotImageSizeFactorCenterRadius), 0, 360, 0);
        CGContextStrokePath(context);
        
        CGImageRef rawMask = CGBitmapContextCreateImage(context);
        self.spotImage = [UIImage imageWithCGImage:rawMask];
        if (self.snapShotBtn)
            [self.snapShotBtn setBackgroundImage:self.spotImage forState:UIControlStateNormal];
        CGImageRelease(rawMask);
    }
}

#pragma mark - Remove Snap View

-(void)removeSnapShotView
{
    [[SnapShotView sharedView] removeFromWindow];
}

#pragma mark - Animation Delegate - only for PopUp

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeSnapShotView];
    [self.snapShotBtn setHidden:NO];
}

#pragma mark - Popup & Popin animation

- (void) addPopUpAnimationToView:(UIView*)view isPopIn:(BOOL)popIn
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D scale1 = CATransform3DMakeScale(0.2, 0.2, 1);
    CATransform3D scale11 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale11],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.1],
                           [NSNumber numberWithFloat:0.2],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    animation.duration = 0.8;
    if (popIn)
    {
        [animation setValues:frameValues];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeForwards;
    }
    else
    {
        [animation setValues:[[frameValues reverseObjectEnumerator] allObjects]];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeRemoved;
        animation.delegate = self;
    }
    [view.layer addAnimation:animation forKey:@"popup"];
}

#pragma mark - Cancel Button Action

- (void) showConfirmationView {
    if (!self.confirmationView)
    {
        if (IS_IPAD)
            self.confirmationView = [[[NSBundle mainBundle] loadNibNamed:@"TPopupView" owner:nil options:nil] lastObject];
        else
            self.confirmationView = [[[NSBundle mainBundle] loadNibNamed:@"TPopupView" owner:nil options:nil] firstObject];
        __weak typeof(self) weakSelf = self;
        self.confirmationView.okActionBlock = ^{
            NSLog(@"Ok Button Tapped");
            [weakSelf.confirmationView removeFromSuperview];
            [weakSelf showWithAnimation];
        };
        self.confirmationView.cancelActionBlock = ^{
            NSLog(@"Cancel button Tapped");
            [weakSelf.confirmationView hideWithAnimation];
        };
    }
    [[[SnapShotView sharedView] getBaseView] addSubview:self.confirmationView];
    [self.confirmationView showWithAnimation];
}

-(void)showWithAnimation
{
    [self addPopUpAnimationToView:[SnapShotView sharedView] isPopIn:NO];
}

-(void)closeButtonFired:(UIButton*)closeBtn
{
    [self showConfirmationView];
}

#pragma mark - Getting Device scale

-(CGFloat)getScale
{
    CGFloat scale = 1.0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        scale = [[UIScreen mainScreen] scale];
    }
#endif

    return scale;
}

#pragma mark - Screen shot from view's layer

-(UIImage*)takeScreenShotImageForView:(UIView *)baseView
{
    return [self takeScreenShotImageForView:baseView withScale:1.0];
}

-(UIImage*)takeScreenShotImageForView:(UIView *)baseView withScale:(CGFloat)scale
{
    CGSize size = CGSizeMake(baseView.layer.frame.size.width*scale, baseView.layer.frame.size.height*scale);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0))
        [baseView drawViewHierarchyInRect:baseView.frame afterScreenUpdates:YES];
    else
        [baseView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return (!image) ? nil : image;
}

#pragma mark remove the status bar from screen shot image

-(UIImage *)getScreenShotImageWithOutStatusBar
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGFloat scale = [self getScale];
    UIImage *image = [self takeScreenShotImageForView:window withScale:scale];
    CGImageRef tmpImgRef    = image.CGImage;
    CGImageRef topImgRef    = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, (scale*20), image.size.width, image.size.height-(scale*20)));
    UIImage *topImage       = [UIImage imageWithCGImage:topImgRef];
    CGImageRelease(topImgRef);
    return topImage;
}

#pragma mark get PresentedView controller
-(UIViewController*)getVisibleViewControllerFrom:(UIViewController *) vc
{
    return ([vc presentedViewController]) ? [vc presentedViewController]: nil;
}

-(NSString*)getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSString *)getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

-(NSString *)getBuild
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

-(NSString*)getBundleIdentifier
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

-(NSString *)batteryStatusString
{
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    NSString *batteryStateString = nil;
    switch(device.batteryState)
    {
        case UIDeviceBatteryStateUnplugged: batteryStateString = @"Unplugged"; break;
        case UIDeviceBatteryStateCharging: batteryStateString = @"Charging"; break;
        case UIDeviceBatteryStateFull: batteryStateString = @"Full"; break;
        default: batteryStateString = @"Unknown"; break;
    }
    [device setBatteryMonitoringEnabled:NO];
    return batteryStateString;
}

-(int)getBatteryLevel
{
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    int batteryLevel = (int)([device batteryLevel]*100.0);
    [device setBatteryMonitoringEnabled:NO];
    return batteryLevel;
}

#pragma mark send screen shot
-(void)sendScreenShotAudioFiles
{
    if(![MFMailComposeViewController canSendMail])
        return;
    [self removeSnapShotView];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    [mailComposer setMailComposeDelegate:self];
    NSMutableString *systemInfo = [NSMutableString string];
    UIDevice *device = [UIDevice currentDevice];
    [systemInfo appendFormat:@"<html><body><table><tr><td colspan=2 bgcolor=#4F81BD><FONT color=white  SIZE=2> System info for %@ </FONT></td></tr><tr bgcolor=#D0D8E8><td>Build Version</td><td>%@(%@)</td></tr><tr bgcolor=#D0D8E8><td width=30 >Device Name</td><td width=170>%@</td></tr><tr bgcolor=#D0D8E8><td>Model</td><td>%@</td></tr><tr bgcolor=#D0D8E8><td>OS(version)</td><td>%@(%@)</td><tr bgcolor=#D0D8E8><td>Battery Level</td><td>%d%%(%@)</td></tr><tr bgcolor=#D0D8E8><td>Brightness</td><td>%d%%</td></tr></table></body></html>",[self getAppName],[self getBuild],[self getAppVersion],[device name],[self platformString],[device systemName],[device systemVersion],[self getBatteryLevel],[self batteryStatusString],(int)([[UIScreen mainScreen] brightness] *100.0)];
    [mailComposer setMessageBody:systemInfo isHTML:YES];
    //Attach audios
    NSInteger i = 0;
    NSArray *audios = [[TFileManager sharedFileManager] getRecordedAudios];
    for (NSString *path  in audios)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:(NSString*)kMimeTypeAudio fileName:[NSString stringWithFormat:@"%@%ld", kAudioPrefix, (long)i]];
    }
    //Set subject
    if(self.emailSubject)
        [mailComposer setSubject:self.emailSubject];
    //Set email recipients
    if(self.emailRecipients)
        [mailComposer setToRecipients:self.emailRecipients];
    //Set email cc recipients
    if(self.eMailCCRecipients)
        [mailComposer setCcRecipients:self.eMailCCRecipients];
    //Attach screen shots
    NSArray *screenShots = [[TFileManager sharedFileManager] getScreenShots];
    for (NSString *path  in screenShots)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:(NSString*)kMimeTypeImage fileName:[NSString stringWithFormat:@"%@%ld", kImagePrefix, (long)i]];
    }
    self.presentedVC = [self getVisibleViewControllerFrom:self.window.rootViewController];
    if(self.presentedVC)
    {
        //Hold already presented vc and present it once mailcomposer vc is dismissed
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
        }];
    }
    else
    {
        [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark dismiss mail composer vc and present the presented vc if the root vc already had presented vc
-(void)dismissMailVCAndPresentAlreadyPresnetedVC
{
    if(self.presentedVC)
    {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self.window.rootViewController presentViewController:self.presentedVC animated:NO completion:^{
                [self.snapShotBtn setHidden:NO];
                self.presentedVC = nil;
            }];
        }];
    }
    else
    {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            [self.snapShotBtn setHidden:NO];
        }];
    }
}

#pragma mark mail composer delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [self clearAudiosAndScreenShots];
            break;
            
        case MFMailComposeResultSaved:
            [self clearAudiosAndScreenShots];
            break;
        case MFMailComposeResultSent:
        {
            [self clearAudiosAndScreenShots];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:(NSString*)kEmailSentResult message:(NSString*)kEmailSentMessage delegate:self cancelButtonTitle:(NSString*)kOKButtonTitle otherButtonTitles:nil, nil];
            [alert setTag:kMailSuccess];
            [alert show];
            return;
        }
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            [self clearAudiosAndScreenShots];
            break;
    }
    [self dismissMailVCAndPresentAlreadyPresnetedVC];
}

#pragma mark clear audios and screen shots
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kMailSuccess)
    {
        [self dismissMailVCAndPresentAlreadyPresnetedVC];
    }
}

#pragma mark clear audios and screen shots
-(void)clearAudiosAndScreenShots
{
    [[TFileManager sharedFileManager] clearAllAudios];
    [[TFileManager sharedFileManager] clearAllScreenShots];
}

@end
