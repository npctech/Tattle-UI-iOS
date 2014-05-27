//
//  AppDelegate.m
//  Tattle-UI
//
//  Created by Mani on 5/26/14.
//  Copyright (c) 2014 Tattle. All rights reserved.
//

#import "AppDelegate.h"
#import "TattleControl.h"
#import "FirstVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[TattleControl sharedControl] enableTattleToWindow:self.window];
    
    [[TattleControl sharedControl] assignRecipientEmailId:@"yourmailid@domain.com" withCCId:@"yourmailid@domain.com" emailSubject:@"Bugs"];
    /* Optional Configuration
     
     //To Add Recipients for mail
     [[TattleControl sharedControl] addRecipientMailId:@"yourmailid@domain.com"];
     
     //To set CC for mail:
     [[TattleControl sharedControl] addCCMailId:@"yourmailid@domain.com"];
     
     //To set Subject for mail:
     [[TattleControl sharedControl] assignMailSubject:@"Bugs"];
     
     //Optionally change colors:
     //Change spot image color according to app theme, default is blue
     [[TattleControl sharedControl] changeSpotImageColor:YOUR_Color];
     
     //If you don't like spot image, you can also set your own image too.
     [[TattleControl sharedControl] setSpotButtonImage:YOUR_Image];
     
     //Change Scribble Color according to background, default is black
     [[TattleControl sharedControl] setScribbleColor:YOUR_Color];
     
     //Change background color of movable control. default is black(transparent)
     [[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color];
     [[TattleControl sharedControl] setMovableControlBackgroundColor:YOUR_Color withAlpha:alpha];
     
     */
    self.window.backgroundColor = [UIColor whiteColor];
    FirstVC *firstVC = [[FirstVC alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:firstVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
