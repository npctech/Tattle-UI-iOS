# Tattle-UI-iOS
-----------------

# Why do you need Tattle-UI

As a developer, we struggle to understand and reproduce few UI
bugs reported by the beta-tester. In tester's point of view, tester
writes paragraphs to explain a simple UI misalignment when they test.

Tattle-UI solves this problem by providing simpler mechanism to get UI feedback
from beta-testers. 

# What do you see on your app

After integration, Tattle library adds a floating button on every screen. 
Tester can click on this button whenever he sees some issue with the UI.
Tattle library takes the snapshot of the current screen and allow the tester
to mark problematic section using scribbles. Tester may wish to add a audio note along with this. 
Tattle provides tester to send them in Email. 

# Integration steps

In two ways you can get Tattle-UI
1. From github 
a. Download the code from github and include the files into your project. 
b. Include following frameworks
- OpenGLES.framework
- QuartzCore.framework
- AVFoundation.framework
- CoreGraphics.framework
- MessageUI.framework
- ImageIO.framework  
2. From cocoapod
a. Add pod 'TattleUI' to your Podfile and run pod install

# Usage
1. Import "UIController+SnapShotButton.h" file into App-Prefix.pch file 

```
import "UIController+SnapShotButton.h"
```

2. Enable Tattle control by adding following line in "AppDelegate.m"

```
#import "ScreenShotControl.h"
```

3. Invoke 'enableTattleToWindow:' method, after main window creation.

```
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window];
```

# Tested OS version

Tattle UI has been tested in iPhone 6+ and iPad 

# Configuration


### Change scribble color (default black)

```
[[TattleControl sharedControl] setScribbleColor:YOUR_Color];
```

### Change background color of floating button

```
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color];
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color withAlpha:alpha];
```

### Set recipients email 
```
[[TattleControl sharedControl] assignRecipientEmailId:@"YOUR_EMAIL_HERE" withCCId:@"YOUR_EMAIL_HERE" emailSubject:@"UI Bug using Tattle UI"];
```

### Add more Recipient

```
[[TattleControl sharedControl] addRecipientMailId:@"YOUR_EMAIL_HERE"];
```

### Add more CC

```
[[TattleControl sharedControl] addCCMailId:@"YOUR_EMAIL_HERE"];
```


