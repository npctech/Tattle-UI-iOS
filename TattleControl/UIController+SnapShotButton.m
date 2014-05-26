//
//  UIController+SnapShotButton.m
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

#import "UIController+SnapShotButton.h"
#import "TattleControl.h"
#import <objc/runtime.h>

@implementation UIViewController (SnapShotButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(snapControlViewDidAppear:);
        SEL addSwizzledSelector = @selector(snapControllerViewDidAppearAdd:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method addSwizzledMethod = class_getInstanceMethod(class, addSwizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(addSwizzledMethod),
                        method_getTypeEncoding(addSwizzledMethod));
        if (!didAddMethod)
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling
-(void)snapControllerViewDidAppearAdd:(BOOL)animated
{
    [[TattleControl sharedControl] removeFromSuperview];
    [self.view.window insertSubview:[TattleControl sharedControl] aboveSubview:self.view];
}

- (void)snapControlViewDidAppear:(BOOL)animated {
    [self snapControlViewDidAppear:animated];
    [[TattleControl sharedControl] removeFromSuperview];
    [self.view.window insertSubview:[TattleControl sharedControl] aboveSubview:self.view];
}

@end

@implementation UIView (SnapShotButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(addSubview:);
        SEL swizzledSelector = @selector(snapControlViewAddSubview:);
        SEL addSwizzledSelector = @selector(snapControlViewAddSubviewAdd:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method addSwizzledMethod = class_getInstanceMethod(class, addSwizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(addSwizzledMethod),
                        method_getTypeEncoding(addSwizzledMethod));
        if (!didAddMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

-(void)snapControlViewAddSubviewAdd:(UIView*)animated
{
    if (self.window)
    {
        [[TattleControl sharedControl] removeFromSuperview];
        [self.window insertSubview:[TattleControl sharedControl] aboveSubview:self];
    }
}

- (void)snapControlViewAddSubview:(UIView*)animated {
    
    [self snapControlViewAddSubview:animated];
    if (self.window)
    {
        [[TattleControl sharedControl] removeFromSuperview];
        [self.window insertSubview:[TattleControl sharedControl] aboveSubview:self];
    }
}

@end
