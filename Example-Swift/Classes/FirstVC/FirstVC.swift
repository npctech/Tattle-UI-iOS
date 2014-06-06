//
//  FirstVC.swift
//  ExampleProject
//
//  Created by Mani on 6/6/14.
//  Copyright (c) 2014 Tattle. All rights reserved.
//

import Foundation

class FirstVC : UIViewController
{
    @IBOutlet var firstButton : UIButton
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "First"
    }
    
    @IBAction func firstButtonClicked (button : UIButton)
    {
        println("Second screen button clicked")
        var secondVc = SecondVC(nibName: "SecondVC", bundle: NSBundle.mainBundle())
        self.navigationController.pushViewController(secondVc, animated: true)
    }
}