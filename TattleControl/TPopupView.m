//
//  PopupView.m
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

#import "TPopupView.h"
#import "CommonMacro.h"

@interface TPopupView ()

@property (nonatomic,weak) IBOutlet UILabel *message;
@property (nonatomic,weak) IBOutlet UIButton *okButton,*cancelButton;
@property (nonatomic,weak) IBOutlet UIView *baseVeiw;

@end

@implementation TPopupView

#pragma mark - View Initilization

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.baseVeiw.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Confiramtion button action

-(IBAction)okButtonFired:(id)sender
{
    if (self.okActionBlock)
        self.okActionBlock();
}

-(IBAction)cancelButtonFired:(id)sender
{
    if (self.cancelActionBlock)
        self.cancelActionBlock();
}

#pragma mark - Animation Delegate - only for PopUp

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeFromSuperview];
    [self.layer removeAnimationForKey:@"SlideAnimationUp"];
}

#pragma mark - Hide View With Animation

-(void)hideWithAnimation
{
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    alphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    alphaAnimation.toValue = [NSNumber numberWithFloat:0.0];
    alphaAnimation.duration = 0.4f;
    alphaAnimation.delegate = self;
    [self.layer addAnimation: alphaAnimation forKey: @"fade"];
    CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    slideAnimation.fromValue =[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2,self.frame.size.height/2)];
    slideAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-self.baseVeiw.frame.size.height)];
    slideAnimation.duration = 0.4f;
    slideAnimation.fillMode = kCAFillModeForwards;
    slideAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:slideAnimation forKey:@"SlideAnimationUp"];
}

#pragma mark - Show View with Animation

-(void)showWithAnimation
{
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    alphaAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    alphaAnimation.toValue = [NSNumber numberWithFloat:1.0];
    alphaAnimation.duration = 0.4f;
    [self.layer addAnimation: alphaAnimation forKey: @"fade"];
    CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    slideAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-self.baseVeiw.frame.size.height)];
    slideAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2,self.frame.size.height/2)];
    slideAnimation.duration = 0.4f;
    [self.layer addAnimation:slideAnimation forKey:@"SlideAnimationDown"];
}

@end
