//
//  Scribble.m
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

#import "Scribble.h"
#import "ScribblePathPoint.h"

@interface Scribble ()

@property (nonatomic) CGPoint currentPoint,previousPoint1,previousPoint2;
@property  BOOL isEmpty;
@property (nonatomic) CGMutablePathRef path;

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation Scribble

#pragma mark - Scribble Initilization 

- (id)init
{
    self = [super init];
    if (self)
    {
        self.points = [[NSMutableArray alloc] init];
        self.strokeColor = [UIColor blackColor] ;
        self.isEraseOn = NO;
        self.path = CGPathCreateMutable();
        self.isEmpty = YES;
    }
    return self;
}

#pragma mark - Scribble points

CGPoint getMidPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (NSMutableArray*)getPoints
{
    return self.points;
}

#pragma mark - Add point to scribble

-(CGRect)updatePointToPath:(CGPoint)point
{
    self.isEmpty = NO;
    if (self.points.count == 1) {
        self.previousPoint2 = self.previousPoint1 = self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    else if(self.points.count == 2){
        self.previousPoint2 = self.previousPoint1 =[self getPointAtIndex:self.points.count - 2];
        self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    else if(self.points.count > 2){
        self.previousPoint2 = [self getPointAtIndex:self.points.count - 3];
        self.previousPoint1 = [self getPointAtIndex:self.points.count - 2];
        self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    
    CGPoint mid1 = getMidPoint(self.previousPoint1, self.previousPoint2);
    CGPoint mid2 = getMidPoint(self.currentPoint,self.previousPoint1);
	CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
	CGPathAddPath(self.path, NULL, subpath);
	CGPathRelease(subpath);
    CGRect drawBox = bounds;
    drawBox.origin.x -= self.lineWidth * 2.0;
    drawBox.origin.y -= self.lineWidth * 2.0;
    drawBox.size.width += self.lineWidth * 4.0;
    drawBox.size.height += self.lineWidth * 4.0;
    return drawBox;
}

- (CGRect)addPoint:(CGPoint)point
{
    ScribblePathPoint *newPoint = [[ScribblePathPoint alloc] init];
    newPoint.point=point;
    [self.points addObject:newPoint];
    return [self updatePointToPath:point];
}

#pragma mark - Get point At touch Index

- (CGPoint) getPointAtIndex:(NSUInteger)index
{
	CGPoint thePoint=CGPointZero;
	@try {
        ScribblePathPoint *point = [self.points objectAtIndex:index];
        thePoint = point.point;
	}
	@catch (NSException * e) {
        @throw e;
	}
	return thePoint;
}

#pragma mark - Scribble Path

- (CGMutablePathRef)drawingPath{
    if (self.isEmpty || !self.path) {
        self.path = CGPathCreateMutable();
        self.isEmpty = NO;
        [self recalculatePath];
    }
    return self.path;
}

#pragma mark - Recalcualte Path

- (void) recalculatePath{
    for (int i = 0; i < self.points.count; i++) {
        if (i == 0) {
            self.previousPoint2 = self.previousPoint1 = self.currentPoint = [self getPointAtIndex:i];
        }
        else if(i == 1){
            self.previousPoint2 = self.previousPoint1 = [self getPointAtIndex:i - 1];
            self.currentPoint = [self getPointAtIndex:i];
        }
        else if(i >= 2){
            self.previousPoint2 = [self getPointAtIndex:i - 2];
            self.previousPoint1 = [self getPointAtIndex:i - 1];
            self.currentPoint = [self getPointAtIndex:i];
        }
        CGPoint mid1 = getMidPoint(self.previousPoint1, self.previousPoint2);
        CGPoint mid2 = getMidPoint(self.currentPoint, self.previousPoint1);
        CGMutablePathRef subpath = CGPathCreateMutable();
        CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(subpath, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
        CGPathAddPath(self.path, NULL, subpath);
        CGPathRelease(subpath);
    }
}

#pragma mark - Getting top most point of scribble

- (CGRect) enclosingRect {
    return CGPathGetBoundingBox(self.path);
}

- (CGPoint)topMostPoint{
    return [self enclosingRect].origin;
}

@end
