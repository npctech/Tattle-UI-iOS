//
//  UIImage+GiffAnimation.m
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
/* Credits goes to Rob(https://github.com/mayoff/uiimage-from-animated-gif/) */

#import "UIImage+GiffAnimation.h"
#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif

@interface GifHelperMethods : NSObject

+(UIImage *)animatedImageWithAnimatedGIFReleasingImageSource:(CGImageSourceRef CF_RELEASES_ARGUMENT)source;
+(UIImage *)animatedImageWithAnimatedGIFImageSource:(CGImageSourceRef )source;
+(int)delayCentisecondsForImage:(CGImageSourceRef ) source atIndex:(size_t)i;

@end

@implementation GifHelperMethods

+(UIImage *)animatedImageWithAnimatedGIFReleasingImageSource:(CGImageSourceRef CF_RELEASES_ARGUMENT)source
{
    if (source) {
        UIImage *image =[GifHelperMethods animatedImageWithAnimatedGIFImageSource:source];
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}
+(int)delayCentisecondsForImage:(CGImageSourceRef ) source atIndex:(size_t)i
{
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties) {
            NSNumber *number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (number == NULL || [number doubleValue] == 0) {
                number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            if ([number doubleValue] > 0) {
                // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                delayCentiseconds = (int)lrint([number doubleValue] * 100);
            }
        }
        CFRelease(properties);
    }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = [GifHelperMethods delayCentisecondsForImage:source atIndex:i];
    }
}

+(int)sum:(size_t)count values:(int *)values
{
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

int pairGCD(int a, int b) {
    if (a < b)
        return pairGCD(b, a);
    while (true) {
        int r = a % b;
        if (r == 0)
            return b;
        a = b;
        b = r;
    }
}

int vectorGCD(size_t count, int const *const values) {
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        gcd = pairGCD(values[i], gcd);
    }
    return gcd;
}

NSArray *frameArray(size_t  count, CGImageRef const images[count], int const delayCentiseconds[count], int  totalDurationCentiseconds) {
    int gcd = vectorGCD(count, delayCentiseconds);
    size_t frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

+(void)releaseImages:(CGImageRef*)images count:(size_t)count
{
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}

+(UIImage *)animatedImageWithAnimatedGIFImageSource:(CGImageSourceRef )source {
    size_t count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int totalDurationCentiseconds = [GifHelperMethods sum:count values:delayCentiseconds];
    NSArray *frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    [GifHelperMethods releaseImages:images count:count];
    return animation;
}

@end

@implementation UIImage (animatedGIF)

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return [GifHelperMethods animatedImageWithAnimatedGIFReleasingImageSource:CGImageSourceCreateWithURL(toCF url, NULL)];
}

@end
