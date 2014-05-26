//
//  TattleControl.h
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

#import <UIKit/UIKit.h>

@interface TattleControl : UIView

//Shared view has spot button, always in top of view hierarchy
+(TattleControl*)sharedControl;

/*Enable spot button to application window. This should start during app launch. Example code as below
 .....
 self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 [[TattleControl sharedControl] enableTattleToWindow:self.window];
 .......
 */
-(void)enableTattleToWindow:(UIWindow*)baseWindow;

//By Default, spot button image drawn by programmatically, So you can change color by this api.
//Default color: blue
-(void)changeSpotImageColor:(UIColor*)spotColor;

//Optional method. If you want to change spot image as your own, you can also do with that.
-(void)setSpotButtonImage:(UIImage*)image;

//Cancel all doing and close snap view
-(void)closeButtonFired:(UIButton*)closeBtn;

//Common Api to take snap shot for view
-(UIImage*)takeScreenShotImageForView:(UIView *)baseView;

//Send screen shot and audio via MFMailComposeViewController
-(void)sendScreenShotAudioFiles;

//Change Scribble Color according to background, default is black
-(void)setScribbleColor:(UIColor*)scribbleColor;

//Change background color of movable control. default is black(transparent)
-(void)setMovableControlBackgroundColor:(UIColor*)backgroundColor;
-(void)setMovableControlBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha;

//Email Configuration
-(void)addRecipientMailId:(NSString*)recipientMailId;
-(void)addCCMailId:(NSString*)ccMailId;
-(void)assignMailSubject:(NSString*)subject;
-(void)assignRecipientEmailId:(NSString*)toEmailId withCCId:(NSString*)ccId emailSubject:(NSString*)subject;

@end
