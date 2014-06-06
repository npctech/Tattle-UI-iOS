//
//  AppDelegate.swift
//  ExampleProject
//
//  Created by Mani on 6/5/14.
//  Copyright (c) 2014 Tattle. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        TattleControl.sharedControl().enableTattleToWindow(self.window)
        TattleControl.sharedControl().assignRecipientEmailId("yourMail@domain.com", withCCId: "yourMail@domain.com", emailSubject: "Bugs")
        var firstVC = FirstVC(nibName: "FirstVC", bundle: NSBundle.mainBundle())
        var nav = UINavigationController(rootViewController: firstVC)
        self.window!.rootViewController = nav;
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        return true
    }
}
