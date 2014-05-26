//
//  ScribCapControl.m
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

#import "ScribCapControl.h"

@interface ScribCapControl ()

@end

@implementation ScribCapControl

#pragma mark - Shared Control

+(ScribCapControl*)sharedControl
{
    static dispatch_once_t predicate = 0;
    static ScribCapControl *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
#pragma mark - Pass touch event to View

-(void)sendEvent:(UIEvent*)event withTouch:(UITouch*)touch
{
    NSSet *touches = [event allTouches];
    for (UITouch *aTouch in touches) {
        if ((UITouchPhaseBegan == aTouch.phase) || (UITouchPhaseEnded == aTouch.phase)) {
            break;
        }
    }
	if (!self.scribTarget || !self.controller)
        return ;
	for (UITouch *touch in touches) {
        if (UITouchPhaseBegan == touch.phase) {
            CGPoint pt = [touch locationInView:self.scribTarget];
            if (CGRectContainsPoint([self.scribTarget bounds], pt)) {
                [self.controller didPassOnTouch:touch withEvent:event];
            }
        } else {
            [self.controller didPassOnTouch:touch withEvent:event];
        }
	}
}

#pragma mark - Handle Touch with Event

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return NO;
    [self sendEvent:event withTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return NO;
    [self sendEvent:event withTouch:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return ;
    [self sendEvent:event withTouch:touch];
}

@end
