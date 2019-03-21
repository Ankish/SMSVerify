//
//  FinalizeViewController.swift
//  AppVerifyDemo
//
//  Created by Plivo on 6/20/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import os.log

/**
    This View Controller handles the verification code received in the SMS
    payload as manual entry or using the app deep link provided to finalize the
    verification with your server.
 */
class OTPVerificationController: ViewController {

    // MARK: - Private Properties
    private let phoneNumber : String
    private let countryCode : String
    private weak var consumerDelegate : ConsumerProtocol?
    private var retryCount = 0
    
    private var bottomConstraint : NSLayoutConstraint?
    private lazy var finalizeView: FinalizeView = {
        let view = FinalizeView(properties: properties)
        return view
    }()
    private let scrollView = UIScrollView()
    
    // MARK: - Init
    init(phoneNumber: String,
         countryCode : String,
         properties : Properties,consumerDelegate : ConsumerProtocol?) {
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.consumerDelegate = consumerDelegate
        super.init(properties : properties)
        
        self.finalizeView.phoneNumber = "\(countryCode)\(phoneNumber)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        os_log("Deinit Finalize View Controller", log: Log.general, type: .info)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFinalizeView()
        self.view.backgroundColor = properties.backgroundColor
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        closeButton.tintColor = properties.tintColor
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        self.navigationController?.navigationBar.tintColor = properties.tintColor
        self.navigationItem.backBarButtonItem?.tintColor = properties.tintColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        finalizeView.securityCodeTextField.textField.becomeFirstResponder()
    }
    
    // MARK: - Private methods
    private func setupFinalizeView() {
        view.addSubview(scrollView)
        scrollView.addSubview(finalizeView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        finalizeView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = finalizeView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        NSLayoutConstraint.activate([
            finalizeView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.leadingAnchor,constant : 10),
        finalizeView.trailingAnchor.constraint(greaterThanOrEqualTo: scrollView.trailingAnchor,constant : -10),
        finalizeView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        finalizeView.widthAnchor.constraint(lessThanOrEqualToConstant: 450),
        finalizeView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        bottomConstraint
            ])
        
        let top : NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top = view.safeAreaLayoutGuide.topAnchor
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
        
        finalizeView.verifySecurityCodeButton.addTarget(self, action: #selector(verifyButtonPressed), for: .touchUpInside)
        finalizeView.resendSecurityCodeButton.addTarget(self, action: #selector(resendSecurityCode), for: .touchUpInside)
        finalizeView.callButton.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        
        finalizeView.startTimer()
    }
    
    // MARK: - Public methods
    public func resetTimer() {
        finalizeView.startTimer()
    }
    
    // MARK: - Action methods
    @objc
    private func dismissViewController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func callButtonPressed() {
        self.consumerDelegate?.requestForCall(countryCode: countryCode,mobileNumber : phoneNumber)
    }
    
    @objc
    private func verifyButtonPressed() {
        self.finalizeView.securityCodeTextField.textField.resignFirstResponder()
        
        guard let verificationCode = finalizeView.securityCodeTextField.textField.text else {
            return
        }
        
        if verificationCode.isEmpty {
            Alert.displayMissingVerificationCodeError(on: self)
            return
        } else {
            if let request = self.consumerDelegate?.requestForOTPVerification(verificationCode) {
                self.showActivityIndicator(in: self.finalizeView.verifySecurityCodeButton)
                self.finalizeView.verifySecurityCodeButton.isHidden = true
                Service.shared.post(request: request, completion: { [weak self] (data,code,errorMessage) in
                  
                    DispatchQueue.main.async {
                        self?.hideActivityIndicator()
                        self?.finalizeView.verifySecurityCodeButton.isHidden = false
                        self?.consumerDelegate?.responseForOTPVerification(responseCode: code, responseData: data)
                    }
                    
                })
            }
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
                    strongSelf.scrollView.scrollToView(view: strongSelf.finalizeView.securityCodeTextField, animated: true)
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
    
    @objc
    private func resendSecurityCode() {
        if (retryCount >= properties.maxRetries) {
            Alert.displayError(on: self, with: "Error", message: "You have exceeded the max retries.")
        } else {
            if let request = self.consumerDelegate?.requestForOTPResent(countryCode: countryCode, mobileNumber: phoneNumber, retryCount: retryCount) {
                self.showActivityIndicator(in: finalizeView.resendSecurityCodeButton)
                self.finalizeView.resendSecurityCodeButton.isHidden = true
                Service.shared.post(request: request, completion: { [weak self] (data,code,errorMessage) in
                    
                    DispatchQueue.main.async {
                        self?.finalizeView.resendSecurityCodeButton.isHidden = false
                        self?.hideActivityIndicator()
                        self?.consumerDelegate?.responseForOTPResent(responseCode : code, responseData: data)
                    }
                    
                })
            }
        }
        retryCount += 1
    }
    
}

enum ServerError: Int {
    case invalidCode = 1008
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
}
