//
//  ViewController.swift
//  AppVerifyDemo
//
//  Created by Plivo on 7/3/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    public let properties : Properties
    
    init(properties : Properties) {
        self.properties = properties
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.properties = Properties()
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .whiteLarge
        indicator.color = properties.tintColor
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
    
    public func showActivityIndicator(in view : UIView) {
        
        if (activityIndicator.superview != nil) {
            activityIndicator.removeFromSuperview()
        }
        
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     activityIndicator.centerYAnchor.constraint(equalTo : view.centerYAnchor)])
    }
    
    public func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
