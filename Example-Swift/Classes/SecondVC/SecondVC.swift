//
//  SecondVC.swift
//  ExampleProject
//
//  Created by Mani on 6/6/14.
//  Copyright (c) 2014 Tattle. All rights reserved.
//

import Foundation

class SecondVC : UIViewController
{
    @IBOutlet var secondButton : UIButton
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Second"
    }
    
    @IBAction func secondButtonFired (button : UIButton)
    {
        println("Third button Fired")
    }
}