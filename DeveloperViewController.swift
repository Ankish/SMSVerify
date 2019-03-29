//
//  ViewController.swift
//  SmsVerification
//
//  Created by Plivo on 2/20/19.
//  Copyright © 2019 Plivo. All rights reserved.
//

import UIKit

// MARK: - DeveloperViewController
class DeveloperViewController: UIViewController {

    // MARK: - Properties
    private weak var delegate : OTPStatusControlProtocol?
    private var otpRequestId : String = ""
    private let properties = Properties()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        fetchToken()
    }
    
    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)
        
        openInitialController()
    }
    
    // MARK: - Private methods
    private func config() {
        properties.backgroundColor = UIColor.white
        properties.tintColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
        properties.confirmButtonBackgroundColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
        properties.textFieldTextColor = UIColor.black
        properties.titleColor = UIColor.black
        properties.hintColor = UIColor.black.withAlphaComponent(0.9)
        properties.hintFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        properties.logoHeight = 70
        properties.verificationCodeKeyboardType = UIKeyboardType.numberPad
        properties.urlSupportInfoAttributedString = getSupportingInformation()
    }
    
    private func showAlert(title : String,message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getSupportingInformation() -> NSAttributedString {
        let description = "By clicking Verify, you agree to our "
        let attributeText : NSMutableAttributedString = NSMutableAttributedString(string: description)
        attributeText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, attributeText.length))
        
        let termsAndConditionString = NSMutableAttributedString(string:  "Terms & Conditions")
        let termsUrl = URL(string: "https://www.google.com")!
        termsAndConditionString.setAttributes([.link: termsUrl], range: NSMakeRange(0, termsAndConditionString.length))
        attributeText.append(termsAndConditionString)
        
        let andText =  NSMutableAttributedString(string: NSLocalizedString(" and ",comment : ""))
        andText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, andText.length))
        attributeText.append(andText)
        
        let privacyString = NSMutableAttributedString(string:  "Privacy & Policy")
        let privacyUrl = URL(string: "https://www.google.com")!
        privacyString.setAttributes([.link: privacyUrl], range: NSMakeRange(0, privacyString.length))
        attributeText.append(privacyString)
        
        return attributeText
    }
    
    private func openInitialController() {
        let vc = OTPGenerationController.getInstance(properties : properties,consumerDelegate : self)
        delegate = vc as? OTPStatusControlProtocol
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Api methods
    /// fetch the token and store it in user defaults which used for all other api's
    /// For security purpose store this in KeyChain.
    /// Implement or replace your own auth mechanism.
    private func fetchToken() {
        let json: [String: Any] = ["username":Constants.userName,"password":Constants.password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let request = Request(path: "v1/authenticate/", method: .post, headers: ["Content-Type":"application/json"], body: jsonData).generateURLRequest()
        
        Service.shared.post(request : request) { [weak self] (response,code,errorMessage) in
            if let dict = response?.toDictionary(),let data = dict["data"] as? [String:String],let key = data["auth_token"] {
                UserDefaults.standard.set(key, forKey: Constants.appTokenKey)
            } else if let errorMessage = errorMessage {
                self?.showAlert( title: NSLocalizedString("Error", comment: ""), message: errorMessage)
            } else {
                self?.showAlert( title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Some thing went wrong", comment: ""))
            }
        }
    }

}

// MARK: - OTPRequestResponseProtocol method
// Check ProviderProtocol for required methods
extension DeveloperViewController : OTPRequestResponseProtocol {
    
    /**
     Generate the URLRequest for OTP generation and send it back to OTP Generation controller,
     which will trigger the request and listen to it's respone.
     */
    func requestForOTPGeneration(countryCode: String, mobileNumber: String) -> URLRequest {
        let json: [String: Any] = ["number":"\(countryCode)\(mobileNumber)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return Request(path: "v1/otp/generate/", method: .post, headers: ["Content-Type":"application/json","Authorization":"Bearer \(UserDefaults.standard.string(forKey: Constants.appTokenKey) ?? "" )"], body: jsonData).generateURLRequest()
    }
    
    /**
     Generate the URLRequest for OTP verification and send it back to OTP Verification controller,
     which will trigger the request and listen to it's respone.
     */
    func requestForOTPVerification(_ code: String) -> URLRequest {
        let json: [String: Any] = ["request_id": otpRequestId,"otp" : code]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return Request(path: "v1/otp/validate/", method: .post, headers: ["Content-Type":"application/json","Authorization":"Bearer \(UserDefaults.standard.string(forKey: Constants.appTokenKey) ?? "" )"], body: jsonData).generateURLRequest()
    }
    
    /**
     Generate the URLRequest for Resent OTP and send it back to OTP Verification controller,
     which will trigger the request and listen to it's respone.
     */
    func requestForOTPResent(countryCode: String, mobileNumber: String, retryCount: Int) -> URLRequest {
        let json: [String: Any] = ["number":"\(countryCode)\(mobileNumber)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        return Request(path: "v1/otp/generate/", method: .post, headers: ["Content-Type":"application/json","Authorization":"Bearer \(UserDefaults.standard.string(forKey: Constants.appTokenKey) ?? "" )"], body: jsonData).generateURLRequest()
    }

    /**
     Do the action which need to perform when user clicks call button.
    */
    func requestForCall(countryCode: String,mobileNumber : String) {
        
    }
    
    /**
     Response for OTP Generation Request,
     Need to assign the maxRetries (max number of retries allwoed) , timeout (Time period in seconds till the OTP is valid) and otpRequestId (Request Id for this particular Request)
    Need to call didOTPSentSuccessfully()  method if it is success else send the error title and message in showAlert method.
     */
    func responseForOTPGeneration(responseCode: Int, responseData: Data?) {
        if let data = responseData,let dict = data.toDictionary(),let status = dict["status"] as? Bool  {
            if status {
                
                if let dataDict = dict["data"] as? [String:Any],let expirySeconds = dataDict["expiry_seconds"] as? Int,let maxRetries = dataDict["max_retries"] as? Int,let requestId = dataDict["request_id"] as? String {
                    
                    properties.maxRetries = maxRetries
                    properties.timeout = CGFloat(expirySeconds)
                    otpRequestId = requestId
                    delegate?.didOTPSentSuccessfully()
                } else {
                    delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
                }
                
            } else {
                delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
            }
        } else {
            delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Some thing went wrong", comment: ""))
        }
    }
    
    /**
     Response for OTP Verification Request,
    Need to call dismiss()  method if it is success else send the error title and message in showAlert() method.
     */
    func responseForOTPVerification(responseCode: Int, responseData: Data?) {
        if let data = responseData,let dict = data.toDictionary(),let status = dict["status"] as? Bool  {
            if status {
                
                if let dataDict = dict["data"] as? [String:Any],let otpstatus = dataDict["validity"] as? Bool {
                    
                    if otpstatus {
                        delegate?.dismiss()
                    } else {
                        delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
                    }
                    
                } else {
                    delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
                }
                
            } else {
                delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
            }
        } else {
            delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Some thing went wrong", comment: ""))
        }
    }
    
   /**
     Response for OTP Generation Request,
     Need to assign the maxRetries (max number of retries allwoed) , timeout (Time period in seconds till the OTP is valid) and otpRequestId (Request Id for this particular Request)
    Need to call didResentOTPSuccessfully()  method if it is success else send the error title and message in showAlert method.
     */
    func responseForOTPResent(responseCode: Int, responseData: Data?) {
        if let data = responseData,let dict = data.toDictionary(),let status = dict["status"] as? Bool  {
            if status {
                
                if let dataDict = dict["data"] as? [String:Any],let expirySeconds = dataDict["expiry_seconds"] as? Int,let maxRetries = dataDict["max_retries"] as? Int,let requestId = dataDict["request_id"] as? String {
                    
                    properties.maxRetries = maxRetries
                    properties.timeout = CGFloat(expirySeconds)
                    otpRequestId = requestId
                    delegate?.didResentOTPSuccessfully()
                } else {
                    delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
                }
                
            } else {
                delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: dict["error"] as? String ?? NSLocalizedString("Some thing went wrong", comment: ""))
            }
        } else {
            delegate?.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Some thing went wrong", comment: ""))
        }
    }
}
