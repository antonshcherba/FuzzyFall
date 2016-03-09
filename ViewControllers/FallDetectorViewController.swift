//
//  FallDetectorViewController.swift
//  Motions
//
//  Created by Admin on 07/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit
//import CoreMotion
import AVFoundation
import CoreTelephony
import Pods_Motions
import MessageUI

let animationImages = ["parts_loading_01", "parts_loading_02",
    "parts_loading_03", "parts_loading_04",
    "parts_loading_05", "parts_loading_06",
    "parts_loading_07"
]

class FallDetectorViewController: UIViewController {
    
    let mainModel = MainModel.sharedInstance
    
    
    // MARK: Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var animationImage: UIImageView!
    
    // MARK: ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationImage.animationImages = animationImages.map { (UIImage(named: $0))! }
        animationImage.animationDuration = 2
        
        let motionManager = mainModel.motionManager
        
        if motionManager.deviceMotionActive {
            startStopButton.setImage(UIImage(named: "StopButton"), forState: UIControlState.Normal)
            animationImage.startAnimating()
        }
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fallDetected:", name: kNotification.fallDetected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "falseFallDetected:", name: kNotification.falseFall, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func startStopButtonTapped(sender: AnyObject) {
        
        if !mainModel.deviceMotionAvailable() {
            print("Accelerometer is not available")
            return
        }
        
        if mainModel.fallDetectorActive() {
            startStopButton.setImage(UIImage(named: "StartButton"), forState: UIControlState.Normal)
            mainModel.stopDetecting()
            animationImage.stopAnimating()
            print("Stop updates!!!!!!!!!!")
            
        } else {
            startStopButton.setImage(UIImage(named: "StopButton"), forState: UIControlState.Normal)
            mainModel.startDetecting()
            animationImage.startAnimating()
        }
        
    }
    
    @IBAction func allertTapped(sender: AnyObject) {
        mainModel.userAlert.fallAlert()
    }
    
    func fallDetected(notification: NSNotification) {
        startStopButton.setImage(UIImage(named: "StartButton"), forState: UIControlState.Normal)
        animationImage.stopAnimating()
    }
    
    func falseFallDetected(notification: NSNotification) {
        startStopButton.setImage(UIImage(named: "StopButton"), forState: UIControlState.Normal)
        animationImage.startAnimating()
    }
}