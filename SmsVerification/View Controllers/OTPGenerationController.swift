//
//  InitiateViewController.swift
//  AppVerifyDemo
//
//  Created by Plivo on 6/18/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import os.log
import libPhoneNumber_iOS
/**
    This view controller is for picking your country code and phone number
    to be verified. It binds functionality from various helpers and views to
    accumulate the data required to proceed with verification.
 */
class OTPGenerationController: OTPBaseViewController {
    
    /**
     getInstance used to initate the InitateView Controller.
     param : properties - used to configure the UI and also used for Localizing the strings.
     */
    class func getInstance(properties : Properties = Properties(),
                           consumerDelegate : OTPRequestResponseProtocol?) -> UINavigationController {
        let vc = OTPGenerationController(properties: properties)
        vc.consumerDelegate = consumerDelegate
        let navController = NavigationController(rootViewController : vc)
        return navController
    }
    
    // MARK: - Private Properties
    private lazy var initiateView: InitiateView = {
        let view = InitiateView(properties : properties)
        return view
    }()
    
    private let scrollView = UIScrollView()
    private weak var consumerDelegate : OTPRequestResponseProtocol?
    private var bottomConstraint : NSLayoutConstraint?
    private var selectedRegionCode : String? = NSLocale.current.regionCode {
        didSet {
            if let nationalNumber = getExampleNumber() {
                let formatter = NBAsYouTypeFormatter(regionCode: selectedRegionCode)
                
                initiateView.phoneTextField.textField.attributedPlaceholder = NSAttributedString(string: formatter?.inputString("\(nationalNumber)") ?? "", attributes: [NSAttributedString.Key.foregroundColor : properties.textFieldPlaceholderColor])
                
                if let prevNumber = initiateView.phoneTextField.textField.text {
                    initiateView.phoneTextField.textField.text = formatter?.inputString("\(prevNumber)") ?? ""
                }
            }
            
        }
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupInitiateView()
        self.selectedRegionCode = NSLocale.current.regionCode
        
        self.view.backgroundColor = properties.backgroundColor
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        closeButton.tintColor = properties.tintColor
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        //navigation configuration
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // MARK: - Private methods
    private func setupInitiateView() {
        view.addSubview(scrollView)
        scrollView.addSubview(initiateView)
       
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        initiateView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = initiateView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        NSLayoutConstraint.activate (
            [initiateView.topAnchor.constraint(equalTo: scrollView.topAnchor),
             initiateView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.leadingAnchor,constant : 10),
             initiateView.trailingAnchor.constraint(greaterThanOrEqualTo: scrollView.trailingAnchor,constant : -10),
             initiateView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
             initiateView.widthAnchor.constraint(lessThanOrEqualToConstant: 450),
             bottomConstraint]
        )
        
        let top : NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top = self.view.safeAreaLayoutGuide.topAnchor
        } else {
            top = self.view.topAnchor
        }
        
