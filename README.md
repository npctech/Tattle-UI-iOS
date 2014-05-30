# Tattle-UI-iOS
-----------------

## Why do you need Tattle-UI

As a developer, we struggle to understand and reproduce few UI
bugs reported by the beta-tester. In tester's point of view, tester
writes paragraphs to explain a simple UI misalignment when they test.

Tattle-UI solves this problem by providing simpler mechanism to get UI feedback
from beta-testers. 

## What do you see on your app

After integration, Tattle library adds a floating button on every screen. 
Tester can click on this button whenever he sees some issue with the UI.
Tattle library takes the snapshot of the current screen and allow the tester
to mark problematic section using scribbles. Tester may wish to add a audio note along with this. 
Tattle provides tester to send them in Email. We use [anypic app](https://github.com/ParsePlatform/Anypic) to demo this control.

[![](http://imagizer.imageshack.us/v2/640x480q90/841/95fa.png)](http://imageshack.com/a/img841/7874/95fa.png)
[![](http://imagizer.imageshack.us/v2/640x480q90/834/iq33.png)](http://imageshack.com/a/img834/3107/iq33.png)
[![](http://imagizer.imageshack.us/v2/640x480q90/844/xtci.png)](http://imageshack.com/a/img844/915/xtci.png)
[![](http://imagizer.imageshack.us/v2/640x480q90/836/9kqe.png)](http://imageshack.com/a/img836/9691/9kqe.png)

# Integration steps

## From github 
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
* Enable Tattle control by adding below line in "AppDelegate.m".`#import "TattleControl.h"`
* Invoke 'enableTattleToWindow:' method, after main window creation.
```ruby
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window]; 
```
## From Cocoapods

* Podfile 
```ruby
platform :ios, '6.0'
pod 'Tattle-UI-iOS', '~> 1.0.1'
```
* Enable Tattle control by adding below line in "AppDelegate.m".
`#import "TattleControl.h"`
* Invoke 'enableTattleToWindow:' method, after main window creation.
```ruby
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window]; 
```
**Note:** [CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries, [Getting started here](http://guides.cocoapods.org/using/getting-started.html)

## Requirment 

* Minimum ios target : iOS 6
* Minimum xcode : Xcode 5.0
* All IOS devices.
* Only compatible with ARC.

## Limitation

- Only supported for **portrait** orientation. 
- Audio recording supports only **2 minutes**.

# Optional Configuration

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

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 
