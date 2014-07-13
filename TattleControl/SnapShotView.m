//
//  SnapShotView.m
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

#import "SnapShotView.h"
#import "TattleControl.h"
#import "ScribbleEraseView.h"
#import "MovableEditorView.h"
#import "CommonMacro.h"
#import "UIImage+GiffAnimation.h"
#import "TLogControlMacro.h"

enum{
    eBorderEdgeInsetTop = 40,
    eBorderEdgeInsetBottom = 10,
    eBorderEdgeInsetLeftRight = 20
}BorderEdgeInset;

CGFloat const CloseButtonSize = 80;
CGFloat const TitleLabelOriginY = 20;
CGFloat const TitleLabelHeight = 20;

CGFloat const kBorderWidth = 0.0;
CGFloat const GifAnimationDuration = 3.4;

@interface SnapShotView ()

@property (nonatomic,strong) ScribbleEraseView *scribbleView;
@property (nonatomic,strong) UIColor *scribbleColor;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *noSelectionView;
@property (nonatomic, strong) UIImageView *screenShotImageView;

@end

@implementation SnapShotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Shared View & Close button

-(void)designBaseViewFrame
{
    self.layer.borderWidth = kBorderWidth;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.clipsToBounds = YES;
    self.baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, TitleLabelOriginY, self.baseView.frame.size.width, TitleLabelHeight)];
    titleLbl.text = @"Tattle-UI";
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.baseView addSubview:titleLbl];
}

-(void)addCloseButton
{
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize buttonSize = CGSizeMake(resizeDependsDevice(CloseButtonSize),resizeDependsDevice(TitleLabelHeight));
    self.closeBtn.frame = CGRectMake(self.baseView.frame.origin.x + self.baseView.frame.size.width - buttonSize.width -10, TitleLabelOriginY,buttonSize.width,buttonSize.height);
    [self.closeBtn addTarget:[TattleControl sharedControl] action:@selector(closeButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setBackgroundColor:[UIColor clearColor]];
    [self.closeBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    if (IS_IPAD)
        self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:22.0];
    else
        self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.closeBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [self.closeBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.closeBtn setNeedsDisplay];
    [self.baseView addSubview:self.closeBtn];
}

+(SnapShotView*)sharedView
{
    static dispatch_once_t predicate = 0;
    static SnapShotView *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [sharedInstance setFrame:[sharedInstance getSnapShotViewFrameFromSize:[sharedInstance getScreenShotSize]]];
        sharedInstance.screenShotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, sharedInstance.frame.size.width, sharedInstance.frame.size.height)];
        sharedInstance.screenShotImageView.contentMode = UIViewContentModeScaleAspectFit;
        [sharedInstance addSubview:sharedInstance.screenShotImageView];
        [sharedInstance.baseView addSubview:sharedInstance];
        [sharedInstance designBaseViewFrame];
        [sharedInstance addCloseButton];

    });
    return sharedInstance;
}

#pragma mark - Screen Sizes

-(CGSize)getScreenShotSize
{
    CGFloat width  = [[UIScreen mainScreen]bounds].size.width;
    CGFloat height = [[UIScreen mainScreen]bounds].size.height - eBorderEdgeInsetTop;
    return CGSizeMake(width, height);
}

-(CGRect)getSnapShotViewFrameFromSize:(CGSize)size
{
    CGFloat aspectRatio = size.height/size.width;
    CGFloat height      = size.height - eBorderEdgeInsetBottom;
    CGFloat width       = height/aspectRatio;
    CGFloat border = size.width - width;
    CGFloat x = border/2;
    return CGRectMake(x, eBorderEdgeInsetTop, width, height);
}

