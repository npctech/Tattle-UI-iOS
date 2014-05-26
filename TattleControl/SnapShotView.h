//
//  SnapShotView.h
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

@interface SnapShotView : UIView

//Snapshot view has screen shot image, all changes will be done on this view
+(SnapShotView*)sharedView;

//Transparent background view show title, cancel option;.
-(UIView*)getBaseView;
//Close snap shot view
-(void)removeFromWindow;
//Assign snap shot image to this view
-(void)assignBackgroundColorWithImage:(UIImage*)image;

//Using this following function, user can change background color of movable control, default, black color with 0.4 alpha
-(void)setMovableControlBackgroundColor:(UIColor*)backgroundColor;
-(void)setMovableControlBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha;

//Add scribble view to snap shot view.
-(void)addScribbleControllToSnapView;
//Remove scribble view from snap shot view.
-(void)removeScribbleControllFromSnapView;
//Change scribble color
-(void)changeScribbleColor:(UIColor*)scribbleColor;

//NoSelection view is enable while either playing audio or recording audio. It will disable all other control
-(void)addNoSelectionView;
//Get NoSelection view to front to disable all other control
-(void)getNoSelectionViewToFront;
//Send NoSelectionView to back to enable all other control.
-(void)sendNoSelectionViewToBack;
//Add movable control to snapshot view when first scribble ended.
-(void)addMovableControlToSnapView;

@end
