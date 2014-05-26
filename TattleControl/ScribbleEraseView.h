//
//  ScribbleEraseView.h
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

@class Scribble;
/* Scribble Completion block called every scribble end*/
typedef void(^ScribbleCompletionBlock)();

/* Scribble delegate track scribbling state while we touch and drag.*/
@protocol ScribbleViewDelegate
@optional
-(void) scribbleDidStart;
-(void) scribbleDidEnd;

//Logging Activity
-(void) logEraseStart;
-(void) logScribbleStart;
-(void) logEraseEnd;
-(void) logScribbleEnd;

@end

@interface ScribbleEraseView : UIView

/* Width of the scribble, To default, see this constant TScribbleLineWidth*/
@property (nonatomic) float lineWidth, eraseWidth;
/* In future, we decide to provide erase control, this bool refer to erase or scribble */
@property (nonatomic) BOOL isEraseOn;
/* Storke color of scribble, default black color. Now we can change store color by [TattleControl setScribbleColor:...], We're also planning to provide dynamically change scribble color by providing extra control to movableEditorview. */
@property (nonatomic,strong) UIColor *currentScribbleStrokeColor;
/* Scribble delegate to show scribble state*/
@property (nonatomic, weak) id <ScribbleViewDelegate,NSObject> scribbleDelegate;
/* this block will get call when scribble end */
@property (nonatomic,strong) ScribbleCompletionBlock scribbleEndCompletion;

- (id)initWithFrame:(CGRect)frame;
/* This will reset view by clearing all scribbles*/
- (void)resetView;

/* Draw scribble path by using following method while touch happen with view, */
- (void) addTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) appendTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) endTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) cancelTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
-(void) outOfBounds:(CGPoint)point forTouch:(UITouch*)touch andEvent:(UIEvent*)event;

//Chagne scribble color , default black color
-(void) changeColorOfScribbleTo:(UIColor*)someColor;
@end
