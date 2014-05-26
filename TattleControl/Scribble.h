//
//  Scribble.h
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

@interface Scribble : NSObject

/* Storke color of scribble, default black color. Now we can change store color by [TattleControl setScribbleColor:...], We're also planning to provide dynamically change scribble color by providing extra control to movableEditorview. */
@property (nonatomic,strong) UIColor* strokeColor;
/* Width of the scribble, To default, see this constant TScribbleLineWidth*/
@property (assign) float lineWidth;
/* In future, we decide to provide erase control, this bool refer to erase or scribble */
@property (assign) BOOL isEraseOn;
/* The end point of the scribble, top most point of the end point*/
@property (readonly) CGPoint topMostPoint;

//Return path of this scribble
-(CGMutablePathRef)drawingPath;
//Add point to current drawing path
- (CGRect) addPoint:(CGPoint)point;
//To find corresponding point at index
- (CGPoint) getPointAtIndex:(NSUInteger)index;

//Get all points for current scribble.
- (NSMutableArray*)getPoints;

@end
