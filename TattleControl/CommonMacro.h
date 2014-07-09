//
//  CommonMacro.h
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

#ifndef SpotIt_CommonMacro_h
#define SpotIt_CommonMacro_h

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define iOS7_0 @"7.0"

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define resizeDependsDevice(originalSize) (CGFloat)(IS_IPAD ? originalSize*2 : originalSize)

#ifndef __OPTIMIZE__
#define NSLog(fmt,...)  NSLog((@"%s [Line %d] " fmt),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#endif
