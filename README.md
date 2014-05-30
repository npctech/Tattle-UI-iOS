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
Tattle provides tester to send them in Email. 

<p align="center" >
  <img src="http://imageshack.com/a/img845/1851/2z5.gif" alt="Tattle-UI" title="Tattle-UI">
</p>


# Integration steps

In two ways you can get Tattle-UI

## From github 
1. Download the code from github and include the files into your project. 
2. Include following frameworks
```
 OpenGLES.framework
 QuartzCore.framework
 AVFoundation.framework
 CoreGraphics.framework
 MessageUI.framework
 ImageIO.framework  
```

## Usage

1. Import "UIController+SnapShotButton.h" file into App-Prefix.pch file. `#import "UIController+SnapShotButton.h"`
2. Enable Tattle control by adding below line in "AppDelegate.m".
`#import "TattleControl.h"`
3. Invoke 'enableTattleToWindow:' method, after main window creation.

```
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
[[TattleControl sharedControl] enableTattleToWindow:self.window]; 
```
## Installation with Cocoapods.

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries, [Getting started here](http://guides.cocoapods.org/using/getting-started.html)

## Podfile

```ruby
platform :ios, '6.0'
pod 'Tattle-UI-iOS', '~> 1.0.1'
```
After pod get install, follow **usage** step from #2

## Requirment 

* Minimum ios target : iOS 6
* Minimum xcode : Xcode 5.0
* All IOS devices.
* Only compatible with ARC.

## Limitation

- Only supported for **portrait** orientation. 

# Optional Configuration

* **Change scribble color (default black)**
```
[[TattleControl sharedControl] setScribbleColor:YOUR_Color];
```
* **Change color of floating button**
```
[[TattleControl sharedControl] changeSpotImageColor:YOUR_Color];
```
We could also insert our own image too instead spot icon.
```
[[TattleControl sharedControl] setSpotButtonImage:YOUR_Image];
```

* **Change background color of floating control**
```
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color];
[[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color withAlpha:alpha];
```

* **Set recipients email** 
```
[[TattleControl sharedControl] assignRecipientEmailId:@"YOUR_EMAIL_HERE" withCCId:@"YOUR_EMAIL_HERE" emailSubject:@"UI Bug using Tattle UI"];
```

* **Add more Recipient**
```
[[TattleControl sharedControl] addRecipientMailId:@"YOUR_EMAIL_HERE"];
```

* **Add more CC**
```
[[TattleControl sharedControl] addCCMailId:@"YOUR_EMAIL_HERE"];
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 
