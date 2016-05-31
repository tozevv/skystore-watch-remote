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
    
    @IBOutlet weak var thresholdSlider: UISlider!
    @IBOutlet weak var samplesSlider: UISlider!
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var samplesLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func viewDidLoad() {
        self.thresholdSlider.minimumValue = 0
        self.thresholdSlider.maximumValue = 1
        self.thresholdSlider.value = Float(Configs.treshold)
        self.thresholdLabel.text = String(Configs.treshold)
            
        self.samplesSlider.minimumValue = 0
        self.samplesSlider.maximumValue = 50
        self.samplesSlider.value = Float(Configs.samples)
        self.samplesLabel.text = String(Configs.samples)
        
        self.stepsSlider.minimumValue = 0
        self.stepsSlider.maximumValue = 100
        self.stepsSlider.value = Float(Configs.steps)
        self.stepsLabel.text = String(Configs.steps)
        
        
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
    
    
    @IBAction func thresholdChanged(sender: AnyObject) {
        Configs.treshold = Double(thresholdSlider.value)
        self.thresholdLabel.text = String(Configs.treshold)
    }
    
    @IBAction func samplesChanged(sender: AnyObject) {
        Configs.samples = Int(samplesSlider.value)
        self.samplesLabel.text = String(Configs.samples)
    }
    
    @IBAction func stepsChanged(sender: AnyObject) {
        Configs.steps = Int(stepsSlider.value)
        self.stepsLabel.text = String(Configs.steps)
    }
}

