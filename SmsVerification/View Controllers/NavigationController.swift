//
//  NavigationController.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/8/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import UIKit

class NavigationController : UINavigationController,OTPStatusControlProtocol {
    
    func showAlert(title: String, message: String) {
        if let controller = self.topViewController as? OTPBaseViewController {
            Alert.displayError(on: controller, with: title, message: message, dismissController: false)
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didOTPSentSuccessfully() {
        if let controller = self.topViewController as? OTPGenerationController {
            controller.openValidationScreen()
        }
    }
    
    func didResentOTPSuccessfully() {
        if let controller = self.topViewController as? OTPVerificationController {
            controller.resetTimer()
        }
    }
}
