//
//  TLogControlMacro.h
//  Tattle-UI
//
//  Created by Justin Jia on 7/11/14.
//  Copyright (c) 2014 Tattle. All rights reserved.
//

#ifndef Tattle_UI_TLogControlMacro_h
#define Tattle_UI_TLogControlMacro_h

#ifndef __OPTIMIZE__
#define TLog(fmt,...)  NSLog((@"%s [Line %d] " fmt),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TLog(...) {}
#endif

#endif
