//
//  SignUpViewController.swift
//  Motions
//
//  Created by Admin on 08/01/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    /// the text field which is editing currently
    var activeField: UITextField?
    
    var settingsManager = SettingsManager()
    
    var alertViewController: UIAlertController?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

        initializeCloseKeyboardTap()
        // TODO: Add Remember me functionality
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        registerForNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        unregisterForNotifications()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        let object = DatabaseManager.sharedInstance.fetchFirst(User.entity, query: "%K like %@",
            args: ["username", usernameTextField.text!])
        if object != nil {
            alertViewController = UIAlertController(title: "Error", message: "Such user exists.", preferredStyle: UIAlertControllerStyle.Alert)
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alertViewController!, animated: true, completion: nil)
            return
        }
        
        if let username = usernameTextField.text where !username.isValidUsername() {
            alertViewController = UIAlertController(title: "Incorrect login",
                message: "Incorrect login format.\n Please try another!",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alertViewController!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertViewController!, animated: true, completion: nil)
            return
        }
        
        // Creates user
        
        let database = DatabaseManager.sharedInstance
        let user = database.createUser(usernameTextField.text!,
            password: passwordTextField.text!)
        user.detectorSettings = database.createDetectorSettings()
        user.userSettings = database.createUserSettings(firstNameTextField.text!, last: lastNameTextField.text!)
        settingsManager.user = user
        settingsManager.setDefaultDetectorSettings()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(user.username, forKey: "loggedUserName")
        
        settingsManager.saveSettings()
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
    func unregisterForNotifications() {
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
     
     :param: textField edited text field
     */
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    /**
     Called when keyboard will show
     
     :param: notification notification
     */
    func keyboardWillShow(notification: NSNotification) {
        
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
     
     :param: notification notification
     */
    func keyboardWillHide(notification: NSNotification) {
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
