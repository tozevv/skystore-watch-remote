//
//  ViewController.swift
//  Watch Remote
//
//  Created by Vieira, Antonio (Technology) on 31/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func leftClick(sender: AnyObject)
    {
        let button = sender as! UIButton
        let label = button.titleLabel!
        
        RokuRemote.Current().sendCommand(label.text!)
    }
}

