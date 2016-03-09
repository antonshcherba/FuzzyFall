//
//  LoginViewController.swift
//  Motions
//
//  Created by Admin on 09/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var activeField: UITextField?
    
    var alertViewController: UIAlertController?
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        initializeCloseKeyboardTap()
        getCurrentLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        registerForNotifications()
    }
    
    var locationManager = CLLocationManager()
    
    func getCurrentLocation() {
        print("gets current location")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .Denied:
            print("Denied")
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            print("Authorized")
        case .NotDetermined:
            print("Not deter")
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse:
            print("in use")
        default:
            print("")
        }
        
        locationManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            print("YES")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromNotifications()
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let user = DatabaseManager.sharedInstance.fetchFirst(User.entity, query: "%K LIKE %@",
            args: ["username", usernameTextField.text!]) as! User?
        
        if user == nil {
            alertViewController = UIAlertController(title: "Error", message: "Such user doesn't exists.", preferredStyle: UIAlertControllerStyle.Alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alertViewController!, animated: true, completion: nil)
            return
        } else if user?.password != passwordTextField.text! {
            alertViewController = UIAlertController(title: "Error", message: "Invalid user password", preferredStyle: UIAlertControllerStyle.Alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alertViewController!, animated: true, completion: nil)
            return
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(user?.username, forKey: "loggedUserName")
        
        performSegueWithIdentifier("RevealViewController", sender: self)
    }
    
    /**
     Registers for notifications
     */
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     Unregisters from notifications
     */
    func unregisterFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func initializeCloseKeyboardTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleOnTapAnywhereButKeyboard:")
        tapRecognizer.delegate = self //delegate event notifications to this class
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    /**
     Called when text field starts editing
     
     :param: textField edited text field
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    /**
     Called when text field ends editing
     
     - parameter textField: edited text field
     */
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    /**
     Called when keyboard will show
     
     - parameter notification: notification
     */
    func keyboardWillShow(notification: NSNotification) {
        scrollView.scrollEnabled = true
        
        if let userInfo = notification.userInfo {
            if let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let insets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
                
                var aRect = view.frame
                aRect.size.height -= kbSize.height
                if !CGRectContainsPoint(aRect, activeField!.frame.origin) {
                    scrollView .scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
        }
    }
    
    /**
     Called when keyboard will hide
     
     - parameter: notification notification
     */
    func keyboardWillHide(notification: NSNotification) {
        scrollView.scrollEnabled = false
        let insets = UIEdgeInsetsZero
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        updateViewConstraints()
    }
    
    /**
     Checks enter button processing
     
     :param: textField edited text field
     :returs: true, if should process enter button
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