-(BOOL)isScribbleViewCreated
{
    if (!self.scribbleView)
    {
        self.scribbleView = [[ScribbleEraseView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scribbleView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        self.scribbleView.scribbleEndCompletion = ^{
            [weakSelf addMovableControlToSnapView];
        };
    }
    return YES;
}

#pragma mark - Background View

-(UIView*)getBaseView
{
    return self.baseView;
}

#pragma mark - Close Button Handle - Front & Back

-(void)getCloseButtonToFront
{
    [self bringSubviewToFront:self.closeBtn];
}

#pragma mark - Giff image Setting

-(BOOL)isControlPresentFirstTime
{
    NSNumber *isFirst = [[NSUserDefaults standardUserDefaults]
                            objectForKey:@"IsFirstTimeToGif"];
    return (isFirst) ? NO : YES;
}

#pragma mark - Giff Animation for demo

-(void)gifAnimationEnd:(UIImageView*)imageView
{
    [imageView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults]
                            setObject:[NSNumber numberWithBool:YES] forKey:@"IsFirstTimeToGif"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self addScribbleView];
}

-(void)animateDemoGiff
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , 320, 320)];
    imageview.center = CGPointMake(baseView.frame.size.width/2, baseView.frame.size.height/2);
    [baseView addSubview:imageview];
    [self addSubview:baseView];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gif_3D" withExtension:@"gif"];
    imageview.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [self performSelector:@selector(gifAnimationEnd:) withObject:baseView afterDelay:GifAnimationDuration];
}

#pragma mark - Add scribble view

-(void)addScribbleView
{
    if (![self isScribbleViewCreated])
        return;
    [self.scribbleView changeColorOfScribbleTo:self.scribbleColor];
    self.scribbleView.userInteractionEnabled = YES;
    self.scribbleView.isEraseOn = NO;
    [self addSubview:self.scribbleView];
    [self getCloseButtonToFront];
    [self setNeedsDisplay];
}

-(void)changeScribbleColor:(UIColor*)scribbleColor
{
    if (self.scribbleView)
    {
        [self.scribbleView changeColorOfScribbleTo:scribbleColor];
    }
    self.scribbleColor = scribbleColor;
}

-(void)addScribbleControllToSnapView
{
    if ([self isControlPresentFirstTime])
    {
        [self animateDemoGiff];
        return;
    }
    [self addScribbleView];
}

#pragma mark - Remove Scribble view

-(void)removeScribbleControllFromSnapView
{
    [self.scribbleView removeFromSuperview];
}

-(CGFloat)getScale
{
    CGFloat scale = 1.0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        scale = [[UIScreen mainScreen] scale];
    }
#endif
    TLog(@"Screen scale %f", scale);
    return scale;
}

-(void)assignBackgroundColorWithImage:(UIImage*)fillingImage
{
    CGFloat scale = [self getScale];
    CGSize size = CGSizeMake(self.frame.size.width * scale, self.frame.size.height * scale);
    UIImage *resizedImage = [self imageWithImage:fillingImage scaledToSize:size];
    [self.screenShotImageView setImage:resizedImage];
    [[MovableEditorView sharedView] resetRecordingControl];
}

#pragma mark - Change movable background color 

-(void)setMovableControlBackgroundColor:(UIColor*)backgroundColor
{
    [[MovableEditorView sharedView] assignBackgroundColor:backgroundColor];
}

-(void)setMovableControlBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha
{
    [[MovableEditorView sharedView] assignBackgroundColor:backgroundColor withAlpha:alpha];
}

#pragma mark add no selection view
-(UIView*)noSelectionView
{
    if(!_noSelectionView)
    {
        _noSelectionView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        [_noSelectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _noSelectionView;
}

-(void)getNoSelectionViewToFront
{
    [self.noSelectionView removeFromSuperview];
    [self addNoSelectionView];
}

-(void)sendNoSelectionViewToBack
{
    [self sendSubviewToBack:self.noSelectionView];
}

-(void)addNoSelectionView
{
    [self insertSubview:self.noSelectionView belowSubview:[MovableEditorView sharedView]];
    [self getCloseButtonToFront];
}

#pragma mark - Movable Control Actions
-(void)addMovableControlToSnapView
{
    [self removeMovableControlFromSnapView];
    [self addSubview:[MovableEditorView sharedView]];
}

-(void)removeMovableControlFromSnapView
{
    [[MovableEditorView sharedView] removeFromSuperview];
}

#pragma mark - Remove Snap View from window
-(void)removeFromWindow
{
    [self.baseView removeFromSuperview];
    [self.scribbleView resetView];
    [self removeMovableControlFromSnapView];
}

#pragma mark - Assign Image to snap button

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
