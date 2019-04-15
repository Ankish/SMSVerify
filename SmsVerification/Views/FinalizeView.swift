//
//  TSVerifyView.swift
//  AppVerifyDemo
//
//  Created by Plivo on 7/3/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

/**
    The finalize view with verification code field to be verified along with
    the confirm button.
 */
class FinalizeView: UIView {
    
    struct Constants {
        static let resendButtonDelay: Int = 60
    }
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(dismissKeyboard))
        return tap
    }()
    
    var phoneNumber: String? {
        didSet {
            if let number = phoneNumber {
                securityCodeTextField.title = String(format : properties.confirmScreenHintText,number)
            }
        }
    }
    
    lazy var headerView: HeaderView = {
        let view = HeaderView(properties: properties,title : properties.verifyTitle)
        return view
    }()
    
    lazy var securityCodeTextField: TextField = {
        let view = TextField(title: String(format : properties.verifyScreenHintText), type: .securityCode, properties: properties)
         if #available(iOS 12.0, *) {
            view.textField.textContentType = .oneTimeCode
        }
        view.textField.keyboardType = properties.verificationCodeKeyboardType
        return view
    }()
    
    lazy var verifySecurityCodeButton: Button = {
        let button = Button(title: properties.confirmButtonTitle, color: properties.confirmButtonBackgroundColor)
        return button
    }()
    
    lazy var resendSecurityCodeButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.setTitle(properties.resendButtonTitle, for: .normal)
        return button
    }()
    
    lazy var callButton : UIButton = {
        let button = UIButton()
        button.setTitle(properties.callButtonTitle, for: .normal)
        button.setTitleColor(properties.callButtonTitleColor ?? properties.tintColor , for: .normal)
        return button
    }()
    
    lazy var orLabel : UILabel = {
        let label = UILabel()
        label.textColor = properties.orLabelTextColor
        label.text = properties.orLabelText
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var resendHintLabel : UILabel = {
        let label = UILabel()
        label.textColor = properties.hintColor
        label.font = properties.hintFont
        label.text = properties.resendHintTitle
        return label
    }()
    
    private let properties : Properties
    private(set) var remainingSecond : CGFloat
    private var progressTimer = Timer()
    
    init(properties : Properties) {
        self.properties = properties
        self.remainingSecond = properties.timeout
        super.init(frame: .zero)
        applyStyling()
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyStyling() {
        backgroundColor = .clear
    
    }
    
    private func setupSubviews() {
        
        [headerView, securityCodeTextField, verifySecurityCodeButton,resendSecurityCodeButton,resendHintLabel,orLabel,callButton].forEach(addSubview)
        
        let top : NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top = self.safeAreaLayoutGuide.topAnchor
        } else {
            top = self.topAnchor
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            headerView.topAnchor.constraint(equalTo: top),
            headerView.heightAnchor.constraint(equalToConstant: self.properties.logoHeight + 40)])
       
        let topPadding : CGFloat
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            topPadding = 60
        } else {
            topPadding = 30
        }
        
        securityCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([securityCodeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
        securityCodeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        securityCodeTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: topPadding),
        securityCodeTextField.heightAnchor.constraint(equalToConstant: 60)])
        
        verifySecurityCodeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([verifySecurityCodeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
        verifySecurityCodeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        verifySecurityCodeButton.topAnchor.constraint(equalTo: securityCodeTextField.bottomAnchor, constant: 20),
        verifySecurityCodeButton.heightAnchor.constraint(equalToConstant: 60)])
        
        resendHintLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([resendHintLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     resendHintLabel.topAnchor.constraint(equalTo: verifySecurityCodeButton.bottomAnchor,constant : 15)])
        
        resendSecurityCodeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([resendSecurityCodeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     resendSecurityCodeButton.topAnchor.constraint(equalTo: resendHintLabel.bottomAnchor,constant : 5)])
        
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([orLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     orLabel.topAnchor.constraint(equalTo: resendSecurityCodeButton.bottomAnchor,constant : 5)])
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([callButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     callButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor,constant : 5), callButton.bottomAnchor.constraint(equalTo: bottomAnchor)])
        callButton.isHidden = true
        orLabel.isHidden = true
        
        addGestureRecognizer(tapGesture)
        setProgressText(Int(properties.timeout))
    }
    
    public func startTimer() {
        remainingSecond = properties.timeout
        resendSecurityCodeButton.isEnabled = false
        callButton.isHidden = true
        orLabel.isHidden = true
        
        resendSecurityCodeButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            
            guard let strongSelf = self else {
                return
            }
            
            self?.remainingSecond -= 1
            self?.setProgressText(Int(strongSelf.remainingSecond))
            
            if strongSelf.remainingSecond == 0 { // restart rotation
                timer.invalidate()
                self?.timedOutAction()
            }
        }
    }
    
    private func timedOutAction() {
        self.progressTimer.invalidate()
        resendSecurityCodeButton.isEnabled = true
        callButton.isHidden = !properties.isCallButtonNeeded
        orLabel.isHidden = !properties.isCallButtonNeeded
        resendSecurityCodeButton.setTitleColor(properties.resendButtonColor ?? properties.tintColor, for: .normal)
    }
    
    private func setProgressText(_ time: Int) {
        guard time != 0 else {
            resendSecurityCodeButton.setTitle(properties.resendButtonTitle, for: .normal)
            return
        }
        
        let text : String
        if time < 10 {
            text = "(00:0\(time))"
        } else if time < 60 {
            text = "(00:\(time))"
        } else {
            let minute = time / 60
            let sec = time % 60
            
            var minuteString = "\(minute)"
            var secString = "\(sec)"
            minuteString = minuteString.count == 1 ? "0\(minuteString)" : minuteString
            secString = secString.count == 1 ? "0\(secString)" : secString
            
            text = "(\(minuteString):\(secString))"
        }
        
        resendSecurityCodeButton.setTitle("\(properties.resendButtonTitle) \(text)", for: .normal)
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
}
