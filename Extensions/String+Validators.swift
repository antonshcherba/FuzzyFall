//
//  String+Validators.swift
//  FuzzyFall
//
//  Created by Admin on 29/02/16.
//  Copyright © 2016 antonShcherba. All rights reserved.
//

import Foundation

extension String {
    
    func isValidUsername() -> Bool {
        let usernameRegex = "^(?=.{6,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return predicate.evaluateWithObject(self)
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^\\+\\d{12}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluateWithObject(self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluateWithObject(self)
    }
}