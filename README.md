# Tattle-UI-iOS
-----------------

## Why do you need Tattle-UI

As a developer, we struggle to understand and reproduce few UI
bugs reported by the tester. In tester's point of view, tester
writes paragraphs to explain a simple UI misalignment when they test.

Tattle-UI solves this problem by providing a simple mechanism to get UI feedback
from testers. 

## What do you see on your app

After integration, Tattle-UI library adds a floating button on every screen. 
Tester can click on this button whenever he sees some issue with the UI.
Tattle-UI library takes the snapshot of the current screen and allow the tester
to mark problematic section using scribbles. Tester may wish to add a audio note along with this. 
Tattle-UI provides tester to send them in Email. We use [anypic app](https://github.com/ParsePlatform/Anypic) to demo this control.

[![](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/Thumbnail/ShotImage.png)](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/ShotImage.png)
[![](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/Thumbnail/Scribble.png)](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/Scribble.png)
[![](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/Thumbnail/AudioRecordPlay.png)](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/AudioRecordPlay.png)
[![](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/Thumbnail/ShareViaMail.png)](https://raw.githubusercontent.com/npctech/Tattle-UI-iOS/master/Screenshot/ShareViaMail.png)

# Integration steps

## [Objective-C](https://github.com/npctech/Tattle-UI-iOS/tree/master/Example)

### From github 
* Download the code from github and include the files into your project. 
* Include following frameworks
```ruby
 OpenGLES.framework
 QuartzCore.framework
 AVFoundation.framework
 CoreGraphics.framework
 MessageUI.framework
 ImageIO.framework  
```
* Import "UIController+SnapShotButton.h" file into App-Prefix.pch file. `#import "UIController+SnapShotButton.h"`
* Enable Tattle-UI control by adding below line in "AppDelegate.m". `#import "TattleControl.h"`
* Invoke `enableTattleToWindow:` method, after main window creation.
```ruby
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window]; 
```

### From Cocoapods
* Podfile 
```ruby
platform :ios, '6.0'
pod 'Tattle-UI-iOS', '~> 1.0.1'
```
* Enable Tattle-UI control by adding below line in "AppDelegate.m". `#import "TattleControl.h"`
* Invoke `enableTattleToWindow:` method, after main window creation.
```ruby
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window];
```

## [Swift](https://github.com/npctech/Tattle-UI-iOS/tree/master/Example-Swift)

### From github
* Download the code from github and include the files into your project.
* Include following header files into `AppModule-Bridging-Header.h`
```ruby
#import "MovableEditorView.h"
#import "Scribble.h"
#import "ScribbleEraseView.h"
#import "ScribblePathPoint.h"
#import "CommonMacro.h"
#import "ScribCapControl.h"
#import "SnapShotView.h"
#import "TattleControl.h"
#import "TAudioManager.h"
#import "TConstants.h"
#import "TFileManager.h"
#import "TPopupView.h"
#import "UIController+SnapShotButton.h"
#import "UIImage+GiffAnimation.h"
```
* Invoke `enableTattleToWindow:` method, after main window creation.
```ruby
self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
TattleControl.sharedControl().enableTattleToWindow(self.window)
```

### From Cocoapods
* Podfile 
```ruby
platform :ios, '6.0'
pod 'Tattle-UI-iOS', '~> 1.0.1'
```
* Include following header files into `AppModule-Bridging-Header.h`
```ruby
#import "MovableEditorView.h"
#import "Scribble.h"
#import "ScribbleEraseView.h"
#import "ScribblePathPoint.h"
#import "CommonMacro.h"
#import "ScribCapControl.h"
#import "SnapShotView.h"
#import "TattleControl.h"
#import "TAudioManager.h"
#import "TConstants.h"
#import "TFileManager.h"
#import "TPopupView.h"
#import "UIController+SnapShotButton.h"
#import "UIImage+GiffAnimation.h"
```
* Invoke `enableTattleToWindow:` method, after main window creation.
```ruby
self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
TattleControl.sharedControl().enableTattleToWindow(self.window)
```

**Note:**
* [CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries, [Getting started here](http://guides.cocoapods.org/using/getting-started.html)

* Read [Importing Objective-C into Swift](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-XID_75) topic for swift migration.

## Requirement

* Minimum ios target : iOS 6
* Minimum xcode : Xcode 5.0
* All IOS devices.
* Only compatible with ARC.

## Limitation

- Only supported for **portrait** orientation. 
- Audio recording supports only **2 minutes**.

# Optional Configuration

## Objective-C

* **Change scribble color (default black)**
```ruby
[[TattleControl sharedControl] setScribbleColor:YOUR_Color];
```
* **Change color of floating button**
```ruby
[[TattleControl sharedControl] changeSpotImageColor:YOUR_Color];
```

We could also insert our own image too instead spot icon.
```ruby
[[TattleControl sharedControl] setSpotButtonImage:YOUR_Image];
```
* **Change background color of floating control**
```ruby
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color];
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color withAlpha:alpha];
```
* **Set recipients email** 
```ruby
[[TattleControl sharedControl] assignRecipientEmailId:@"YOUR_EMAIL_HERE" withCCId:@"YOUR_EMAIL_HERE" emailSubject:@"UI Bug using Tattle UI"];
```
* **Add more Recipient**
```ruby
[[TattleControl sharedControl] addRecipientMailId:@"YOUR_EMAIL_HERE"];
```
* **Add more CC**
```ruby
[[TattleControl sharedControl] addCCMailId:@"YOUR_EMAIL_HERE"];
```

## Swift
* **Change scribble color (default black)**
```ruby
TattleControl.sharedControl().setScribbleColor(YOUR_Color)
```

* **Change color of floating button**
```ruby
TattleControl.sharedControl().changeSpotImageColor(YOUR_Color)
```

We could also insert our own image too instead spot icon.
```ruby
TattleControl.sharedControl().setSpotButtonImage(YOUR_Image)
```

* **Change background color of floating control**
```ruby
TattleControl.sharedControl().setMovableControlBackgroundColor(YOUR_Color)
TattleControl.sharedControl().setMovableControlBackgroundColor(YOUR_Color, withAlpha: alpha)
```

* **Set recipients email** 
```ruby
TattleControl.sharedControl().assignRecipientEmailId("YOUR_EMAIL_HERE", withCCId: "YOUR_EMAIL_HERE", emailSubject: "Bugs")
```

* **Add more Recipient**
```ruby
TattleControl.sharedControl().addRecipientMailId("YOUR_EMAIL_HERE")
```

* **Add more CC**
```ruby
TattleControl.sharedControl().addCCMailId("YOUR_EMAIL_HERE")
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 