        NSLayoutConstraint.activate (
            [scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
             scrollView.topAnchor.constraint(equalTo: top),
             scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        )
        
        self.bottomConstraint = bottomConstraint
        
        initiateView.verifyButton.addTarget(self, action: #selector(verifyButtonPressed), for: .touchUpInside)
        
        initiateView.countryCodeTapGesture.addTarget(self, action: #selector(presentCountryCodeTableView))
        initiateView.phoneTextField.textField.becomeFirstResponder()
        initiateView.phoneTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        initiateView.urlSupportTextView?.delegate = self
    }
    
    private func getExampleNumber() -> String? {
        if let code = selectedRegionCode {
            if code == "IN" {
                return "9999999999"
            } else if code == "US" {
                return "6045550110"
            } else if let number = try?  NBPhoneNumberUtil.init().getExampleNumber(code),let nationalNumber = number.nationalNumber {
                return nationalNumber.stringValue
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func getValidPhoneNumber(phoneNumber : String) -> String {
        let numberUtil = NBPhoneNumberUtil()
        do {
            let numberParsed = try numberUtil.parse(phoneNumber, defaultRegion: self.selectedRegionCode ?? NSLocale.current.regionCode)
            let valid = numberUtil.isValidNumber(numberParsed)
            if let number = numberParsed.nationalNumber,valid {
                return "\(number)"
            }
        } catch {
            return ""
        }
        return ""
    }
    
    private func presentVerifyController(phoneNumber: String,countryCode : String) {
        DispatchQueue.main.async {
            let finalizeViewController = OTPVerificationController(phoneNumber: phoneNumber,countryCode : countryCode,properties : self.properties,consumerDelegate : self.consumerDelegate)
            self.navigationController?.pushViewController(finalizeViewController, animated: true)
        }
    }
    
    // MARK: - Action methods
    @objc
    private func verifyButtonPressed() {
        guard let countryCode = initiateView.phoneTextField.countryCodeTextField.text else { return }
        guard let phoneNumber = initiateView.phoneTextField.textField.text else { return }
        
        if phoneNumber.isEmpty {
            Alert.displayMissingPhoneNumberError(on: self)
            return
        } else {
            if let request = self.consumerDelegate?.requestForOTPGeneration(countryCode: countryCode, mobileNumber: self.getValidPhoneNumber(phoneNumber: phoneNumber)) {
                initiateView.verifyButton.isHidden = true
                showActivityIndicator(in : initiateView.verifyButton)
                Service.shared.post(request: request, completion: { [weak self] (data,code,errorMessage) in
                    
                    DispatchQueue.main.async {
                        self?.initiateView.verifyButton.isHidden = false
                        self?.hideActivityIndicator()
                        self?.consumerDelegate?.responseForOTPGeneration(responseCode : code, responseData: data)
                    }
                    
                })
                
            }
        }
    }
    
    @objc
    func dismissViewController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func textFieldDidChange(_ textView: UITextField) {
        let formatter = NBAsYouTypeFormatter(regionCode: selectedRegionCode)
        textView.text = formatter?.inputString(textView.text) ?? ""
        
        if let text = textView.text,let regionCode = self.selectedRegionCode,let number = try? NBPhoneNumberUtil.init().getExampleNumber(regionCode),let nationalNumber = number.nationalNumber,let formatNationalNumber = formatter?.inputString(nationalNumber.stringValue),text.count >= formatNationalNumber.count {
            if getValidPhoneNumber(phoneNumber : text).isEmpty {
                initiateView.phoneTextField.setErrorText(string: "Invalid Phone number")
            } else {
                 initiateView.phoneTextField.setErrorText(string: nil)
            }
        } else {
            initiateView.phoneTextField.setErrorText(string: nil)
        }
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let rect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            bottomConstraint?.constant = -(rect.size.height)
            print("rect : \(rect)")
            
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
                if let strongSelf = self {
                    strongSelf.scrollView.scrollToView(view: strongSelf.initiateView.phoneTextField, animated: true)
                }
            })
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification){
         bottomConstraint?.constant = 0
        
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    public func openValidationScreen() {
        guard let countryCode = initiateView.phoneTextField.countryCodeTextField.text else { return }
        guard let phoneNumber = initiateView.phoneTextField.textField.text else { return }
        
        presentVerifyController(phoneNumber: "\(self.getValidPhoneNumber(phoneNumber: phoneNumber))",countryCode : countryCode)
    }
    
    @objc func presentCountryCodeTableView() {
        let viewController = CountryCodeViewController(properties: properties)
        viewController.delegate = self
        let navController = UINavigationController(rootViewController: viewController)
        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: - CountryCodeViewDelegate
extension OTPGenerationController: CountryCodeViewDelegate {
    func didSelectCountryCode(countryCodeInfo: CountryCodeInfo) {
        self.selectedRegionCode = countryCodeInfo.code
        initiateView.phoneTextField.countryCode = countryCodeInfo.dialCode
        if let imageFile = Bundle.main.path(forResource: countryCodeInfo.code, ofType: "png") {
            initiateView.phoneTextField.countryImage = UIImage(contentsOfFile: imageFile)
        }
    }
}

// MARK: - UITextViewDelegate
extension OTPGenerationController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        
        return false
    }
}
